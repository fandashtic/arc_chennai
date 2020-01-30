CREATE Procedure sp_acc_gj_billamendment(@BillID Integer,@BackDate DateTime=NULL)          
As          
DECLARE @nBillID Integer,@dBillDate DateTime,@nValue Decimal(18,6),@nTaxAmount Decimal(18,6)          
DECLARE @AccountID Integer          
DECLARE @DocumentID Integer,@nVendorID nvarchar(15),@Purchase Integer,@PurchaseTax Integer,@nTotalAmt Decimal(18,6),@nDocType Integer          
DECLARE @ReferenceID Integer,@RefBillID Integer,@RefdBillDate DateTime,@RefValue Decimal(18,6),@RefTaxAmount Decimal(18,6),@RefTotalAmt Decimal(18,6)          
DECLARE @UniqueID Integer          
DECLARE @NetAmount Decimal(18,6),@TaxAmount Decimal(18,6),@DiscountComputed Decimal(18,6)          
DECLARE @DiscountOption Integer,@OverAllDiscount Decimal(18,6),@OverAllDiscountValue Decimal(18,6)          
DECLARE @AcceptedValue Decimal(18,6)          
DECLARE @TotalPurchase Decimal(18,6)          
DECLARE @TotalTaxAmount Decimal(18,6)          
DECLARE @RejectionValue Decimal(18,6)          
DECLARE @TotalRejectionValue Decimal(18,6)          
DECLARE @TotalNetAmount Decimal(18,6)          
DECLARE @REJECTIONTYPE_AMENDED Integer          
DECLARE @REJECTIONTYPE_AMENDMENT Integer          
DECLARE @AdjustedAmount Decimal(18,6)          
DECLARE @AmendedAdjustedAmount Decimal(18,6)          
DECLARE @GrossAmount Decimal(18,6)          
DECLARE @PurchaseDiscount Decimal(18,6)          
DECLARE @AmendedGrossAmount Decimal(18,6)          
DECLARE @AmendedPurchaseDiscount Decimal(18,6)          
DECLARE @PurchaseDiscountAccount Integer          
DECLARE @Vat_Exists Integer    
DECLARE @VAT_Receivable Integer    
DECLARE @nVatTaxamount Decimal(18,6)    
DECLARE @VatRefTaxAmount Decimal(18,6)    
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
DECLARE @Amended_Freight Decimal(18,6)    
DECLARE @Amended_Octroi Decimal(18,6)    
DECLARE @Amended_Prod_Disc Decimal(18,6)    
DECLARE @Amended_Trade_Disc Decimal(18,6)    
DECLARE @Amended_Addl_Disc Decimal(18,6)    
DECLARE @TAX_TYPE Int   
    
SET @PurchaseDiscountAccount=106    
SET @VAT_Receivable=115  /* Constant to store the VAT Receivable (Input Tax Credit) AccountID*/    
SET @REJECTIONTYPE_AMENDED=58          
SET @REJECTIONTYPE_AMENDMENT=59          
SET @nDocType=9 /* Constant to store the Document Type*/          
SET @AccountID=0 /* Variable to store the Vendors AccountID*/          
SET @Purchase=6 /* Constant to store the Purchase AccountID*/          
SET @PurchaseTax=2 /* Constant to store the PurchaseTax AccountID*/          
SET @nTotalAmt=0 /* variable to store the Summedup values [Value + TaxAmount]*/          
SET @RefValue=0  /* variable to store the Amended Bill Value*/          
SET @RefTaxAmount=0 /* variable to store the Amended Bill TaxAmount*/             
SET @RefTotalAmt=0 /* variable to store the summedup value of [Value + TaxAmount]*/          
SET @VatRefTaxAmount=0    
SET @AdjustedAmount=0           
SET @AmendedAdjustedAmount=0          
SET @Freight_Account=118    
SET @Octroi_Account=113    
SET @Disc_NewImpl=0    
SET @Vat_Exists=0    
SET @TAX_TYPE = 1   
          
CREATE TABLE #TempBackDatedBillAmendment(AccountID Int) --for backdated operation    

--GST_Changes starts here
Declare @GSTEnable int,
		@GSTCount int , 
		@Rowid int, 
		@GSTReceivable int, 
		@GSTaxComponent int ,
		@nGSTaxAmt decimal(18,6),
		@billabs_StateType	int			

Select @GSTEnable = isnull(flag,0) 
From tbl_merp_configabstract(nolock)
Where screencode = 'GSTaxEnabled'  

Create Table #GSTaxCalc  --For GS Tax Calculation Amendment
(	id int identity(1,1), 
	billid int,
	tax_component_code int, 
	tax_value decimal(18,6),
	gst_flag  int
)

Create Table #GSTaxCalcAmend  --For GS Tax Calculation Amended
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
	@nTaxAmount=IsNULL([TaxAmount],0) - IsNULL(VATTaxAmount,0),@nVendorID=IsNULL([VendorID],0),     
	@ReferenceID=IsNULL([BillReference],0),    
	@DiscountOption=IsNULL(DiscountOption,0),@OverAllDiscount=IsNULL(Discount,0),@billabs_StateType = isnull(GSTFlag,0), --GST_Changes    
	@AdjustedAmount=IsNULL(AdjustmentAmount,0),@nVatTaxamount=IsNULL(VATTaxAmount,0), @Tax_Type = IsNull(TaxType,1)    
	from BillAbstract Where [BillID]=@BillID           
End    
Else    
Begin    
	Select @nBillID=[BillID],@dBillDate=[BillDate],@nValue=IsNULL([Value],0),          
	@nTaxAmount=IsNULL([TaxAmount],0),@nVendorID=IsNULL([VendorID],0),          
	@ReferenceID=IsNULL([BillReference],0),          
	@DiscountOption=IsNULL(DiscountOption,0),@OverAllDiscount=IsNULL(Discount,0),@billabs_StateType = isnull(GSTFlag,0), --GST_Changes          
	@AdjustedAmount=IsNULL(AdjustmentAmount,0) from BillAbstract Where [BillID]=@BillID    
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

	insert into #GSTaxCalcAmend
	(billid , tax_component_code , tax_value		, gst_flag	)
	select 
	billid , tax_component_code , sum(tax_value)	, tx.GSTFlag
	from	billtaxcomponents	bl(nolock)
	join	tax		tx(nolock)
	on(		tx.Tax_Code = bl.Tax_Code
	and		isnull(tx.GSTFlag,0)= 1		
	)
	where billid = @ReferenceID
	group by tax_component_code,billid,tx.GSTFlag
end  
--GST_Changes ends here
          
Select @GrossAmount=Sum(Quantity * PurchasePrice) from BillDetail Where BillID=@BillID    
Select @Prod_Disc=IsNULL(ProductDiscount,0),@Addl_Disc=IsNULL(AddlDiscountAmount,0),    
@Freight=IsNULL(Freight,0),@Octroi=IsNULL(OctroiAmount,0) from BillAbstract Where [BillID]=@BillID    
    
SET @nValue=IsNULL(@nValue,0)-IsNULL(@Freight,0)-IsNULL(@Octroi,0)    
SET @PurchaseDiscount=IsNULL(@GrossAmount,0) - IsNULL(@nValue,0)    
SET @PurchaseDiscount=IsNULL(@PurchaseDiscount,0)    
SET @nValue=@nValue + @AdjustedAmount    
SET @nTotalAmt=@nValue + @nTaxAmount    
    
If @Vat_Exists=1     
Begin    
	SET @nTotalAmt=@nTotalAmt + @nVatTaxamount    
End 
   
SET @nTotalAmt=IsNULL(@nTotalAmt,0)+IsNULL(@Freight,0)+IsNULL(@Octroi,0)    
Select @AccountID=IsNULL([AccountID],0) from [Vendors] Where [VendorID]=@nVendorID    
          
If @Vat_Exists=1    
Begin    
	Select @RefBillID=[BillID],@RefdBillDate=[BillDate],@RefValue=IsNULL([Value],0),    
	@RefTaxAmount=IsNULL([TaxAmount],0)-IsNULL(VATTaxAmount,0),@AmendedAdjustedAmount=IsNULL(AdjustmentAmount,0),    
	@VatRefTaxAmount=IsNULL(VATTaxAmount,0) from BillAbstract Where [BillID]=@ReferenceID And [Status]=128    
End    
Else    
Begin    
	Select @RefBillID=[BillID],@RefdBillDate=[BillDate],@RefValue=IsNULL([Value],0),@RefTaxAmount=IsNULL([TaxAmount],0),     
	@AmendedAdjustedAmount=IsNULL(AdjustmentAmount,0) from BillAbstract Where [BillID]=@ReferenceID And [Status]=128    
End    
          
Select @AmendedGrossAmount=Sum(Quantity * PurchasePrice) from BillDetail Where BillID=@ReferenceID    
Select @Amended_Prod_Disc=IsNULL(ProductDiscount,0),@Amended_Addl_Disc=IsNULL(AddlDiscountAmount,0),    
@Amended_Freight=IsNULL(Freight,0),@Amended_Octroi=IsNULL(OctroiAmount,0) from BillAbstract Where [BillID]=@ReferenceID    
    
SET @RefValue=IsNULL(@RefValue,0)-IsNULL(@Amended_Freight,0)-IsNULL(@Amended_Octroi,0)    
SET @AmendedPurchaseDiscount=IsNULL(@AmendedGrossAmount,0) - IsNULL(@RefValue,0)    
SET @AmendedPurchaseDiscount=IsNULL(@AmendedPurchaseDiscount,0)    
SET @RefValue=@RefValue + @AmendedAdjustedAmount    
SET @RefTotalAmt=@RefValue + @RefTaxAmount    
    
If @Vat_Exists=1     
Begin    
	SET @RefTotalAmt=@RefTotalAmt + @VatRefTaxAmount    
End 
   
SET @RefTotalAmt=IsNULL(@RefTotalAmt,0)+IsNULL(@Amended_Freight,0)+IsNULL(@Amended_Octroi,0)    
    
SET @NetAmount=0          
SET @DiscountComputed=0          
SET @TaxAmount=0          
SET @TotalTaxAmount=0          
SET @TotalPurchase=0           
SET @RejectionValue=0          
SET @TotalRejectionValue=0          
SET @TotalNetAmount=0          
          
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

	/* FOR FMRP Tax Type*/  
	if @TAX_TYPE = 4  
	BEGIN  
 
		If isnull(@RefTotalAmt,0) <> 0
		Begin   
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
			Values(@DocumentID,@AccountID,@RefdBillDate,@RefTotalAmt,0,@RefBillID,@nDocType,'Bill Amended',@UniqueID,getdate())            
			Insert Into #TempBackDatedBillAmendment(AccountID) Values(@AccountID)          
		End     
		
		If isnull(@VatRefTaxAmount,0) <> 0 or isnull(@RefValue,0) <> 0  or isnull(@RefTaxAmount,0) <> 0
		Begin   
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
			Values(@DocumentID,@Purchase,@RefdBillDate,0,isnull(@RefValue,0)+case @Vat_Exists when 1 then isnull(@VatRefTaxAmount,0) else isnull(@RefTaxAmount,0) end,@RefBillID,@nDocType,'Bill Amended',@UniqueID,getdate())            
			Insert Into #TempBackDatedBillAmendment(AccountID) Values(@Purchase)           
		End     
      
		If @Amended_Freight <> 0    
		Begin    
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],      
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])      
			Values(@DocumentID,@Freight_Account,@RefdBillDate,0,@Amended_Freight,@RefBillID,@nDocType,'Bill Amended',@UniqueID,GetDate())        
			Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Freight_Account)       
		End    
       
		If @Amended_Octroi <> 0    
		Begin    
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],      
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])      
			Values(@DocumentID,@Octroi_Account,@RefdBillDate,0,@Amended_Octroi,@RefBillID,@nDocType,'Bill Amended',@UniqueID,GetDate())        
			Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Octroi_Account)       
		End    
	END  
	ELSE  
	/* For other Types*/  
	BEGIN  
	If @RefTotalAmt <> 0     
	Begin    
		If @RefTotalAmt <> 0           
		Begin          
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
			Values(@DocumentID,@AccountID,@RefdBillDate,@RefTotalAmt,0,@RefBillID,@nDocType,'Bill Amended',@UniqueID,getdate())            
			Insert Into #TempBackDatedBillAmendment(AccountID) Values(@AccountID)          
		End          
		/* FOR FLST Tax Type*/
        if @TAX_TYPE = 3
		Begin
			If @RefValue <> 0         
			Begin       
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
				Values(@DocumentID,@Purchase,@RefdBillDate,0,isnull(@RefValue,0)+ case @Vat_Exists When 1 then isnull(@VatRefTaxAmount,0) else isnull(@RefTaxAmount,0) end,@RefBillID,@nDocType,'Bill Amended',@UniqueID,getdate())            
				Insert Into #TempBackDatedBillAmendment(AccountID) Values(@Purchase)           
			End          
		End
		Else
		/* FOR NON FLST Tax Type*/
		Begin
			If @RefValue <> 0          
			Begin          
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
				Values(@DocumentID,@Purchase,@RefdBillDate,0,@RefValue,@RefBillID,@nDocType,'Bill Amended',@UniqueID,getdate())            
				Insert Into #TempBackDatedBillAmendment(AccountID) Values(@Purchase)           
			End          
		
			If @RefTaxAmount <> 0          
			Begin          
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
				Values(@DocumentID,@PurchaseTax,@RefdBillDate,0,@RefTaxAmount,@RefBillID,@nDocType,'Bill Amended',@UniqueID,getdate())            
				Insert Into #TempBackDatedBillAmendment(AccountID) Values(@PurchaseTax)          
			End       
		
			--GST_Changes starts
			if @GSTEnable = 1 
			begin		
				select @gstcount = max(id) from #GSTaxCalcAmend
				
				if ((isnull(@billabs_StateType,0)>0) and (@gstcount > 0))--GST flag Enabled in Bill abstract
				begin
					select @rowid = 1
					while ( @rowid <= @gstcount)		
					begin
						select	@GSTaxComponent = Tax_Component_Code,
								@nGSTaxAmt		= Tax_Value 
						from	#GSTaxCalcAmend
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
								Values(@DocumentID,@gstreceivable,@RefdBillDate,0,@nGSTaxAmt,@RefBillID,@nDocType,'Bill Amended',@UniqueID,getdate())            
  								Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@gstreceivable)
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
					
					if ((@VatRefTaxAmount <> 0 ) and (isnull(@gstreceivable,0)>0) and (@Tax_Type=1))  
					begin
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])    						
						Values(@DocumentID,@gstreceivable,@RefdBillDate,0,@VatRefTaxAmount,@RefBillID,@nDocType,'VAT Bill Amended',@UniqueID,getdate())            
  						Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@gstreceivable)   
					end
					else if ((@VatRefTaxAmount <> 0 ) and (@Tax_Type in (2,3,4)))
					begin
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
  						Values(@DocumentID,@PurchaseTax,@RefdBillDate,0,@VatRefTaxAmount,@RefBillID,@nDocType,'VAT Bill Amended',@UniqueID,GetDate())    
  						Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@PurchaseTax) 
					end
				end   	
			end
			else   --GST_Changes ends
			If @Vat_Exists=1    
			Begin    
				If @VatRefTaxAmount <> 0  and (@TAX_TYPE = 1)  
				Begin      
					Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
					Values(@DocumentID,@VAT_Receivable,@RefdBillDate,0,@VatRefTaxAmount,@RefBillID,@nDocType,'Bill Amended',@UniqueID,getdate())            
					Insert Into #TempBackDatedBillAmendment(AccountID) Values(@VAT_Receivable)           
				End      
				Else If @VatRefTaxAmount <> 0  and (@TAX_TYPE = 2)  
				Begin      
					Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
					Values(@DocumentID,@PurchaseTax,@RefdBillDate,0,@VatRefTaxAmount,@RefBillID,@nDocType,'Bill Amended',@UniqueID,getdate())            
					Insert Into #TempBackDatedBillAmendment(AccountID) Values(@PurchaseTax)           
				End   
			End    
		End
		If @Amended_Freight <> 0    
		Begin    
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],      
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])      
			Values(@DocumentID,@Freight_Account,@RefdBillDate,0,@Amended_Freight,@RefBillID,@nDocType,'Bill Amended',@UniqueID,GetDate())        
			Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Freight_Account)       
		End    
       
		If @Amended_Octroi <> 0    
		Begin    
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],      
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])      
			Values(@DocumentID,@Octroi_Account,@RefdBillDate,0,@Amended_Octroi,@RefBillID,@nDocType,'Bill Amended',@UniqueID,GetDate())        
			Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Octroi_Account)       
		End    
	End  
 End       
---------------------Reversal Entries for Discount On Purchase ------------------------------          
If @AmendedPurchaseDiscount <> 0         
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
		If (Select Count(*) from BillDiscount Where BillID = @ReferenceID) > 0    
		Set @Disc_NewImpl = 1    
	End    
      
	If @Disc_NewImpl = 1    
	Begin    
		DECLARE ScanBillDiscounts CURSOR KEYSET FOR      
		Select AccountID,Sum(DiscountAmount) from BillDiscount,BillDiscountMaster    
		Where BillDiscount.DiscountID=BillDiscountMaster.DiscountID    
		And BillDiscount.BillID=@ReferenceID Group By AccountID    
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
					Values(@DocumentID,@Disc_AccID,@RefdBillDate,@Disc_Amt,0,@RefBillID,@nDocType,'Discount On Purchase - Amended',@UniqueID,GetDate())      
					Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Disc_AccID)      
				End    
			End    
			FETCH NEXT FROM ScanBillDiscounts INTO @Disc_AccID,@Disc_Amt    
		End      
		CLOSE ScanBillDiscounts      
		DEALLOCATE ScanBillDiscounts      
		Set @Disc_Amt = IsNULL(@AmendedPurchaseDiscount,0)-IsNULL(@TotalDisc_Amt,0)    
		If @Disc_Amt <> 0    
		Begin    
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],      
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])      
			Values(@DocumentID,@PurchaseDiscountAccount,@RefdBillDate,@Disc_Amt,0,@RefBillID,@nDocType,'Discount On Purchase - Amended',@UniqueID,GetDate())      
			Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@PurchaseDiscountAccount)      
		End    

		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],      
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])      
		Values(@DocumentID,@Purchase,@RefdBillDate,0,@AmendedPurchaseDiscount,@RefBillID,@nDocType,'Discount On Purchase - Amended',@UniqueID,GetDate())        
		Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Purchase)      
	End    
	Else    
	Begin    
		--Entry For Discount Account          
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
		Values(@DocumentID,@PurchaseDiscountAccount,@RefdBillDate,@AmendedPurchaseDiscount,0,@RefBillID,@nDocType,'Discount On Purchase - Amended',@UniqueID,getdate())            
		Insert Into #TempBackDatedBillAmendment(AccountID) Values(@PurchaseDiscountAccount)          
		--Entry For Purchase Account          
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
		Values(@DocumentID,@Purchase,@RefdBillDate,0,@AmendedPurchaseDiscount,@RefBillID,@nDocType,'Discount On Purchase - Amended',@UniqueID,getdate())          
		Insert Into #TempBackDatedBillAmendment(AccountID) Values(@Purchase)     
	End    
End        
------------------------Credit/Debit Note cancellation journal entries-----------------------                  
DECLARE @AdjReferenceID Int,@Type Int                  
If exists(Select ReferenceID From AdjustmentReference Where InvoiceID=@ReferenceID And IsNULL(TransactionType,0)=1)                  
Begin                  
	DECLARE scanadjustmentreference CURSOR KEYSET FOR                  
	Select ReferenceID, DocumentType from AdjustmentReference Where InvoiceID=@ReferenceID And IsNULL(TransactionType,0)=1          OPEN scanadjustmentreference                  
	FETCH FROM scanadjustmentreference INTO @AdjReferenceID,@Type                  
	WHILE @@FETCH_STATUS=0                  
	Begin                  
		If @Type=2 -- Debit Note                  
		Begin                  
			Exec sp_acc_gj_debitnoteCancel @AdjReferenceID,@BackDate    
		End                  
		Else If @Type=5 -- Credit Note                  
		Begin                  
			Exec sp_acc_gj_creditnoteCancel @AdjReferenceID,@BackDate    
		End                  
		FETCH NEXT FROM scanadjustmentreference INTO @AdjReferenceID,@Type                  
	End                  
	CLOSE scanadjustmentreference                  
	DEALLOCATE scanadjustmentreference                  
End               
--------------------------------------Amendment Entries--------------------------------------    
 SET @NetAmount=0          
 SET @DiscountComputed=0          
 SET @TaxAmount=0          
 SET @TotalTaxAmount=0          
 SET @TotalPurchase=0           
 SET @RejectionValue=0          
 SET @TotalRejectionValue=0          
 SET @TotalNetAmount=0          
 SET @Disc_NewImpl=0    
 SET @Disc_Amt=0    
 SET @TotalDisc_Amt=0    
 SET @Disc_AccID=0    
     
Begin Tran          
Update DocumentNumbers SET DocumentID=DocumentID + 1 Where DocType=24          
Select @DocumentID=DocumentID - 1 from DocumentNumbers Where DocType=24          
Commit Tran          
          
Begin Tran          
Update DocumentNumbers SET DocumentID=DocumentID + 1 Where DocType=51          
Select @UniqueID=DocumentID - 1 from DocumentNumbers Where DocType=51          
Commit Tran          

/* FOR FMRP Tax Type*/  
if @TAX_TYPE = 4  
BEGIN      
	if isnull(@nValue,0) <> 0 or isnull(@nTaxAmount,0) <> 0 or isnull(@nVatTaxamount,0)<>0
	Begin
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
		Values(@DocumentID,@Purchase,@dBillDate,isnull(@nValue,0)+ case @Vat_Exists When 1 then isnull(@nVatTaxamount,0)else isnull(@nTaxAmount,0) End,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,getdate())            
		Insert Into #TempBackDatedBillAmendment(AccountID) Values(@Purchase)             
	End                    
	If @Freight <> 0    
	Begin    
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],      
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])      
		Values(@DocumentID,@Freight_Account,@dBillDate,@Freight,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,GetDate())        
		Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Freight_Account)       
	End    
       
	If @Octroi <> 0    
	Begin    
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],      
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])      
		Values(@DocumentID,@Octroi_Account,@dBillDate,@Octroi,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,GetDate())        
		Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Octroi_Account)       
	End    
        
	If @nTotalAmt <> 0   
	Begin         
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
		Values(@DocumentID,@AccountID,@dBillDate,0,@nTotalAmt,@nBillID,@nDocType,'Bill Amendment',@UniqueID,getdate())          
		Insert Into #TempBackDatedBillAmendment(AccountID) Values(@AccountID)           
	End  
 END  
/* FOR OTHER TYPES */  
ELSE  
BEGIN      
	If @nValue <> 0     
	Begin    
		/* FOR FLST TAX TYPE*/
		If @TAX_TYPE=3 
		BEGIN
			
			If @nValue <> 0          
			Begin          

			   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
			   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
			   Values(@DocumentID,@Purchase,@dBillDate,isnull(@nValue,0)+case @Vat_Exists When 1 then isnull(@nVatTaxamount,0) else isnull(@nTaxAmount,0) End,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,getdate())            
			   Insert Into #TempBackDatedBillAmendment(AccountID) Values(@Purchase)           
			End   
		END
		ELSE
		/* FOR NON FLST TAX TYPE*/
		BEGIN
			If @nValue <> 0          
			Begin          
			   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
			   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
			   Values(@DocumentID,@Purchase,@dBillDate,@nValue,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,getdate())            
			   Insert Into #TempBackDatedBillAmendment(AccountID) Values(@Purchase)           
			End          
			If @Vat_Exists=0
			Begin	           
				If @nTaxAmount <> 0          
				Begin      
					Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
					Values(@DocumentID,@PurchaseTax,@dBillDate,@nTaxAmount,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,getdate())            
					Insert Into #TempBackDatedBillAmendment(AccountID) Values(@PurchaseTax)           
				End          
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
  								Values(@DocumentID,@gstreceivable,@dBillDate,@nGSTaxAmt,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,GetDate())    
  								Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@gstreceivable)
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
					
					if ((@nVatTaxamount <> 0 ) and (isnull(@gstreceivable,0)>0) and (@Tax_Type = 1))  
					begin
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
  						Values(@DocumentID,@gstreceivable,@dBillDate,@nVatTaxAmount,0,@nBillID,@nDocType,'VAT Bill Amendment',@UniqueID,GetDate())    
  						Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@gstreceivable)   
					end
					else if ((@nVatTaxamount <> 0 ) and (@Tax_Type in (2,3,4)))
					begin
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
  						Values(@DocumentID,@PurchaseTax,@dBillDate,@nVatTaxamount,0,@nBillID,@nDocType,'VAT Bill Amendment',@UniqueID,GetDate())    
  						Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@PurchaseTax) 
					end
				end   	
			end
			else   --GST_Changes ends
			If @Vat_Exists=1    
			Begin    
				If @nVatTaxamount <> 0  and (@TAX_TYPE = 1)  
				Begin      
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
				Values(@DocumentID,@VAT_Receivable,@dBillDate,@nVatTaxamount,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,getdate())            
				Insert Into #TempBackDatedBillAmendment(AccountID) Values(@VAT_Receivable)  
			End      
			Else
			Begin
				If @nVatTaxamount <> 0  and @TAX_TYPE = 2  
				Begin      
					Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
					Values(@DocumentID,@PurchaseTax,@dBillDate,@nVatTaxamount,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,getdate())            
					Insert Into #TempBackDatedBillAmendment(AccountID) Values(@PurchaseTax)           
				End 
				else If @nTaxamount <> 0  and @TAX_TYPE = 1
				Begin
					Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
					Values(@DocumentID,@PurchaseTax,@dBillDate,@nTaxamount,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,getdate())            
					Insert Into #TempBackDatedBillAmendment(AccountID) Values(@PurchaseTax)           	
				End
		    End
		END
	End    
      
	If @Freight <> 0    
	Begin    
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],      
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])      
		Values(@DocumentID,@Freight_Account,@dBillDate,@Freight,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,GetDate())        
		Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Freight_Account)       
	End    
	   
	If @Octroi <> 0    
	Begin    
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],      
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])      
		Values(@DocumentID,@Octroi_Account,@dBillDate,@Octroi,0,@nBillID,@nDocType,'Bill Amendment',@UniqueID,GetDate())        
		Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Octroi_Account)       
	End    
	  
	If @nTotalAmt <> 0          
	Begin          
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
		Values(@DocumentID,@AccountID,@dBillDate,0,@nTotalAmt,@nBillID,@nDocType,'Bill Amendment',@UniqueID,getdate())          
		Insert Into #TempBackDatedBillAmendment(AccountID) Values(@AccountID)           
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
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],      
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])      
		Values(@DocumentID,@Purchase,@dBillDate,@PurchaseDiscount,0,@nBillID,@nDocType,'Discount On Purchase - Amendment',@UniqueID,GetDate())        
		Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Purchase)      
		   
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
					  Values(@DocumentID,@Disc_AccID,@dBillDate,0,@Disc_Amt,@nBillID,@nDocType,'Discount On Purchase - Amendment',@UniqueID,GetDate())      
					  Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@Disc_AccID)      
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
			Values(@DocumentID,@PurchaseDiscountAccount,@dBillDate,0,@Disc_Amt,@nBillID,@nDocType,'Discount On Purchase - Amendment',@UniqueID,GetDate())      
			Insert INTO #TempBackDatedBillAmendment(AccountID) Values(@PurchaseDiscountAccount)      
		End    
	End    
	Else    
	Begin    
		--Entry For Purchase Account          
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
		Values(@DocumentID,@Purchase,@dBillDate,@PurchaseDiscount,0,@nBillID,@nDocType,'Discount On Purchase - Amendment',@UniqueID,getdate())            
		Insert Into #TempBackDatedBillAmendment(AccountID) Values(@Purchase)          
		--Entry For Discount Account          
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])          
		Values(@DocumentID,@PurchaseDiscountAccount,@dBillDate,0,@PurchaseDiscount,@nBillID,@nDocType,'Discount On Purchase - Amendment',@UniqueID,getdate())          
		Insert Into #TempBackDatedBillAmendment(AccountID) Values(@PurchaseDiscountAccount)          
	End    
 End          
End    
     
If @BackDate Is Not NULL            
Begin          
	DECLARE @TempAccountID Int          
	DECLARE ScanTempBackDatedAccounts CURSOR KEYSET FOR          
	Select AccountID From #TempBackDatedBillAmendment          
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
Drop Table #TempBackDatedBillAmendment     
Drop Table #GSTaxCalc --GST_Changes
Drop Table #GSTaxCalcAmend --GST_Changes
