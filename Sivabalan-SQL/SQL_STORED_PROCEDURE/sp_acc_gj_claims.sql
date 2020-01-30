Create procedure sp_acc_gj_claims(@claimid integer,@BackDate DATETIME=Null)    
As    
DECLARE @nClaimType integer,@dclaimdate datetime,@nvendorid nvarchar(15)    
DECLARE @nclaimvalue decimal (18,6),@claimsreceivable integer,@SecondarySchemeExpense integer,@documentid integer    
DECLARE @ndoctype integer,@accountid integer    
Declare @AdjReasonID Int, @AdjustedAmount Decimal(18,6),@AdjAccountID Int    
declare @uniqueid integer    
  
    
set @claimsreceivable =10  /*constant to store claimsreceivable Account*/     
set @SecondarySchemeExpense=39  /*constant to store secondary scheme expenses Account*/     
set @ndoctype=22   /*constant to store document type Account*/     
set @accountid=0  /*constant to store the vendors AccountID*/     
  
  
Declare @TaxAmt Decimal(18,6)  
Declare @VATPayable int  
Declare @TotClaimableValuewithoutTax Decimal(18,6)   
Declare @GVclaimvalue Decimal(18,6)  
  
Declare @LoyalName nVarchar(255)  
Declare @LoyaltyID nVarchar(255)  
Declare @MonthName nVarchar(255)  
Declare @CLOMonthName nVarchar(255)  
Declare @GVAccountID int  
Declare @GVValue Decimal(18,6)  

Set @VATPayable = 116  
Set @TotClaimableValuewithoutTax = 0  
Set @TaxAmt = 0  
  
Declare @CSTaXamount Decimal(18,6)  
Declare @CStotalClaimamount Decimal(18,6)  
Declare @CSActualClaimamountWithoutTax Decimal(18,6)  
Declare @GVAccount int  
  
Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation    

--GST_Changes starts here
DECLARE @GSTEnable INT
DECLARE	@GSTCount INT 
DECLARE	@Rowid INT
DECLARE	@GSTPayable INT
DECLARE	@GSTaxComponent INT
DECLARE	@nGSTaxAmt Decimal(18,6)
DECLARE @BillAbs_StateType	INT
DECLARE @DandDid INT
DECLARE @GSTFlag INT
DECLARE @UTGSTFlag INT

Select @GSTEnable = ISNULL(flag,0) 
from Tbl_MERP_Configabstract(NOLOCK)
Where screencode = 'GSTaxEnabled'  

Select @UTGSTFlag = isnull(Flag,0) 
from Tbl_MERP_Configabstract(nolock)
where screencode = 'UTGST'

Create Table #GSTaxCalc  --For GS Tax Calculation
(Id int identity(1,1), 
 DandDID int,
 Tax_Component_Code int, 
 Tax_Value decimal(18,6),
 GST_Flag  int
)

If @GSTEnable = 1 
Begin
	select @DandDID = ID from DandDAbstract where ClaimID=@claimid

	Insert Into #GSTaxCalc 
	(DandDID , Tax_Component_Code , Tax_Value		, GST_Flag	)
	Select 
	DandDID , Tax_Component_Code , SUM(Tax_Value)	, tx.GSTFlag
	from	DandDTaxComponents	bl(NOLOCK)
	JOIN	Tax		tx(NOLOCK)
	on(		tx.Tax_Code = bl.Tax_Code
	AND		ISNULL(tx.GSTFlag,0)= 1		
	)
	Where DandDID = @DandDID
	Group By Tax_Component_Code,DandDID,tx.GSTFlag
	Union
	Select 
	dt.ID , acc.accountid , SUM(dt.TaxAmount)	, 0
	From	DandDDetail	 dt(NOLOCK),
	AccountsMaster		acc(NOLOCK)
	where acc.AccountName	= Case @UTGSTFlag When 1 Then 'UTGST Output' Else 'SGST Output' End
	and	dt.Batch_code	not in ( select Batch_Code from DandDTaxComponents(nolock)
								 Where DandDID = @DandDID )
	and	dt.ID = @DandDID
	Group By dt.ID,acc.accountid
End  
--GST_Changes ends here
    
--select @dclaimdate =[ClaimDate],@nClaimType=[ClaimType], @nclaimvalue =[ClaimValue],@nvendorid=[VendorID]    
--from claimsnote where [ClaimID]=@claimid    
Declare @CreditNoteRef nVarchar(255)  
Declare @SalvageValue decimal(18,6) 
select @nClaimType=[ClaimType], @nclaimvalue =[ClaimValue],@nvendorid=[VendorID]    
, @CreditNoteRef = isNull(Remarks,'')  
from claimsnote where [ClaimID]=@claimid    
If @nClaimType = 2 -- Damages
BEGIN
	Create Table #tmpSal(Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SalVal decimal(18,6))
	insert into #tmpSal(Product_code,SalVal)
	Select distinct Product_code,max(isnull(salvageUOMValue,0)) from DandDDetail where ID in (select ID from DandDAbstract where ClaimID=@claimid)
	Group by Product_code
	Select @nclaimvalue= ClaimValue from DandDAbstract where ClaimID=@claimid
	Select @SalvageValue=isnull(sum(isnull(SalVal,0)),0) from #tmpSal
	Drop Table #tmpSal
END
  
Select @GVAccount = AccountID from creditNote where Flag = 2 and GiftVoucherNO = @CreditNoteRef   
  
Select Top 1 @dclaimdate = SubmissionDate From tbl_mERP_RFAAbstract Where DocReference = @claimid  
  
select @accountid=isnull([AccountID],0) from Vendors where [VendorID]=@nvendorid    
    
begin tran    
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24    
 select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24    
commit tran    
    
begin tran    
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51    
 select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51    
commit tran    
-- Account    
If @nclaimvalue <> 0    
Begin     
	If @nClaimType = 2
	BEGIN
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@documentid,@accountid,@dclaimdate,@nclaimvalue+@SalvageValue,0,@claimid,@ndoctype,'Claims Raise',@uniqueid)      
	END
	ELSE
	BEGIN
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@documentid,@accountid,@dclaimdate,@nclaimvalue,0,@claimid,@ndoctype,'Claims Raise',@uniqueid)      
	END
 Insert Into #TempBackdatedAccounts(AccountID) Values(@accountid)    
end    
    
if @nclaimvalue <> 0    
begin    
	If (@nClaimType=4) Or (@nClaimType=6) -- Secondary Scheme    
	Begin    
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@documentid,@SecondarySchemeExpense,@dclaimdate,0,@nclaimvalue,@claimid,@ndoctype,'Claims Raise',@uniqueid)    
		Insert Into #TempBackdatedAccounts(AccountID) Values(@SecondarySchemeExpense)    
	End    
	Else If @nClaimType=5 -- Adjustment Reason    
	Begin    
		DECLARE scanclaimsdetail CURSOR KEYSET FOR    
		Select AdjReasonID,AdjustedAmount FROM ClaimsDetail WHERE ClaimID=@claimid    
		OPEN scanclaimsdetail    
		FETCH FROM scanclaimsdetail Into @AdjReasonID,@AdjustedAmount    
		WHILE @@Fetch_Status =0    
		Begin    
			If IsNull(@AdjustedAmount,0)<>0    
			Begin    
				Select @AdjAccountID =AccountID From AdjustmentReason where AdjReasonID=@AdjReasonID    

				insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@documentid,@AdjAccountID,@dclaimdate,0,@AdjustedAmount,@claimid,@ndoctype,'Claims Raise',@uniqueid)    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@AdjAccountID)     
			End    
			Fetch Next From scanclaimsdetail Into @AdjReasonID,@AdjustedAmount    
		End    
		CLOSE scanclaimsdetail    
		DEALLOCATE scanclaimsdetail    
	End    
	Else If (@nClaimType=1) Or (@nClaimType=2) Or (@nClaimType=3)   
	Begin    
	/*1 -2- 3=> Dmaages, Expiry, Sampling  */  
	-- Claims Receivable Account    
    
		Select @TotClaimableValuewithoutTax = Cast(IsNull(Sum(Quantity * Rate), 0)  as Decimal(18,6))  from ClaimsDetail where ClaimID = isNull(@claimid,0)  
		Select @TaxAmt = Sum(IsNull(TaxAmount,0)) from ClaimsDetail where ClaimID = IsNull(@claimid,0)  

		if @nClaimType=2
		BEGIN
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@documentid,@claimsreceivable,@dclaimdate,0,(isnull(@nclaimvalue,0)+isnull(@SalvageValue,0))-isnull(@TaxAmt,0),@claimid,@ndoctype,'Claims Raise',@uniqueid)    
		END
		ELSE
		BEGIN
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@documentid,@claimsreceivable,@dclaimdate,0,@TotClaimableValuewithoutTax,@claimid,@ndoctype,'Claims Raise',@uniqueid)    
		END
		--GST_Changes starts here
		If ((@GSTEnable = 1 ) and (@nClaimType=2))--GST GJ Posting for Damages
		Begin		
		Select @GSTCount = MAX(ID) from #GSTaxCalc

		If (@GSTCount > 0)
		Begin
		 Select @RowId = 1
		 While ( @RowId <= @GSTCount)		
		 Begin
		  Select @GSTaxComponent = Tax_Component_Code,
				 @nGSTaxAmt	= Tax_Value,
				 @GSTFlag	= GST_Flag				 
		  from	#GSTaxCalc
		  where	ID = @RowId
				
		  If @nGSTaxAmt <> 0    
		  Begin
		   Select  @GSTPayable	  = InputAccID 
		   from	 TaxComponentDetail(nolock) 
		   Where TaxComponent_Code = @GSTaxComponent

		   --Entry for GS Tax Accounts
		   If ((isnull(@GSTPayable,0) > 0) and (@GSTFlag = 1))
		   Begin
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
			Values(@DocumentID,@GSTPayable,@dclaimdate,0,@nGSTaxAmt,@claimid,@nDocType,'Claims Raise',@UniqueID)    
		   End
		   Else If ((@GSTaxComponent > 0) and (@GSTFlag = 0))
		   Begin
			Set @GSTPayable = @GSTaxComponent -- UTGST/SGST Output Account ID

			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
			Values(@DocumentID,@GSTPayable,@dclaimdate,0,@nGSTaxAmt,@claimid,@nDocType,'VAT Claims Raise',@UniqueID)			
		   End		   
		  End
		  Select @RowId = @RowId+1
		 End 
		End 
		Else --GST flag Disabled in Bill abstract
		Begin --UTGST Output / SGST Output
		 If (@UTGSTFlag = 1)
		 Begin
		  Select @GSTPayable	= AccountId
		  from	AccountsMaster (nolock)
		  Where	AccountName		= 'UTGST Output'
		 End
		 Else
		 Begin
		  Select @GSTPayable	= accountid
		  from	AccountsMaster (nolock)
		  where	AccountName		= 'SGST Output'
		 End	
			
		 If ((@TaxAmt <> 0 ) and (isnull(@GSTPayable,0)>0))  
		 Begin
		  Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
		  [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
		  Values(@DocumentID,@GSTPayable,@dclaimdate,0,@TaxAmt,@claimid,@nDocType,'VAT Claims Raise',@UniqueID)   
		 End			
		End   	
		End
		Else --GST_Changes ends here
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@documentid,@VATPayable,@dclaimdate,0,@TaxAmt,@claimid,@ndoctype,'Claims Raise',@uniqueid)   
  
		/* Salvage DandD Changes*/
		if isnull(@SalvageValue,0)<>0
		BEGIN
			begin tran    
			 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24    
			 select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24    
			commit tran    
			    
			begin tran    
			 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51    
			 select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51    
			commit tran              

			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@documentid,@claimsreceivable,@dclaimdate,@SalvageValue,0,@claimid,@ndoctype,'Claims Raise - Salvage',@uniqueid)    

			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@documentid,@accountid,@dclaimdate,0,@SalvageValue,@claimid,@ndoctype,'Claims Raise - Salvage',@uniqueid)    
		END
		Insert Into #TempBackdatedAccounts(AccountID) Values(@SecondarySchemeExpense)     
		Insert Into #TempBackdatedAccounts(AccountID) Values(@VATPayable)     
	End  
	Else If (@nClaimType=8) Or (@nClaimType=9) -- Display & Points  
	Begin  
		Select @CSTaXamount = IsNull(TaxAmount,0) from claimsnote Where ClaimID = isNull(@claimid,0)  
		Select @CStotalClaimamount = IsNull(ClaimValue,0) from claimsnote Where ClaimID = isNull(@claimid,0)    

		Set @CSActualClaimamountWithoutTax = IsNull(@CStotalClaimamount,0) - IsNull(@CSTaXamount,0)  

		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@documentid,@claimsreceivable,@dclaimdate,0,@CSActualClaimamountWithoutTax,@claimid,@ndoctype,'Claims Raise',@uniqueid)    

		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@documentid,@VATPayable,@dclaimdate,0,@CSTaXamount,@claimid,@ndoctype,'Claims Raise',@uniqueid)   

		Insert Into #TempBackdatedAccounts(AccountID) Values(@SecondarySchemeExpense)     
		Insert Into #TempBackdatedAccounts(AccountID) Values(@VATPayable)     
  
	End     
	Else If (@nClaimType=7) -- Trade scheme  
	Begin  
		Declare @TaxConfigFlag Int  
		Declare @QPS Int,@SchemeID Int  
		Declare @PayoutID Int  
		Declare @SlabType Int  
		Declare @QPSTaxAmnt Decimal(18,6)  
		Declare @TaxConfigCrdtNote Int  

		/* Checking for Tax Configuration /  
		Flag = 1 Include Tax   
		Flag = 0 Without Tax   
		For Rebate Value calculation for Free Item*/  
		Select @TaxConfigFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract   
		Where ScreenCode = 'RFA01'  

		/* Tax Config flag for Credit Note */  
		Select @TaxConfigCrdtNote = IsNull(Flag, 0) From tbl_merp_ConfigAbstract   
		Where ScreenCode = 'RFA02'  



		Select @SchemeID = DocumentID,@PayoutID = ID,@SlabType = SlabType  
		From tbl_mERP_RFAAbstract RFA, tbl_mERP_SchemePayoutPeriod SPP,tbl_mERP_SchemeSlabDetail SLAB  
		Where DocReference = isNull(@claimid,0) And RFA.DocumentID = SPP.SchemeID And PayoutPeriodFrom = RFA.PayoutFrom   
		And PayoutPeriodTo = RFA.PayoutTo And SLAB.SchemeID = SPP.SchemeID  

		Select  @QPS = QPS From tbl_mERP_SchemeOutlet Where SchemeID = @SchemeID And QPS = 1  
  
  
   
		Select @CSTaXamount = IsNull(TaxAmount,0) from claimsnote Where ClaimID = isNull(@claimid,0)  
		Select @CStotalClaimamount = IsNull(ClaimValue,0) from claimsnote Where ClaimID = isNull(@claimid,0)    

		Set @QPSTaxAmnt = 0  
		If @QPS = 1 And (@SlabType = 1 Or @SlabType = 2)  
		Begin  
			If @TaxConfigCrdtNote = 0   
			Select @QPSTaxAmnt = Sum(Rebate_Val)-Sum(RFARebate_Val) from tbl_merp_qpsdtldata Where    
			Schemeid = @SchemeID  And PayoutID = @PayoutID  
		End  

		If @SlabType <> 3  
		Begin  
			If @TaxConfigCrdtNote = 0   
				Set @CSActualClaimamountWithoutTax = IsNull(@CStotalClaimamount,0) + IsNull(@QPSTaxAmnt,0)  
			Else  
				Set @CSActualClaimamountWithoutTax = IsNull(@CStotalClaimamount,0) - IsNull(@QPSTaxAmnt,0)  
		End  
		Else  
		Begin  
			If @TaxConfigFlag = 0   
				Set @CSActualClaimamountWithoutTax = IsNull(@CStotalClaimamount,0) --+ IsNull(@CSTaXamount,0) (TaxAmount need not to consider for Free item schemes)  
			Else  
				Set @CSActualClaimamountWithoutTax = IsNull(@CStotalClaimamount,0)-IsNull(@CSTaXamount,0)  
			End  
    
     
		   If @TaxConfigCrdtNote = 0   
		   Begin  
			--    If @SlabType = 3  
			--     insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			--     [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			--     Values(@documentid,@VATPayable,@dclaimdate,@CSTaXamount,0,@claimid,@ndoctype,'Claims Raise',@uniqueid)  
			--    Else   
			 /* TaxConfig is set without Tax then the difference between the credit note vaue and  
			 and RFA Value should be posted in the Vat payable account in the debit side*/  
			 If @QPSTaxAmnt > 0   
			 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			 Values(@documentid,@VATPayable,@dclaimdate,@QPSTaxAmnt,0,@claimid,@ndoctype,'Claims Raise',@uniqueid)  
		   End  
     
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@documentid,@SecondarySchemeExpense,@dclaimdate,0,@CSActualClaimamountWithoutTax,@claimid,@ndoctype,'Claims Raise',@uniqueid)    

			If @TaxConfigFlag = 1  
			Begin  
				If @CSTaXamount > 0   
					insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
					Values(@documentid,@VATPayable,@dclaimdate,0,@CSTaXamount,@claimid,@ndoctype,'Claims Raise',@uniqueid)   
			End  
  
    
			Insert Into #TempBackdatedAccounts(AccountID) Values(@SecondarySchemeExpense)     
			Insert Into #TempBackdatedAccounts(AccountID) Values(@VATPayable)     
		End  
		Else If (@nClaimType=10) -- Loyalty  
		Begin  
			/* Commented As On Nov 8 2010  
			select @GVclaimvalue =[ClaimValue]  from claimsnote where [ClaimID]=@claimid    
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@documentid,@GVAccount,@dclaimdate,0,@GVclaimvalue,@claimid,@ndoctype,'Claims Raise',@uniqueid)   
			-- Commented As On Nov 8 2010  
			*/  
			Select @LoyalName = substring(@CreditNoteRef, 1, CharIndex('-', @CreditNoteRef, 1)-1)  
			SElect @LoyaltyID = LoyaltyID From Loyalty where Loyaltyname = @LoyalName  
			--Select @MonthName = substring( @CreditNoteRef, CharIndex('-', @CreditNoteRef, 1)+ 1, 3)  
			Select @MonthName = substring( @CreditNoteRef, CharIndex('-', @CreditNoteRef, 1)+ 1, 8)
			Select @CLOMonthName = right(@CreditNoteRef,8)  

			--SElect @LoyalName, @LoyaltyID, @MonthName  
			/* NON CLO CREDIT NOTES*/ 
			Declare Mycur Cursor for  
			Select AccountID, NoteValue from CreditNote   
			Where Isnull(claimrfa,0)=1 and IsNull(Status,0) not in (64,128) and Flag = 2 
			--and CONVERT(varchar(3), DocumentDate, 100) = @MonthName 
			and CONVERT(varchar(3), DocumentDate, 100) + '-' + CONVERT(varchar(4), DocumentDate, 112) = @MonthName 
			and LoyaltyID = @LoyaltyID  
			And CreditID not in (select Distinct isnull(CreditID,0) from CLOCrNote)
			Open MyCur  
			Fetch From Mycur Into @GVAccountID, @GVValue  
			While @@Fetch_Status = 0  
			Begin  
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@documentid, @GVAccountID, @dclaimdate, 0, @GVValue, @claimid, @ndoctype, 'GV Claims Raise', @uniqueid)   
				Fetch Next From Mycur Into @GVAccountID, @GVValue   
			End  
			Close MyCur  
			Deallocate MyCur  
			/* For CLO Credit notes */

			Declare Mycur Cursor for  
			Select AccountID, NoteValue from CreditNote   
			Where Isnull(claimrfa,0)=1 and IsNull(Status,0) not in (64,128) and   
			Flag = 1 and Right(Memo,8) = @CLOMonthName and LoyaltyID = @LoyaltyID  
			And CreditID in (select Distinct CreditID from CLOCrNote)
			Open MyCur  
			Fetch From Mycur Into @GVAccountID, @GVValue  
			While @@Fetch_Status = 0  
			Begin  
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@documentid, @GVAccountID, @dclaimdate, 0, @GVValue, @claimid, @ndoctype, 'GV Claims Raise', @uniqueid)   
				Fetch Next From Mycur Into @GVAccountID, @GVValue   
			End  
			Close MyCur  
			Deallocate MyCur

		End  
		Else  
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@documentid,@claimsreceivable,@dclaimdate,0,@nclaimvalue,@claimid,@ndoctype,'Claims Raise',@uniqueid)    
			Insert Into #TempBackdatedAccounts(AccountID) Values(@claimsreceivable)     
	End    
    
	/*Backdated Operation */    
	If @BackDate Is Not Null      
	Begin    
		Declare @TempAccountID Int    
		DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR    
		Select AccountID From #TempBackdatedAccounts    
		OPEN scantempbackdatedaccounts    
		FETCH FROM scantempbackdatedaccounts INTO @TempAccountID    
		WHILE @@FETCH_STATUS =0    
		Begin    
			Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID    
			FETCH NEXT FROM scantempbackdatedaccounts INTO @TempAccountID    
		End    
		CLOSE scantempbackdatedaccounts    
		DEALLOCATE scantempbackdatedaccounts    
	End    
Drop Table #TempBackdatedAccounts
Drop Table #GSTaxCalc --GST_Changes 
