CREATE Procedure sp_acc_gj_billgrn(@BillID Integer,@BackDate DateTime=NULL)  
As  
DECLARE @nBillID Integer,@dBillDate DateTime,@nValue Decimal(18,6),@nTaxAmount Decimal(18,6)  
DECLARE @AccountID Integer
DECLARE @DocumentID Integer,@nVendorID nVarChar(15),@Purchase Integer,@PurchaseTax Integer,@nTotalAmt Decimal(18,6),@nDocType Integer  
DECLARE @UniqueID Integer
DECLARE @NetAmount Decimal(18,6),@TaxAmount Decimal(18,6),@DiscountComputed Decimal(18,6)  
DECLARE @DiscountOption Integer,@OverAllDiscount Decimal(18,6),@OverAllDiscountvalue Decimal(18,6)  
DECLARE @AcceptedValue Decimal(18,6)  
DECLARE @TotalPurchase Decimal(18,6)  
DECLARE @TotalTaxAmount Decimal(18,6)  
DECLARE @RejectionValue Decimal(18,6)  
DECLARE @TotalRejectionValue Decimal(18,6)  
DECLARE @TotalNetAmount Decimal(18,6)  
DECLARE @AdjustedAmount Decimal(18,6)   
DECLARE @GrossAmount Decimal(18,6)  
DECLARE @PurchaseDiscount Decimal(18,6)  
DECLARE @PurchaseDiscountAccount Integer  
DECLARE @REJECTIONTYPE Integer  
DECLARE @Vat_Exists Integer
DECLARE @VAT_Receivable Integer
DECLARE @nVatTaxAmount Decimal(18,6)
DECLARE @Disc_NewImpl INT
DECLARE @Freight Decimal(18,6)
DECLARE @Octroi Decimal(18,6)
DECLARE @Prod_Disc Decimal(18,6)
DECLARE @Trade_Disc Decimal(18,6)
DECLARE @Addl_Disc Decimal(18,6)
DECLARE @Disc_AccID INT
DECLARE @Disc_Amt Decimal(18,6)
DECLARE @TotalDisc_Amt Decimal(18,6)
DECLARE @Freight_Account INT
DECLARE @Octroi_Account INT
DECLARE @TaxType Int

SET @REJECTIONTYPE=56  
SET @PurchaseDiscountAccount=106  
SET @Purchase=6 /* Constant to store the Purchase AccountID*/   
SET @PurchaseTax=2 /* Constant to store the PurchaSETax AccountID*/   
SET @nDocType=8 /* Constant to store the Document Type*/   
SET @AccountID=0 /* variable to store the VEndor's AccountID*/              
SET @nTotalAmt=0 /* variable to store the Summedup Value of [Value+TaxAmount]*/   
SET @AdjustedAmount=0  
SET @VAT_Receivable=115 /* Constant to store the VAT Receivable(Input Tax Credit)AccountID*/     
SET @Freight_Account=118
SET @Octroi_Account=113
SET @Disc_NewImpl=0
SET @Vat_Exists=0 
SET @TaxType = 1 

--Execute sp_acc_gj_grnbill @BillID,@BackDate  
  
CREATE TABLE #TempBackDatedBillGRN(AccountID INT)--for backdated operation  

--GST_Changes starts here
declare @GSTEnable int,
		@GSTCount int , 
		@Rowid int, 
		@GSTReceivable int, 
		@GSTaxComponent int ,
		@nGSTaxAmt decimal(18,6),
		@billabs_StateType	int	

select @GSTEnable = isnull(flag,0) 
from tbl_merp_configabstract(nolock)
where screencode = 'GSTaxEnabled'  

create table #gstaxcalc  --for gs tax calculation
(	id int identity(1,1), 
	billid int,
	tax_component_code int, 
	tax_value decimal(18,6),
	gst_flag  int
)
--GST_Changes ends here

If dbo.ColumnExists('Billabstract','VATTaxAmount')=1
Begin
	SET @Vat_Exists=1
End

If @Vat_Exists=1
Begin
	Select @nBillID=[BillID],@dBillDate=[BillDate],@nValue=IsNULL(Value,0),  
	@nTaxAmount=IsNULL([TaxAmount],0)-IsNULL(VATTaxAmount,0),
	@nVendorID=IsNULL([VendorID],0),@DiscountOption=IsNULL(DiscountOption,0),
	@OverAllDiscount=IsNULL(Discount,0),@AdjustedAmount=IsNULL(AdjustmentAmount,0),@billabs_StateType = isnull(StateType,0), --GST_Changes
	@nVatTaxAmount=IsNULL(VATTaxAmount,0), @TaxType = IsNULL(TaxType,1) from BillAbstract Where [BillID]=@BillID   
End
Else
Begin
	Select @nBillID=[BillID],@dBillDate=[BillDate],@nValue=IsNULL(Value,0),  
	@nTaxAmount=IsNULL([TaxAmount],0),@nVendorID=IsNULL([VendorID],0),  
	@DiscountOption=IsNULL(DiscountOption,0),@OverAllDiscount=IsNULL(Discount,0),@billabs_StateType = isnull(StateType,0), --GST_Changes
	@AdjustedAmount=IsNULL(AdjustmentAmount,0) from BillAbstract Where [BillID]=@BillID   
End

--GST_Changes starts here
--GST Enabled 
if @GSTEnable = 1 
begin
	insert into #gstaxcalc 
	(billid , tax_component_code , tax_value	, gst_flag	)
	select 
	billid , tax_component_code , sum(tax_value), tx.GSTFlag
	from	billtaxcomponents	bl(nolock)
	join	tax		tx(nolock)
	on(		tx.Tax_Code			= bl.Tax_Code	
	and		isnull(tx.GSTFlag,0)= 1	
	)
	where billid = @billid
	group by tax_component_code,billid,tx.GSTFlag		
end
--GST_Changes ends here
  
Select @GrossAmount=Sum(Quantity * PurchasePrice) from BillDetail Where BillID=@BillID
Select @Prod_Disc=IsNULL(ProductDiscount,0),@Addl_Disc=IsNULL(AddlDiscountAmount,0),
@Freight=IsNULL(Freight,0),@Octroi=IsNULL(OctroiAmount,0) from BillAbstract Where [BillID]=@BillID

SET @nValue=IsNULL(@nValue,0)-IsNULL(@Freight,0)-IsNULL(@Octroi,0)
SET @PurchaseDiscount=IsNULL(@GrossAmount,0)-IsNULL(@nValue,0)
SET @PurchaseDiscount=IsNULL(@PurchaseDiscount,0)
  
Select @AcceptedValue=(((Quantity * PurchasePrice)* Discount)/100) from BillDetail Where BillID=@BillID
  
SET @NetAmount=0  
SET @DiscountComputed=0  
SET @TaxAmount=0  
SET @TotalTaxAmount=0  
SET @TotalPurchase=0   
SET @RejectionValue=0  
SET @TotalRejectionValue=0  
SET @TotalNetAmount=0  
SET @nValue=@nValue+@AdjustedAmount   
SET @nTotalAmt=@nValue+@nTaxAmount  

If @Vat_Exists=1 
Begin
	SET @nTotalAmt=@nTotalAmt+@nVatTaxAmount  
End
SET @nTotalAmt=IsNULL(@nTotalAmt,0)+IsNULL(@Freight,0)+IsNULL(@Octroi,0)

Select @AccountID=IsNULL([AccountID],0) from [Vendors] Where [VendorID]=@nVendorID

If @AccountID <> 0  
Begin  
	Begin Tran  
	Update DocumentNumbers SET DocumentID=DocumentID+1 Where DocType=24  
	Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24  
	commit Tran  
  
	Begin Tran  
	Update DocumentNumbers SET DocumentID=DocumentID+1 Where DocType=51  
	Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51  
	Commit Tran 
	/* FOR FMRP */
	if @TaxType = 4
	BEGIN
		
		/* FMRP Tax Type - Tax Amount will be added with Purchase Account */
		If @Vat_Exists=1
		Begin
			If isnull(@nVatTaxAmount,0) <> 0 or isnull(@Purchase,0) <> 0
			Begin 
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
				Values(@DocumentID,@Purchase,@dBillDate,isnull(@nValue,0)+isnull(@nVatTaxAmount,0),0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
				Insert INTO #TempBackDatedBillGRN(AccountID) Values(@Purchase)   
			End  
		End
		else
		Begin
			If isnull(@nTaxAmount,0) <> 0 or isnull(@Purchase,0) <> 0
			Begin  
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
				Values(@DocumentID,@Purchase,@dBillDate,isnull(@nValue,0)+isnull(@nTaxAmount,0),0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
				Insert INTO #TempBackDatedBillGRN(AccountID) Values(@PurchaseTax)   
			End  
		End
  
		If @Freight <> 0
		Begin
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
			Values(@DocumentID,@Freight_Account,@dBillDate,@Freight,0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
			Insert INTO #TempBackDatedBillGRN(AccountID) Values(@Freight_Account)   
		End
   
		If @Octroi <> 0
		Begin
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
			Values(@DocumentID,@Octroi_Account,@dBillDate,@Octroi,0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
			Insert INTO #TempBackDatedBillGRN(AccountID) Values(@Octroi_Account)   
		End
  
	  	 /* FOR FMRP Tax Type */
		If @nTotalAmt <> 0 
		Begin 
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
			Values(@DocumentID,@AccountID,@dBillDate,0,@nTotalAmt,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())  
			Insert INTO #TempBackDatedBillGRN(AccountID) Values(@AccountID)   
		End  
	END
	ELSE
	BEGIN
	/* FOR OTHER TAX TYPE*/
	If @nValue <> 0 
	Begin
		If @nValue <> 0  
		Begin  
			/* FLST Tax Type - Tax Amount will be added with Purchase Account*/
			if @TaxType=3
			Begin
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
				Values(@DocumentID,@Purchase,@dBillDate,isnull(@nValue,0)+isnull(@nTaxAmount,0)+isnull(@nVatTaxAmount,0),0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
				Insert INTO #TempBackDatedBillGRN(AccountID) Values(@Purchase)   
			End 
			Else
			Begin
			   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
			   Values(@DocumentID,@Purchase,@dBillDate,@nValue,0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
			   Insert INTO #TempBackDatedBillGRN(AccountID) Values(@Purchase)   
			End
		End  
		/* NON FLST TAX TYPE*/
		if @TaxType <> 3
		Begin
			If @nTaxAmount <> 0  
			Begin  
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
				Values(@DocumentID,@PurchaseTax,@dBillDate,@nTaxAmount,0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
				Insert INTO #TempBackDatedBillGRN(AccountID) Values(@PurchaseTax)   
			End  
	  
			--GST_Changes starts
			if @GSTEnable = 1 
			begin		
				select @gstcount = max(id) from #GSTaxCalc

				if ((isnull(@billabs_StateType,0)>0) and (@gstcount > 0))--GST flag Enabled in Bill abstract
				begin
					select @rowid = 1
					while ( @rowid <= @gstcount)		
					begin
						select	@GSTaxComponent = Tax_Component_Code,
								@nGSTaxAmt		= Tax_Value 
						from	#GSTaxCalc
						where	id = @rowid
						
						if @nGSTaxAmt <> 0    
						begin
							select  @gstreceivable	  = InputAccID 
							from	TaxComponentDetail(nolock) 
							where	TaxComponent_Code = @GSTaxComponent

							--Entry for GS Tax Accounts
							if (isnull(@gstreceivable,0) > 0)
							begin
								Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
 								[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
  								Values(@DocumentID,@gstreceivable,@dBillDate,@nGSTaxAmt,0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
  								Insert INTO #TempBackDatedBillGRN(AccountID) Values(@gstreceivable)
							end
						end
						select @rowid = @rowid+1
					end 
				end 
				else --GST flag Disabled in Bill abstract
				begin
					if (( select isnull(flag,0)
						  from tbl_merp_configabstract(nolock)
						  where screencode = 'UTGST' ) = 1)
					begin
						select	@gstreceivable	= accountid
						from	accountsmaster (nolock)
						where	accountname		= 'UTGST Input'
					end
					else
					begin
						select	@gstreceivable	= accountid
						from	accountsmaster (nolock)
						where	accountname		= 'SGST Input'
					end	
					
					if ((@nVatTaxamount <> 0 ) and (isnull(@gstreceivable,0)>0) and (@TaxType = 1))  
					begin
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
  						Values(@DocumentID,@gstreceivable,@dBillDate,@nVatTaxAmount,0,@nBillID,@nDocType,'VAT Bill',@UniqueID,GetDate())    
  						Insert INTO #TempBackDatedBillGRN(AccountID) Values(@gstreceivable)   
					end
					else if ((@nVatTaxamount <> 0 ) and (@TaxType in (2,3,4)))
					begin
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
  						Values(@DocumentID,@PurchaseTax,@dBillDate,@nVatTaxAmount,0,@nBillID,@nDocType,'VAT Bill',@UniqueID,GetDate())    
  						Insert INTO #TempBackDatedBillGRN(AccountID) Values(@PurchaseTax) 
					end
				end   	
			end
			else   --GST_Changes ends
			If @Vat_Exists=1
			Begin
  				If @nVatTaxAmount <> 0  And (@TaxType = 1 OR  @TaxType = 3 or @TaxType = 4)
  				Begin  
 	 				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
 					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
  					Values(@DocumentID,@VAT_Receivable,@dBillDate,@nVatTaxAmount,0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
  					Insert INTO #TempBackDatedBillGRN(AccountID) Values(@VAT_Receivable)   
		  		End  
				Else If @nVatTaxAmount <> 0 And @TaxType = 2 
				Begin
 	 				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
 					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
  					Values(@DocumentID,@PurchaseTax,@dBillDate,@nVatTaxAmount,0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
  					Insert INTO #TempBackDatedBillGRN(AccountID) Values(@PurchaseTax)   
				End
			End
		End
  
		If @Freight <> 0
		Begin
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
			Values(@DocumentID,@Freight_Account,@dBillDate,@Freight,0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
			Insert INTO #TempBackDatedBillGRN(AccountID) Values(@Freight_Account)   
		End
   
		If @Octroi <> 0
		Begin
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
			Values(@DocumentID,@Octroi_Account,@dBillDate,@Octroi,0,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())    
			Insert INTO #TempBackDatedBillGRN(AccountID) Values(@Octroi_Account)   
		End
  
		If @nTotalAmt <> 0
		Begin   
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
			Values(@DocumentID,@AccountID,@dBillDate,0,@nTotalAmt,@nBillID,@nDocType,'Bill',@UniqueID,GetDate())  
			Insert INTO #TempBackDatedBillGRN(AccountID) Values(@AccountID)   
		End 
	End
END
---------------------------------Discount On Purchase Entries------------------------------- 
If @PurchaseDiscount <> 0
Begin  
	Begin Tran  
	Update DocumentNumbers SET DocumentID=DocumentID+1 Where DocType=24  
	Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24  
	Commit Tran  
   
	Begin Tran  
	Update DocumentNumbers SET DocumentID=DocumentID+1 Where DocType=51  
	Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51  
	Commit Tran  
   
	If Exists(Select * from dbo.SysObjects Where ID = Object_ID(N'[dbo].[BillDiscount]') And OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	Begin
		If (Select Count(*) from BillDiscount Where BillID = @BillID) > 0
 		Set @Disc_NewImpl = 1
	End

	If @Disc_NewImpl = 1
	Begin
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
		Values(@DocumentID,@Purchase,@dBillDate,@PurchaseDiscount,0,@nBillID,@nDocType,'Discount On Purchase',@UniqueID,GetDate())    
		Insert INTO #TempBackDatedBillGRN(AccountID) Values(@Purchase)  
   
		DECLARE ScanBillDiscounts CURSOR KEYSET FOR  
		Select AccountID,Sum(DiscountAmount) from BillDiscount,BillDiscountMaster
		Where BillDiscount.DiscountID=BillDiscountMaster.DiscountID
		And BillDiscount.BillID=@BillID Group By AccountID
		OPEN ScanBillDiscounts  
		FETCH FROM ScanBillDiscounts INTO @Disc_AccID,@Disc_Amt
		WHILE @@FETCH_STATUS=0  
		Begin  
			If @Disc_AccID<>@PurchaseDiscountAccount
			Begin
				SET @Disc_Amt=IsNULL(@Disc_Amt,0)
				SET @TotalDisc_Amt = IsNULL(@TotalDisc_Amt,0)+IsNULL(@Disc_Amt,0)
				If @Disc_Amt <> 0
				Begin
					Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
					Values(@DocumentID,@Disc_AccID,@dBillDate,0,@Disc_Amt,@nBillID,@nDocType,'Discount On Purchase',@UniqueID,GetDate())  
					Insert INTO #TempBackDatedBillGRN(AccountID) Values(@Disc_AccID)  
				End
			End
			FETCH NEXT FROM ScanBillDiscounts INTO @Disc_AccID,@Disc_Amt
		End  
		CLOSE ScanBillDiscounts  
		DEALLOCATE ScanBillDiscounts  
		Set @Disc_Amt = IsNULL(@PurchaseDiscount,0)-IsNULL(@TotalDisc_Amt,0)
		If @Disc_Amt <> 0
		Begin
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
			Values(@DocumentID,@PurchaseDiscountAccount,@dBillDate,0,@Disc_Amt,@nBillID,@nDocType,'Discount On Purchase',@UniqueID,GetDate())  
			Insert INTO #TempBackDatedBillGRN(AccountID) Values(@PurchaseDiscountAccount)  
		End
	End
	Else
	Begin
		--Entry For Purchase Account  
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
		Values(@DocumentID,@Purchase,@dBillDate,@PurchaseDiscount,0,@nBillID,@nDocType,'Discount On Purchase',@UniqueID,GetDate())    
		Insert INTO #TempBackDatedBillGRN(AccountID) Values(@Purchase)  
		--Entry For Discount Account  
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
		Values(@DocumentID,@PurchaseDiscountAccount,@dBillDate,0,@PurchaseDiscount,@nBillID,@nDocType,'Discount On Purchase',@UniqueID,GetDate())  
		Insert INTO #TempBackDatedBillGRN(AccountID) Values(@PurchaseDiscountAccount)  
	End
End  
End  

If @BackDate Is Not NULL    
Begin  
	DECLARE @TempAccountID INT  
	DECLARE ScanTempBackDatedAccounts CURSOR KEYSET FOR  
	Select AccountID From #TempBackDatedBillGRN  
	OPEN ScanTempBackDatedAccounts  
	FETCH FROM ScanTempBackDatedAccounts INTO @TempAccountID  
	WHILE @@FETCH_STATUS=0  
	Begin  
		Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID  
		FETCH NEXT FROM ScanTempBackDatedAccounts INTO @TempAccountID  
	End  
	CLOSE ScanTempBackDatedAccounts  
	DEALLOCATE ScanTempBackDatedAccounts  
End  
Drop Table #TempBackDatedBillGRN 
Drop Table #GSTaxCalc --GST_Changes 
