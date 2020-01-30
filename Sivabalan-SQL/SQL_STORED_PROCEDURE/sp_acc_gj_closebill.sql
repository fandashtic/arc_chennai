CREATE Procedure sp_acc_gj_closebill(@BillID INTEGER,@BackDate DateTime=NULL)        
As        
DECLARE @nBillID INTEGER,@dBillDate DateTime,@nValue Decimal(18,6),@nTaxAmount Decimal(18,6)        
DECLARE @AccountID INTEGER  
DECLARE @DocumentID INTEGER,@nVendorID nVarChar(15),@Purchase INTEGER,@PurchaseTax INTEGER,@nTotalAmt Decimal(18,6),@nDocType INTEGER        
DECLARE @UniqueID INTEGER        
DECLARE @NetAmount Decimal(18,6),@TaxAmount Decimal(18,6),@DiscountComputed Decimal(18,6)        
DECLARE @DiscountOption INTEGER,@OverAllDiscount Decimal(18,6),@OverAllDiscountValue Decimal(18,6)        
DECLARE @AcceptedValue Decimal(18,6)        
DECLARE @TotalPurchase Decimal(18,6)        
DECLARE @TotalTaxAmount Decimal(18,6)        
DECLARE @RejectionValue Decimal(18,6)        
DECLARE @TotalRejectionValue Decimal(18,6)        
DECLARE @TotalNetAmount Decimal(18,6)        
DECLARE @AdjustmentAmount Decimal(18,6)        
DECLARE @GrossAmount Decimal(18,6)        
DECLARE @PurchaseDiscount Decimal(18,6)        
DECLARE @PurchaseDiscountAccount INTEGER        
DECLARE @REJECTIONTYPE INTEGER        
DECLARE @Vat_Exists INTEGER  
DECLARE @VAT_Receivable INTEGER  
DECLARE @nVatTaxamount Decimal(18,6)  
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
  
SET @REJECTIONTYPE=57        
SET @PurchaseDiscountAccount=106        
SET @VAT_Receivable=115 /* Constant to store the VAT Receivable (Input Tax Credit) AccountID*/       
SET @Purchase=6 /* Constant to store Purchase AccountID*/        
SET @PurchaseTax=2 /* Constant to store PurchaseTax AccountID*/            
SET @nDocType=10 /* Constant to store Document Type */              
SET @AccountID=0 /* variable to store AccountID of the Vendor*/             
SET @nTotalAmt=0 /* Variable to store Summed Values [Value]+ [TaxAmount] */            
SET @AdjustmentAmount=0        
SET @Freight_Account=118  
SET @Octroi_Account=113  
SET @Disc_NewImpl=0  
SET @Vat_Exists=0   
SET @TaxType = 1 
        
Execute sp_acc_gj_grnbillcancellation @BillID,@BackDate  
        
CREATE TABLE #TempBackDatedCloseBill(AccountID INT) --for backdated operation  

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
  
If dbo.ColumnExists('BillAbstract','VATTaxAmount')=1  
Begin  
	SET @Vat_Exists=1  
End  
  
If @Vat_Exists=1  
Begin  
	Select @nBillID=[BillID],@dBillDate=[BillDate],@nValue=IsNULL([Value],0),        
	@nTaxAmount=IsNULL([TaxAmount],0)-IsNULL(VATTaxAmount,0),@nVendorID=[VendorID],      
	@DiscountOption=IsNULL(DiscountOption,0),@OverAllDiscount=IsNULL(Discount,0),        
	@AdjustmentAmount=IsNULL(AdjustmentAmount,0),@nVatTaxamount=IsNULL(VATTaxAmount,0),
	@TaxType = IsNULL(TaxType,1),@billabs_StateType = isnull(Statetype,0) --GST_Changes     
	from BillAbstract Where [BillID]=@BillID And Status=192  
End  
Else  
Begin  
	Select @nBillID=[BillID],@dBillDate=[BillDate],@nValue=IsNULL([Value],0),        
	@nTaxAmount=IsNULL([TaxAmount],0),@nVendorID=[VendorID],      
	@DiscountOption=IsNULL(DiscountOption,0),@OverAllDiscount=IsNULL(Discount,0),@billabs_StateType = isnull(Statetype,0), --GST_Changes          
	@AdjustmentAmount=IsNULL(AdjustmentAmount,0) from BillAbstract        
	Where [BillID]=@BillID And Status=192        
End  

--GST_Changes starts here
--GST Enabled 
if @GSTEnable = 1 
begin
	insert into #gstaxcalc 
	(billid , tax_component_code , tax_value		, gst_flag	)
	select 
	billid , tax_component_code , sum(tax_value)	, tx.GSTFlag
	from	billtaxcomponents	bl(nolock)
	join	tax		tx(nolock)
	on(		tx.Tax_Code = bl.Tax_Code
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
        
SET @NetAmount=0        
SET @DiscountComputed=0        
SET @TaxAmount=0        
SET @TotalTaxAmount=0        
SET @TotalPurchase=0         
SET @RejectionValue=0        
SET @TotalRejectionValue=0        
SET @TotalNetAmount=0        
SET @nValue=@nValue+@AdjustmentAmount        
SET @nTotalAmt=@nValue+@nTaxAmount  
  
If @Vat_Exists=1   
Begin  
	SET @nTotalAmt=@nTotalAmt + @nVatTaxamount    
End 
 
SET @nTotalAmt=IsNULL(@nTotalAmt,0)+IsNULL(@Freight,0)+IsNULL(@Octroi,0)  
  
Select @AccountID=IsNULL([AccountID],0) from [Vendors] Where [VendorID]=@nVendorID          

If @AccountID <> 0  
Begin        
	Begin Tran        
	Update DocumentNumbers SET DocumentID=DocumentID + 1 Where DocType=24        
	Select @DocumentID=DocumentID - 1 from DocumentNumbers Where DocType=24        
	Commit Tran        
        
	Begin Tran        
	Update DocumentNumbers SET DocumentID=DocumentID + 1 Where DocType=51        
	Select @UniqueID=DocumentID - 1 from DocumentNumbers Where DocType=51        
	Commit Tran        
	
	/* FOR FMRP */
	If @TaxType=4
	Begin  
		/* FOR FMRP Tax Type */
		If @nTotalAmt <> 0 
		Begin   
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
			Values(@DocumentID,@AccountID,@dBillDate,@nTotalAmt,0,@nBillID,@nDocType,'Bill Cancellation',@UniqueID)          
			Insert Into #TempBackDatedCloseBill(AccountID) Values(@AccountID)         
		END
        
		If @nTotalAmt<> 0
		Begin       
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
			Values(@DocumentID,@Purchase,@dBillDate,0,isnull(@nValue,0)+ case When @Vat_Exists=1 then isnull(@nVatTaxAmount,0) else isnull(@nTaxAmount,0) end,@nBillID,@nDocType,'Bill Cancellation',@UniqueID)          
			Insert Into #TempBackDatedCloseBill(AccountID) Values(@Purchase) 
		End

    
		If @Freight <> 0  
		Begin  
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])    
			Values(@DocumentID,@Freight_Account,@dBillDate,0,@Freight,@nBillID,@nDocType,'Bill Cancellation',@UniqueID,GetDate())      
			Insert INTO #TempBackDatedCloseBill(AccountID) Values(@Freight_Account)     
		End  
     
		If @Octroi <> 0  
		Begin  
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])    
			Values(@DocumentID,@Octroi_Account,@dBillDate,0,@Octroi,@nBillID,@nDocType,'Bill Cancellation',@UniqueID,GetDate())      
			Insert INTO #TempBackDatedCloseBill(AccountID) Values(@Octroi_Account)     
		End  
	End
	ELSE
	BEGIN
		/* FOR OTHERS*/
		If @nTotalAmt <> 0  
		Begin  
			If @nTotalAmt <> 0        
			Begin         
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
				Values(@DocumentID,@AccountID,@dBillDate,@nTotalAmt,0,@nBillID,@nDocType,'Bill Cancellation',@UniqueID)          
				Insert Into #TempBackDatedCloseBill(AccountID) Values(@AccountID)         
			End        
			/* FLST Tax Type*/
			If @TaxType=3  
			Begin
				If @nValue <> 0        
				Begin        
				   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
				   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
				   Values(@DocumentID,@Purchase,@dBillDate,0,isnull(@nValue,0)+case when @Vat_Exists=1 then isnull(@nVatTaxamount,0) else isnull(@nTaxAmount,0) end ,@nBillID,@nDocType,'Bill Cancellation',@UniqueID)          
				   Insert Into #TempBackDatedCloseBill(AccountID) Values(@Purchase)         
				End        	
			End
			Else
			Begin
				If @nValue <> 0        
				Begin        
					Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
					Values(@DocumentID,@Purchase,@dBillDate,0,@nValue,@nBillID,@nDocType,'Bill Cancellation',@UniqueID)          
					Insert Into #TempBackDatedCloseBill(AccountID) Values(@Purchase)         
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
 									[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    								
									Values(@DocumentID,@gstreceivable,@dBillDate,0,@nGSTaxAmt,@nBillID,@nDocType,'Bill Cancellation',@UniqueID)   
  									Insert INTO #TempBackDatedCloseBill(AccountID) Values(@gstreceivable)
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
							[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
  							Values(@DocumentID,@gstreceivable,@dBillDate,0,@nVatTaxAmount,@nBillID,@nDocType,'VAT Bill Cancellation',@UniqueID)   							
  							Insert INTO #TempBackDatedCloseBill(AccountID) Values(@gstreceivable)   
						end
						else if ((@nVatTaxamount <> 0 ) and (@TaxType in (2,3,4)))
						begin
							Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
							[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
  							Values(@DocumentID,@PurchaseTax,@dBillDate,0,@nVatTaxamount,@nBillID,@nDocType,'VAT Bill Cancellation',@UniqueID)    
  							Insert INTO #TempBackDatedCloseBill(AccountID) Values(@PurchaseTax) 
						end
					end   	
				end
				else --GST_Changes ends	
				If @Vat_Exists=1  
				Begin  
					If @nVatTaxAmount <> 0  And @TaxType = 1   
					Begin    
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
						Values(@DocumentID,@VAT_Receivable,@dBillDate,0,@nVatTaxamount,@nBillID,@nDocType,'Bill Cancellation',@UniqueID)         
						Insert Into #TempBackDatedCloseBill(AccountID) Values(@VAT_Receivable)         
					End
					Else If @nVatTaxAmount <> 0 And @TaxType = 2
					Begin
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
						Values(@DocumentID,@PurchaseTax,@dBillDate,0,@nVatTaxamount,@nBillID,@nDocType,'Bill Cancellation',@UniqueID)         
						Insert Into #TempBackDatedCloseBill(AccountID) Values(@PurchaseTax)         
					End     
				End  
				else
				Begin
					If @nTaxAmount <> 0         
					Begin          
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
						Values(@DocumentID,@PurchaseTax,@dBillDate,0,@nTaxAmount,@nBillID,@nDocType,'Bill Cancellation',@UniqueID)         
						Insert Into #TempBackDatedCloseBill(AccountID) Values(@PurchaseTax)         
					End  
				End
			End
	    
			If @Freight <> 0  
			Begin  
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])    
				Values(@DocumentID,@Freight_Account,@dBillDate,0,@Freight,@nBillID,@nDocType,'Bill Cancellation',@UniqueID,GetDate())      
				Insert INTO #TempBackDatedCloseBill(AccountID) Values(@Freight_Account)     
			End  
	     
			If @Octroi <> 0  
			Begin  
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])    
				Values(@DocumentID,@Octroi_Account,@dBillDate,0,@Octroi,@nBillID,@nDocType,'Bill Cancellation',@UniqueID,GetDate())      
				Insert INTO #TempBackDatedCloseBill(AccountID) Values(@Octroi_Account)     
			End  
		End  
	END
	---------------------------------Discount On Purchase Entries-------------------------------        
	If @PurchaseDiscount <> 0  
	Begin        
		Begin Tran        
		Update DocumentNumbers SET DocumentID=DocumentID + 1 Where DocType=24        
		Select @DocumentID=DocumentID - 1 from DocumentNumbers Where DocType=24        
		Commit Tran        
	         
		Begin Tran        
		Update DocumentNumbers SET DocumentID=DocumentID + 1 Where DocType=51        
		Select @UniqueID=DocumentID - 1 from DocumentNumbers Where DocType=51        
		Commit Tran        
	         
		If Exists(Select * from dbo.SysObjects Where ID = Object_ID(N'[dbo].[BillDiscount]') And OBJECTPROPERTY(ID, N'IsUserTable') = 1)  
		Begin  
			If (Select Count(*) from BillDiscount Where BillID = @BillID) > 0  
			Set @Disc_NewImpl = 1  
		End  
	      
		If @Disc_NewImpl = 1  
		Begin  
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
						Values(@DocumentID,@Disc_AccID,@dBillDate,@Disc_Amt,0,@nBillID,@nDocType,'Discount On Purchase - Cancellation',@UniqueID,GetDate())    
						Insert INTO #TempBackDatedCloseBill(AccountID) Values(@Disc_AccID)  
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
				Values(@DocumentID,@PurchaseDiscountAccount,@dBillDate,@Disc_Amt,0,@nBillID,@nDocType,'Discount On Purchase - Cancellation',@UniqueID,GetDate())    
				Insert INTO #TempBackDatedCloseBill(AccountID) Values(@PurchaseDiscountAccount)    
			End  
	  
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])    
			Values(@DocumentID,@Purchase,@dBillDate,0,@PurchaseDiscount,@nBillID,@nDocType,'Discount On Purchase - Cancellation',@UniqueID,GetDate())      
			Insert INTO #TempBackDatedCloseBill(AccountID) Values(@Purchase)    
		End  
		Else  
		Begin  
			--Entry For Purchase Account        
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])        
			Values(@DocumentID,@PurchaseDiscountAccount,@dBillDate,@PurchaseDiscount,0,@nBillID,@nDocType,'Discount On Purchase - Cancellation',@UniqueID,getdate())          
			Insert Into #TempBackDatedCloseBill(AccountID) Values(@Purchase)        
			--Entry For Discount Account        
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])        
			Values(@DocumentID,@Purchase,@dBillDate,0,@PurchaseDiscount,@nBillID,@nDocType,'Discount On Purchase - Cancellation',@UniqueID,getdate())        
			Insert Into #TempBackDatedCloseBill(AccountID) Values(@PurchaseDiscountAccount)        
		End  
	 End        
	------------------------Credit/Debit Note cancellation journal entries-----------------------                
	DECLARE @ReferenceID Int,@Type Int                
	If Exists(Select ReferenceID From AdjustmentReference Where InvoiceID=@BillID And IsNULL(TransactionType,0)=1)                
	Begin                
		DECLARE scanadjustmentreference CURSOR KEYSET FOR                
		Select ReferenceID, DocumentType from AdjustmentReference Where InvoiceID=@BillID And IsNULL(TransactionType,0)=1      
		OPEN scanadjustmentreference                
		FETCH FROM scanadjustmentreference INTO @ReferenceID,@Type                
		WHILE @@FETCH_STATUS=0                
		Begin                
			If @Type=2 -- Debit Note                
			Begin                
				Exec sp_acc_gj_debitnoteCancel @ReferenceID,@BackDate  
			End                
			Else If @Type=5 -- Credit Note                
			Begin                
				Exec sp_acc_gj_creditnoteCancel @ReferenceID,@BackDate  
			End                
			FETCH NEXT FROM scanadjustmentreference INTO @ReferenceID,@Type                
		End                
		CLOSE scanadjustmentreference                
		DEALLOCATE scanadjustmentreference                
	End             
End        

If @BackDate Is Not NULL          
Begin        
	DECLARE @TempAccountID Int        
	DECLARE ScanTempBackDatedAccounts CURSOR KEYSET FOR        
	Select AccountID From #TempBackDatedCloseBill        
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
Drop Table #TempBackDatedCloseBill   
Drop Table #GSTaxCalc --GST_Changes 
