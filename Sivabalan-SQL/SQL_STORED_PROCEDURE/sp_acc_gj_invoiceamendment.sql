CREATE Procedure sp_acc_gj_invoiceamendment(@INVOICEID INT,@BackDate DATETIME=Null,@CANCEL Int=0)                        
AS -- Journal entries for Invoice Amendment                          
Declare @SalesValue float                        
Declare @InvoiceDate datetime                        
Declare @NetValue float                        
Declare @TaxAmount float                        
Declare @TotalSalesTax float                        
Declare @TotalTaxSuffered float                        
Declare @AccountID int                        
Declare @CustomerID nvarchar(15)                        
Declare @TransactionID int                        
Declare @PaymentMode int                        
Declare @InvRefNum int                        
Declare @CollectionID int                        
Declare @DocumentNumber Int                        
Declare @Freight float                        
Declare @RoundOffAmount Decimal(18,6)                        
Declare @NetBalance Decimal(18,6)                        
Declare @PaymentDetails Int                        
Declare @ColValue Decimal(18,6)                        
Declare @Status Int                      
                      
Declare @TradeDiscount Decimal(18,6)                      
Declare @AdditionalDiscount Decimal(18,6)                      
Declare @ItemDiscount Decimal(18,6)                      
Declare @TotalDiscount Decimal(18,6)                      
Declare @InvSchemeDiscountAmount Decimal(18,6)                    
Declare @ItmSchemeDiscountAmount Decimal(18,6)                    
                      
Declare @AccountID1 int                        
Declare @AccountID2 int                        
Declare @AccountID3 int                        
Declare @AccountID4 int                        
Declare @AccountID5 int                        
Declare @AccountID6 int                        
Set @AccountID1 = 3  --Cash Account                        
Set @AccountID2 = 1  --SalesTax Account                        
Set @AccountID3 = 5  --Sales Account                        
Set @AccountID4 = 7  --Cheque on Hand                        
Set @AccountID5 = 29 --Tax Suffered Account                        
Set @AccountID6 = 33 --Freight Account                        
Declare @AccountType Int                        
Declare @CollectionType Int                        
Declare @DispatchType int                      
Declare @DispatchCancelType int                      
Declare @CollectionCancelType Int                        
Set @AccountType =5                        
Set @CollectionType =13                        
set @DispatchType =44                      
set @DispatchCancelType =45                      
set @CollectionCancelType=25                      
--RoundOff Amount                        
Declare @RoundOffAccount Int                        
Set @RoundOffAccount=92                        
                      
--PaymentMode Types                        
Declare @CASH int                        
Declare @CHEQUE int                        
Declare @CREDIT int                        
Declare @DD int                        
--                         
Set @CASH =1                        
SET @CHEQUE=2                        
SET @CREDIT=0                        
SET @DD=3                        
--                      
Declare @Vat_Exists Integer  
Declare @VAT_Payable Integer  
Declare @nVatTaxamount decimal(18,6)  
Set @VAT_Payable  = 116  /* Constant to store the VAT Payable (Output Tax) AccountID*/       
Set @Vat_Exists = 0   
If dbo.columnexists('InvoiceAbstract','VATTaxAmount') = 1  
Begin  
 Set @Vat_Exists = 1  
end  
  
Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation     

--GST_Changes starts here
Declare @GSTEnable int,		
		@GSTCount int , 
		@Rowid int, 
		@GST_Payable int, 
		@GSTaxComponent int ,
		@nGSTaxAmt decimal(18,6),
		@invabs_gstflag int				

Select @GSTEnable = isnull(flag,0) 
From tbl_merp_configabstract(nolock)
Where screencode = 'GSTaxEnabled' 

Create Table #GSTaxCalc  --For GS Tax Calculation Amendment
(	id int identity(1,1), 
	invoiceid int,
	tax_component_code int, 
	tax_value decimal(18,6),
	gst_flag  int
)

Create Table #GSTaxCalcAmend --For GS Tax Calculation Amended
(	id int identity(1,1), 
	invoiceid int,
	tax_component_code int, 
	tax_value decimal(18,6),
	gst_flag  int
)
--GST_Changes ends here               
                         
Select @TotalTaxSuffered=TotalTaxSuffered From InvoiceAbstract Where InvoiceID = @InvoiceID                        
                        
Select @ItmSchemeDiscountAmount = Sum(IsNull(SchemeDiscAmount,0) + IsNull(SplCatDiscAmount,0)) from InvoiceDetail Where InvoiceID = @InvoiceID                    
If @Vat_Exists  = 1  
Begin  
 Select @InvoiceDate=InvoiceDate, @NetValue=NetValue,                         
 @TotalSalesTax=IsNull(TotalTaxApplicable,0) - isnull(VATTaxAmount,0),
 @TotalTaxSuffered=IsNull(TotalTaxSuffered,0),                         
 @TradeDiscount = isnull(DiscountValue,0),                      
 @AdditionalDiscount = isnull(AddlDiscountValue,0),                      
 @ItemDiscount = isnull(ProductDiscount,0),                      
 @CustomerID=CustomerID,                        
 @PaymentMode=PaymentMode,                         
 @InvRefNum=InvoiceReference,                        
 @CollectionID=cast(PaymentDetails as Int),     
 @Freight=isnull(Freight,0),                        
 @RoundOffAmount =isnull(RoundOffAmount,0),                      
 @InvSchemeDiscountAmount = IsNull(SchemeDiscountAmount,0),                    
 @Status=isnull(Status,0),@nVatTaxamount = isnull(VATTaxAmount,0), @invabs_gstflag = GSTFlag --GST_Changes                
 from InvoiceAbstract Where InvoiceID=@InvoiceID                        
End  
Else  
Begin  
 Select @InvoiceDate=InvoiceDate, @NetValue=NetValue,                         
 @TotalSalesTax=IsNull(TotalTaxApplicable,0),
 @TotalTaxSuffered=IsNull(TotalTaxSuffered,0),                         
 @TradeDiscount = isnull(DiscountValue,0),                      
 @AdditionalDiscount = isnull(AddlDiscountValue,0),                      
 @ItemDiscount = isnull(ProductDiscount,0),                      
 @CustomerID=CustomerID,                        
 @PaymentMode=PaymentMode,                         
 @InvRefNum=InvoiceReference,                        
 @CollectionID=cast(PaymentDetails as Int),     
 @Freight=isnull(Freight,0),                        
 @RoundOffAmount =isnull(RoundOffAmount,0),                      
 @InvSchemeDiscountAmount = IsNull(SchemeDiscountAmount,0),                    
 @Status=isnull(Status,0), @invabs_gstflag = GSTFlag --GST_Changes                      
 from InvoiceAbstract Where InvoiceID=@InvoiceID                        
End  

--GST_Changes starts here
--GST Enabled 
if @GSTEnable = 1 
begin
	insert into #gstaxcalc
	(invoiceid , tax_component_code , tax_value		, gst_flag	)
	select 
	invoiceid , tax_component_code , sum(tax_value)	, tx.GSTFlag
	from	invoicetaxcomponents	iv(nolock)
	join	tax		tx(nolock)
	on(		tx.Tax_Code = iv.Tax_Code
	and		isnull(tx.GSTFlag,0)= 1		
	)
	where invoiceid = @invoiceid
	group by tax_component_code,invoiceid,tx.GSTFlag	

	insert into #GSTaxCalcAmend
	(invoiceid , tax_component_code , tax_value		, gst_flag	)
	select 
	invoiceid , tax_component_code , sum(tax_value)	, tx.GSTFlag
	from	invoicetaxcomponents	iv(nolock)
	join	tax		tx(nolock)
	on(		tx.Tax_Code = iv.Tax_Code
	and		isnull(tx.GSTFlag,0)= 1		
	)
	where invoiceid = @InvRefNum
	group by tax_component_code,invoiceid,tx.GSTFlag		
end
--GST_Changes ends here
-- Tax Computation from InvoiceDetail table                        
--Select @TaxAmount=Sum((isnull(STPayable,0)+isnull(CSTPayable,0))+((isnull(SalePrice,0)*isnull(Quantity,0))*(isnull(TaxSuffered,0)/100))) from InvoiceDetail where InvoiceID=@InvoiceID                        
Set @TaxAmount=@TotalSalesTax+@TotalTaxSuffered                        
-- Get AccountID of the customer from Customer master                
Select @AccountID=AccountID from Customer where CustomerID=@CustomerID                        
                        
If @Vat_Exists  = 1  
Begin  
 SET @SalesValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0)-IsNull(@Freight,0) - isnull(@nVatTaxamount,0)
End  
Else  
Begin  
 SET @SalesValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0)-IsNull(@Freight,0)
End  
--Reverse entry to close dispatch                      
--If (@Status & 1)<>0 -- invoice from dispatch                      
--Begin                      
Declare @Value float,@RefID Int                      
Declare @AccountID7 int                      
Declare @AccountID8 int                      
Set @AccountID7 = 28 --Bills Received Account                      
Set @AccountID8 = 35 --Sales On DC Account                      
                      
DECLARE scanDispatch CURSOR KEYSET FOR                      
Select DispatchID from DispatchAbstract where InvoiceID=@INVOICEID                      
OPEN scanDispatch                      
FETCH FROM scanDispatch INTO @RefID                      
While @@FETCH_STATUS=0                      
Begin                      
 If IsNull(@RefID,0) <> 0                      
 Begin                      
  --Exec sp_acc_gj_dispatch @RefID -- Journal enry for new Dispatch                      
  Select @Value=sum(isnull(Quantity,0)*isnull(SalePrice,0)) from DispatchDetail where DispatchID = @RefID                      
  -- Get the last TransactionID from the DocumentNumbers table                      
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24                      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                      
  Commit Tran                      
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51                      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                      
  Commit Tran                      
                       
  -- Entry for Bills Receivable Account                      
  execute sp_acc_insertGJ @TransactionID,@AccountID7,@InvoiceDate,@Value,0,@RefID,@DispatchType,"Implicit Dispatch",@DocumentNumber                      
  -- Entry for Sales on DC Account                      
  execute sp_acc_insertGJ @TransactionID,@AccountID8,@InvoiceDate,0,@Value,@RefID,@DispatchType,"Implicit Dispatch",@DocumentNumber                      
            
  -- Get the last TransactionID from the DocumentNumbers table                      
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24                      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                      
  Commit Tran                      
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51                      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                      
  Commit Tran                      
                       
  --Reverse entry to close dispatch                      
  --Exec sp_acc_gj_dispatchcancel @ReferenceNumber                      
  -- Entry for Sales on DC Account                      
  execute sp_acc_insertGJ @TransactionID,@AccountID8,@InvoiceDate,@Value,0,@RefID,@DispatchCancelType,"Close Implicit Dispatch",@DocumentNumber                      
  -- Entry for Bills Receivable Account                      
  execute sp_acc_insertGJ @TransactionID,@AccountID7,@InvoiceDate,0,@Value,@RefID,@DispatchCancelType,"Close Implicit Dispatch",@DocumentNumber                      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID8)                      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID7)                      
 End                      
 FETCH NEXT FROM scanDispatch INTO @RefID                     
End                      
CLOSE ScanDispatch                      
DEALLOCATE ScanDispatch                      
                      
-- To get the new TransactionID for Invoice Amendment                        
Begin Tran                        
 update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=24                        
 Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
Commit Tran                        
-- To get the new DocumentID for Invoice Amendment                        
Begin Tran                        
 update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=51                        
 Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
Commit Tran                        
                        
If @PaymentMode = @CREDIT                        
Begin                        
 -- Procedure to insert journal entries for Invoice Amendment in GJ table.                        
 If @NetValue<>0                        
 Begin                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@NetValue,0,@InvoiceID,@AccountType,"Credit Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
 End                        
 --If @TotalSalesTax<>0                        
 --Begin                        
 -- Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,0,@TotalSalesTax,@InvoiceID,@AccountType,"Credit Invoice Amendment",@DocumentNumber                        
 --Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)                      
 --End                        
 If @TotalTaxSuffered<>0                        
 Begin                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,0,@TotalTaxSuffered,@InvoiceID,@AccountType,"Credit Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)                      
 End   

--GST_Changes starts
 if @GSTEnable = 1 
 begin		
	select @gstcount = max(id) from #GSTaxCalc
	if ((@invabs_gstflag = 1)and (@gstcount > 0))--GST flag Enabled in Invoice abstract
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
				select  @gst_payable	  = OutputAccID 
				from	TaxComponentDetail(nolock) 
				where	TaxComponent_Code = @GSTaxComponent

				--Entry for GS Tax Accounts
				if (isnull(@gst_payable,0)>0)
				begin
					execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,0,@nGSTaxAmt,@InvoiceID,@AccountType,"Credit Invoice Amendment",@DocumentNumber                
					Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)  
				end
			end
			select @rowid = @rowid+1
		end 
	end 
	else  --GST flag Disabled in Invoice abstract
	begin
		if (( select isnull(flag,0)
			  from tbl_merp_configabstract(nolock)
			  where screencode = 'UTGST' ) = 1)
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'UTGST Output'
		end
		else
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'SGST Output'
		end	
		
		if ((@nVatTaxamount <> 0 ) and (isnull(@gst_payable,0)>0))
		begin
			execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,0,@nVatTaxamount,@InvoiceID,@AccountType,"VAT Credit Invoice Amendment",@DocumentNumber                		
			Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)
		end
	end   	
 end
 else   --GST_Changes ends 
 If @Vat_Exists = 1  
 Begin  
  if @nVatTaxamount <> 0    
  begin    
    -- Entry for VAT Tax Account                
  Execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,0,@nVatTaxamount,@InvoiceID,@AccountType,"Credit Invoice Amendment",@DocumentNumber                        
  Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)                      
 end  
 End  
  
 If @Freight<>0                        
Begin                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,0,@Freight,@InvoiceID,@AccountType,"Credit Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)                      
 End                        
 If @SalesValue<>0                        
 Begin                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@SalesValue,@InvoiceID,@AccountType,"Credit Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)                      
 End                        
End                        
Else if @PaymentMode = @CASH                        
Begin                        
 -- Procedure to insert journal entries for Invoice Amendment 1st set in GJ table.                        
 If @NetValue<>0                        
 Begin                        
  -- Entry for customer Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@NetValue,0,@InvoiceID,@AccountType,"Cash Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
 End                        
 --If @TotalSalesTax<>0                        
 --Begin                        
 -- -- Entry for Sales tax Account                        
 -- Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,0,@TotalSalesTax,@InvoiceID,@AccountType,"Cash Invoice Amendment",@DocumentNumber                        
 --Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)                      
 --End                        
 If @TotalTaxSuffered<>0                        
 Begin                        
  -- Entry for Sales tax Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,0,@TotalTaxSuffered,@InvoiceID,@AccountType,"Cash Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)                      
 End                     
  
 --GST_Changes starts
 if @GSTEnable = 1 
 begin		
	select @gstcount = max(id) from #GSTaxCalc
	if ((@invabs_gstflag = 1)and (@gstcount > 0))--GST flag Enabled in Invoice abstract
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
				select  @gst_payable	  = OutputAccID 
				from	TaxComponentDetail(nolock) 
				where	TaxComponent_Code = @GSTaxComponent

				--Entry for GS Tax Accounts
				if (isnull(@gst_payable,0)>0)
				begin
					execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,0,@nGSTaxAmt,@InvoiceID,@AccountType,"Cash Invoice Amendment",@DocumentNumber                
					Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)
				end
			end
			select @rowid = @rowid+1
		end 
	end 
	else  --GST flag Disabled in Invoice abstract
	begin
		if (( select isnull(flag,0)
			  from tbl_merp_configabstract(nolock)
			  where screencode = 'UTGST' ) = 1)
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'UTGST Output'
		end
		else
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'SGST Output'
		end	
			
		if ((@nVatTaxamount <> 0 ) and (isnull(@gst_payable,0)>0))
		begin 
			execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,0,@nVatTaxamount,@InvoiceID,@AccountType,"VAT Cash Invoice Amendment",@DocumentNumber                		
			Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)
		end
	end   	
 end
 else   --GST_Changes ends 
 If @Vat_Exists = 1  
 Begin  
  if @nVatTaxamount <> 0    
  begin    
    -- Entry for VAT Tax Account                
  Execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,0,@nVatTaxamount,@InvoiceID,@AccountType,"Cash Invoice Amendment",@DocumentNumber                        
  Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)                      
 end  
 End  
     
 If @Freight<>0                        
 Begin                        
  -- Entry for Freight Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,0,@Freight,@InvoiceID,@AccountType,"Cash Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)                      
 End                        
 If @SalesValue<>0                        
 Begin                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@SalesValue,@InvoiceID,@AccountType,"Cash Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)                      
 End                        
                        
 -- To get the new TransactionID for Invoice Amendment                        
 Begin Tran                        
  update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=24                        
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
 Commit Tran                        
 -- To get the new DocumentID for Invoice Amendment                        
 Begin Tran                        
  update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=51                        
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
 Commit Tran                        
           
-- Procedure to insert journal entries for Invoice Amendment 2nd set in GJ table.                        
--  If @RoundOffAmount <> 0                        
--  Begin                        
--   Set @NetBalance=@NetValue + @RoundOffAmount                        
--  End                        
--  Else                         
--  Begin                        
--   Set @NetBalance=@NetValue                        
--  End                          
--  If @NetValue<>0                        
--  Begin                        
--   -- Entry for Debit Cash Account                        
--   Execute sp_acc_insertGJ @TransactionID,@AccountID1,@InvoiceDate,@NetBalance,0,@CollectionID,@CollectionType,"Cash Invoice Amendment",@DocumentNumber                        
--                           
--   -- Entry for Credit Customer Account                        
--   Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@NetBalance,@CollectionID,@CollectionType,"Cash Invoice Amendment",@DocumentNumber                        
--  End                        
 SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @INVOICEID) as int)                        
 select @ColValue=isnull(Value,0) from collections Where DocumentID = @PaymentDetails                        
                        
 If @ColValue<>0                        
 Begin                        
  -- Entry for Debit Cash Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID1,@InvoiceDate,@ColValue,0,@CollectionID,@CollectionType,"Cash Invoice Amendment",@DocumentNumber                        
                          
  -- Entry for Credit Customer Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@ColValue,@CollectionID,@CollectionType,"Cash Invoice Amendment",@DocumentNumber           
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)                      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                       
 End                        
End                        
Else if (@PaymentMode = @CHEQUE) or (@PaymentMode = @DD)                        
Begin                        
 -- Procedure to insert journal entries for Invoice Amendment 1st set in GJ table.                        
 If @NetValue<>0                        
 Begin                        
  -- Entry for customer Account              
  Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@NetValue,0,@InvoiceID,@AccountType,"Cheque/DD Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
 End                        
 --If @TotalSalesTax<>0                        
 --Begin                        
 -- -- Entry for Sales tax Account                        
 -- Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,0,@TotalSalesTax,@InvoiceID,@AccountType,"Cheque/DD Invoice Amendment",@DocumentNumber                  
 --Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)                      
 --End   
 If @TotalTaxSuffered<>0                        
 Begin                        
  -- Entry for Tax suffered Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,0,@TotalTaxSuffered,@InvoiceID,@AccountType,"Cheque/DD Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)                      
 End                 
         
 --GST_Changes starts
 if @GSTEnable = 1 
 begin		
	select @gstcount = max(id) from #GSTaxCalc
	if  ((@invabs_gstflag = 1)and (@gstcount > 0))--GST flag Enabled in Invoice abstract
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
				select  @gst_payable	  = OutputAccID 
				from	TaxComponentDetail(nolock) 
				where	TaxComponent_Code = @GSTaxComponent

				--Entry for GS Tax Accounts
				if (isnull(@gst_payable,0)>0)
				begin
					execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,0,@nGSTaxAmt,@InvoiceID,@AccountType,"Cheque/DD Invoice Amendment",@DocumentNumber                
					Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)  
				end
			end
			select @rowid = @rowid+1
		end 
	end 
	else --GST flag Disabled in Invoice abstract
	begin
		if (( select isnull(flag,0)
			  from tbl_merp_configabstract(nolock)
			  where screencode = 'UTGST' ) = 1)
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'UTGST Output'
		end
		else
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'SGST Output'
		end	
				
		if ((@nVatTaxamount <> 0 ) and (isnull(@gst_payable,0)>0))
		begin
			execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,0,@nVatTaxamount,@InvoiceID,@AccountType,"VAT Cheque/DD Invoice Amendment",@DocumentNumber                		
			Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)
		end
	end   	
 end
 else   --GST_Changes ends
 If @Vat_Exists = 1  
 Begin  
  if @nVatTaxamount <> 0    
  begin    
    -- Entry for VAT Tax Account  
  Execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,0,@nVatTaxamount,@InvoiceID,@AccountType,"Cheque/DD Invoice Amendment",@DocumentNumber                        
  Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)                      
 end  
 End  
  
 If @Freight<>0           
 Begin                        
  -- Entry for Freight Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,0,@Freight,@InvoiceID,@AccountType,"Cheque/DD Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)                      
 End                        
 If @Salesvalue<>0                        
 Begin                        
  -- Entry for Sales Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@SalesValue,@InvoiceID,@AccountType,"Cheque/DD Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)                      
 End                        
                        
 -- To get the new TransactionID for Invoice Amendment                        
 Begin Tran                        
  update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=24                        
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
 Commit Tran                        
 -- To get the new DocumentID for Invoice Amendment                        
 Begin Tran                        
  update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=51                        
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
 Commit Tran                        
                        
-- Procedure to insert journal entries for Invoice Amendment 2nd set in GJ table.                        
--  If @RoundOffAmount <> 0                        
--  Begin                        
--   Set @NetBalance=@NetValue + @RoundOffAmount          
--  End                        
--  Else                         
--  Begin                        
--   Set @NetBalance=@NetValue                        
--  End                         
 SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @INVOICEID) as int)                        
 select @ColValue=isnull(Value,0) from collections Where DocumentID = @PaymentDetails                        
                         
 If @ColValue<>0                        
 Begin                        
  -- Entry for Debit Cheque on Hand Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID4,@InvoiceDate,@ColValue,0,@CollectionID,@CollectionType,"Cheque/DD Invoice Amendment",@DocumentNumber                       
  -- Entry for Credit Customer Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@ColValue,@CollectionID,@CollectionType,"Cheque/DD Invoice Amendment",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID4)                      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
 End                        
End                        
--------------------------------Entry for Discount Account----------------------------------                      
Declare @SalesDiscountAccount Int             
Set @SalesDiscountAccount = 107 --Discount On Sales A/c                      
                
Set @TradeDiscount = @TradeDiscount - @InvSchemeDiscountAmount                    
Set @ItemDiscount = @ItemDiscount - @ItmSchemeDiscountAmount                    
Set @TotalDiscount = @TradeDiscount + @AdditionalDiscount + @ItemDiscount                      
                      
If @TotalDiscount > 0                      
 Begin                     
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24                      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                      
  Commit Tran                      
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51                      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                      
  Commit Tran                      
  --Entry for Discount Account                      
  Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,@TotalDiscount,0,@InvoiceID,@AccountType,"Invoice Amendment - Discount On Sales",@DocumentNumber                      
  --Entry for Sales Account                      
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@TotalDiscount,@InvoiceID,@AccountType,"Invoice Amendment - Discount On Sales",@DocumentNumber                      
  --Update #TempBackdatedAccounts for Backdation Purpose                      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesDiscountAccount)                      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)                      
 End                      
Else If @TotalDiscount < 0                      
 Begin                      
  Set @TotalDiscount = ABS(@TotalDiscount)                      
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24                      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                      
  Commit Tran                      
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51                      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                      
  Commit Tran                      
  --Entry for Sales Account                      
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@TotalDiscount,0,@InvoiceID,@AccountType,"Invoice Amendment - Discount On Sales",@DocumentNumber                      
  --Entry for Discount Account                      
  Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,0,@TotalDiscount,@InvoiceID,@AccountType,"Invoice Amendment - Discount On Sales",@DocumentNumber                      
  --Update #TempBackdatedAccounts for Backdation Purpose                      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesDiscountAccount)                      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)                      
 End                      
--------------------------------------------------------------------------------------------                      
If @RoundOffAmount >0                        
Begin                        
 -- Get the last TransactionID from the DocumentNumbers table                        
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24                        
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
 Commit Tran                        
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51                        
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
 Commit Tran                        
 -- Entry for Customer Account                        
 execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber                        
 -- Entry for RoundOff Account                        
 execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)                      
End                        
Else If @RoundOffAmount <0                        
Begin                        
 Set @RoundOffAmount=Abs(@RoundOffAmount)                        
 -- Get the last TransactionID from the DocumentNumbers table                    
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24            
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
 Commit Tran                        
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51                        
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
 Commit Tran                        
 -- Entry for RoundOff Account                        
 execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber                        
 -- Entry for Customer Account                        
 execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)                      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
End                        
-----------------------------------Entry for Schemes-----------------------------------------                
--Declare @SecSchemeValue Decimal(18,6),@SchemeDiscountValue Decimal(18,6)                  
--Declare @SecondarySchemeExpense Int,@ClaimsRecivable Int                        
--Declare @SchType Int,@SecScheme Int,@SchemeType Int,@SchemeID Int                  
--Set @SecondarySchemeExpense = 39                        
--Set @ClaimsRecivable = 10                        
--                        
--DECLARE scanScheme CURSOR KEYSET FOR                        
--Select Type from SchemeSale where InvoiceId=@InvoiceId And IsNull(SaleType,0) = 0 Group By Type                        
--OPEN scanScheme                        
--FETCH FROM scanScheme INTO @SchType                        
--While @@FETCH_STATUS=0                        
--Begin                        
-- Select @SecScheme=IsNull(SecondaryScheme,0),@SchemeType=IsNull(SchemeType,0) from Schemes where SchemeID=IsNull(@SchType,0)                        
-- If IsNull(@SecScheme,0)<>0                        
-- Begin                        
--  If IsNull(@SchemeType,0) =19 -- Item based percentage scheme type                        
--  Begin                        
--   Select @SecSchemeValue= IsNull(@SecSchemeValue,0) + (Select Sum((isnull(Cost,0)*isnull(Value,0))/100) from SchemeSale where InvoiceId=@InvoiceId and Type=@SchType And IsNull(SaleType,0) = 0 group by Type)                        
--  End                        
--  Else                        
--  Begin                        
--   Select @SecSchemeValue=IsNull(@SecSchemeValue,0) + (Select Sum(isnull(Cost,0)) from SchemeSale where InvoiceId=@InvoiceId and Type=@SchType And IsNull(SaleType,0) = 0 group by Type)                        
--  End                        
-- End                        
-- FETCH NEXT FROM scanScheme INTO @SchType                        
--End                        
--CLOSE scanScheme                        
--DEALLOCATE scanScheme                        
--                
--/*Add Invoice Based Secondary Scheme Values to the @SecSchemeValue Variable*/                  
--Select @SchemeID = IsNull(SchemeID,0), @SchemeDiscountValue = IsNull(SchemeDiscountAmount,0) from InvoiceAbstract Where InvoiceID = @InvoiceID                        
--Select @SecScheme = IsNull(SecondaryScheme,0) from Schemes where SchemeID = @SchemeID                  
--If IsNull(@SecScheme,0) <> 0                  
--Begin                  
-- Set @SecSchemeValue = IsNull(@SecSchemeValue,0) + IsNull(@SchemeDiscountValue,0)                  
--End                  

-- Begin: New Code for Schemes -37939
Declare @SecSchemeValue Decimal(18,6),@SchemeDiscountValue Decimal(18,6)          
Declare @SecondarySchemeExpense Int,@ClaimsRecivable Int                
Declare @Type1 Int,@SecScheme Int,@SchemeType Int,@SchemeID Int, @SchID  int          
Declare @InvSchemeID nVarchar(255)
Set @SecondarySchemeExpense = 39                
Set @ClaimsRecivable = 10                
                
DECLARE scanScheme CURSOR KEYSET FOR                
Select SchemeID from tbl_mERP_SchemeSale where InvoiceId=@InvoiceId And IsNull(SaleType,0) = 0 Group By SchemeID
OPEN scanScheme                
FETCH FROM scanScheme INTO @Type1                
While @@FETCH_STATUS=0                
Begin                
 Select @SecScheme=IsNull(RFAApplicable,0)  from tbl_mERP_SchemeAbstract where SchemeID=IsNull(@Type1,0)                
 If IsNull(@SecScheme,0)<>0                
  Begin                
   Select @SecSchemeValue=IsNull(@SecSchemeValue,0) + (Select Sum(isnull(SChemeValue,0)) from tbl_mERP_SchemeSale where InvoiceId=@InvoiceId and SChemeID=@Type1 And IsNull(SaleType,0) = 0 group by SchemeID)                
  End                
 FETCH NEXT FROM scanScheme INTO @Type1                
End                
CLOSE scanScheme                
DEALLOCATE scanScheme                
          
/*Add Invoice Based Secondary Scheme Values to the @SecSchemeValue Variable*/          
-- Select @SchemeID = IsNull(SchemeID,0), @SchemeDiscountValue = IsNull(SchemeDiscountAmount,0) from InvoiceAbstract Where InvoiceID = @InvoiceID                

--Select @SchemeDiscountValue = IsNull(SchemeDiscountAmount,0) from InvoiceAbstract Where InvoiceID = @InvoiceID                
--
--Create table #TScheme(SchemeID int)
--Select @InvSchemeID = InvoiceSchemeID from InvoiceAbstract Where InvoiceID = 1
--Truncate table #TScheme 
--Insert Into #TScheme 
--Select * from dbo.sp_SplitIn2Rows(@InvSchemeID, ',')
--Select @SchID = SchemeID  from #TScheme Order By 1 
--
--Select @SecScheme = IsNull(RFAApplicable,0) from tbl_mERP_SchemeAbstract where SchemeID = @SchID
--If IsNull(@SecScheme,0) <> 0          
--Begin          
-- Set @SecSchemeValue = IsNull(@SecSchemeValue,0) + IsNull(@SchemeDiscountValue,0)          
--End          
--Drop table #TScheme
---- End: New Code for Schemes -37939


/*Add Invoice Based Secondary Scheme Values to the @SecSchemeValue Variable - Changed - ITC Phase III*/  
Declare @MultiSchDet as nVarchar(2500)
Declare @SchDet as nVarchar(2500)
Declare @SchmID As Int
Declare @SlabID As Int
Declare @SchAmnt as Decimal(18,6)
Declare @SchPer as Decimal(18,6)
Declare @Delimeter as  Char(1)
Declare @szSchAmnt nvarchar(100)

Set @Delimeter = Char(15)

Select @MultiSchDet = isNull(MultipleSchemeDetails,'')  From InvoiceAbstract Where InvoiceID = @InvoiceID
If @MultiSchDet <> ''
Begin
		Declare @i as Int
		Declare @RecCnt as Int
		Create Table #tmpSch(RowID Int Identity(1,1),SchemeDetail nVarchar(250))
		Truncate table #tmpSch
		Insert Into #tmpSch
		Select * from dbo.sp_SplitIn2Rows(@MultiSchDet,@Delimeter)	
		Select @RecCnt = Count(*) From #tmpSch 
		Set @i = 1
		While @i <= @RecCnt
		Begin
			Set @SchDet = ''			
			Set @SchmID = 0
			Set @szSchAmnt = 0
			Set @SlabID = 0
			Set @SchAmnt = 0
			Set @SecScheme = 0

			Select @SchDet =isNull(SchemeDetail,'') From #tmpSch Where RowID = @i
			Set @SchmID = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
			Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet)+1,len(@SchDet))
			Set @SlabID = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
			Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet) + 1,len(@SchDet))

			Set @szSchAmnt = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)

			if (Charindex('E+',@szSchAmnt) > 0  Or Charindex('E-',@szSchAmnt) > 0)
				set @SchAmnt = convert(decimal(18,6), str(@szSchAmnt, 18, 6))
			Else
				set @SchAmnt = @szSchAmnt
		

 			Select @SecScheme=IsNull(RFAApplicable,0)  from tbl_mERP_SchemeAbstract where SchemeID=IsNull(@SchmID,0)   
			
			If  @SecScheme = 1 
			Begin
				Set @SchemeDiscountValue = isNull(@SchemeDiscountValue,0) + isNull(@SchAmnt,0)
			End
		
			Set @i = @i + 1
		End
		Drop Table #tmpSch
End


Set @SecSchemeValue = IsNull(@SecSchemeValue,0) + IsNull(@SchemeDiscountValue,0)   

/*Ends: Add Invoice Based Secondary Scheme Values to the @SecSchemeValue Variable - Changed - ITC Phase III*/         

                  
If IsNull(@SecSchemeValue,0)<>0                        
Begin                        
 -- Get the last TransactionID from the DocumentNumbers table                        
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24                        
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
 Commit Tran                        
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51                        
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
 Commit Tran                        
 -- Entry for SecondarySchemeExpense Account                        
execute sp_acc_insertGJ @TransactionID,@SecondarySchemeExpense,@InvoiceDate,@SecSchemeValue,0,@InvoiceID,@AccountType,"Secondary Scheme",@DocumentNumber                        
 -- Entry for Customer Account                        
 execute sp_acc_insertGJ @TransactionID,@ClaimsRecivable,@InvoiceDate,0,@SecSchemeValue,@InvoiceID,@AccountType,"Secondary Scheme",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@SecondarySchemeExpense)                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@ClaimsRecivable)                        
End                        
---------------------------------------------------------------------------------------------                      
/*Retrive the require fields to make Reversal entry of the original invoice using InvoiceReference (Invoice Amended)*/                
If @Vat_Exists = 1  
Begin  
 Select @InvoiceDate=InvoiceDate, @NetValue=NetValue,@TotalSalesTax=isnull(TotalTaxApplicable,0) - isnull(VATTaxAmount,0),
 @TradeDiscount = isnull(DiscountValue,0),@AdditionalDiscount = isnull(AddlDiscountValue,0),@ItemDiscount = isnull(ProductDiscount,0),                      
 @TotalTaxSuffered=isnull(TotalTaxSuffered,0), @CustomerID=CustomerID,@PaymentMode=PaymentMode,@CollectionID=cast(PaymentDetails as Int),                         
 @InvSchemeDiscountAmount = IsNull(SchemeDiscountAmount,0),@Freight=isnull(Freight,0),@RoundOffAmount=RoundOffAmount ,  
 @nVatTaxamount = isnull(VATTaxAmount,0)  
 from InvoiceAbstract where InvoiceID=@InvRefNum          
End  
Else  
Begin  
 Select @InvoiceDate=InvoiceDate, @NetValue=NetValue,@TotalSalesTax=TotalTaxApplicable,
 @TradeDiscount = isnull(DiscountValue,0),@AdditionalDiscount = isnull(AddlDiscountValue,0),@ItemDiscount = isnull(ProductDiscount,0),                      
 @TotalTaxSuffered=TotalTaxSuffered, @CustomerID=CustomerID,@PaymentMode=PaymentMode,@CollectionID=cast(PaymentDetails as Int),                         
 @InvSchemeDiscountAmount = IsNull(SchemeDiscountAmount,0),@Freight=isnull(Freight,0),@RoundOffAmount=RoundOffAmount from InvoiceAbstract where InvoiceID=@InvRefNum                
End  
                      
Select @ItmSchemeDiscountAmount = Sum(IsNull(SchemeDiscAmount,0) + IsNull(SplCatDiscAmount,0)) from InvoiceDetail Where InvoiceID = @InvRefNum                    
 -- Tax Computation from InvoiceDetail table                        
 --Select @TaxAmount=Sum((isnull(STPayable,0)+isnull(CSTPayable,0))+((isnull(SalePrice,0)*isnull(Quantity,0))*(isnull(TaxSuffered,0)/100))) from InvoiceDetail where InvoiceID=@InvRefNum       
 Set @TaxAmount=@TotalSalesTax+@TotalTaxsuffered                     
 -- Get AccountID of the customer from Customer master                        
 Select @AccountID=AccountID from Customer where CustomerID=@CustomerID                        
 --Set the old invoice sales value                        
If @Vat_Exists  = 1  
Begin  
 Set @SalesValue=@NetValue-@TaxAmount-@Freight - @nVatTaxamount
End  
Else  
Begin            
  Set @SalesValue=@NetValue-@TaxAmount-@Freight
End  
-- To get the new TransactionID for Invoice Amendment                        
Begin Tran                        
 update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=24                        
 Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
Commit Tran                        
-- To get the new DocumentID for Invoice Amendment                        
Begin Tran                        
 update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=51                        
 Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
Commit Tran                        
                        
If @PaymentMode = @CREDIT                        
Begin                      
 -- Procedure to insert journal entries for Invoice Amended in GJ table.                        
 --If @TotalSalesTax<>0                     
 --Begin                       
 -- -- Entry for Sales tax account                        
 -- Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,@TotalSalesTax,0,@InvRefNum,@AccountType,"Credit Invoice Amended",@DocumentNumber                        
 --Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)                      
 --End                        
 If @TotalTaxSuffered<>0                        
 Begin                        
  -- Entry for Sales tax account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,@TotalTaxSuffered,0,@InvRefNum,@AccountType,"Credit Invoice Amended",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)                      
 End   
 
 --GST_Changes starts
 if @GSTEnable = 1 
 begin		
	select @gstcount = max(id) from #GSTaxCalcAmend 
	if ((@invabs_gstflag = 1)and (@gstcount > 0))--GST flag Enabled in Invoice abstract
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
				select  @gst_payable	  = OutputAccID 
				from	TaxComponentDetail(nolock) 
				where	TaxComponent_Code = @GSTaxComponent

				--Entry for GS Tax Accounts
				if (isnull(@gst_payable,0)>0)
				begin
					execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,@nGSTaxAmt,0,@InvRefNum,@AccountType,"Credit Invoice Amended",@DocumentNumber                
					Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)  
				end
			end
			select @rowid = @rowid+1
		end 
	end 
	else  --GST flag Disabled in Invoice abstract
	begin
		if (( select isnull(flag,0)
			  from tbl_merp_configabstract(nolock)
			  where screencode = 'UTGST' ) = 1)
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'UTGST Output'
		end
		else
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'SGST Output'
		end	
		
		if ((@nVatTaxamount <> 0 ) and (isnull(@gst_payable,0)>0))  
		begin
			execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,@nVatTaxamount,0,@InvRefNum,@AccountType,"VAT Credit Invoice Amended",@DocumentNumber                		
			Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)
		end
	end   	
 end
 else   --GST_Changes ends
 If @Vat_Exists = 1  
 Begin  
  if @nVatTaxamount <> 0    
  begin    
    -- Entry for VAT Tax Account         
  Execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,@nVatTaxamount,0,@InvRefNum,@AccountType,"Credit Invoice Amended",@DocumentNumber                        
  Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)                      
 end  
 End  
  
 If @Freight<>0                        
 Begin                        
  -- Entry for freight account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,@Freight,0,@InvRefNum,@AccountType,"Credit Invoice Amended",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)                      
 End                        
 If @SalesValue<>0                        
 Begin                        
  -- Entry for Sales account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@SalesValue,0,@InvRefNum,@AccountType,"Credit Invoice Amended",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)                      
 End                        
 If @NetValue<>0                        
 Begin                        
  -- Entry for customer account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@NetValue,@InvRefNum,@AccountType,"Credit Invoice Amended",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
 End             
End                        
Else If @PaymentMode = @CASH                      
Begin                        
 -- Procedure to insert journal entries for Invoice Amended 1st set in GJ table.              
 --If @TotalSalesTax<>0               
 --Begin                        
 -- -- Entry for Debit Sales tax Account                        
 -- Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,@TotalSalesTax,0,@InvRefNum,@AccountType,"Cash Invoice Amended",@DocumentNumber                        
 -- Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)                       
 --End                        
 If @TotalTaxSuffered<>0                        
 Begin                        
  -- Entry for Debit Sales tax Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,@TotalTaxSuffered,0,@InvRefNum,@AccountType,"Cash Invoice Amended",@DocumentNumber                        
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)                      
 End  
  
 --GST_Changes starts
 if @GSTEnable = 1 
 begin		
	select @gstcount = max(id) from #GSTaxCalcAmend
	if ((@invabs_gstflag = 1)and (@gstcount > 0))--GST flag Enabled in Invoice abstract
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
				select  @gst_payable	  = OutputAccID 
				from	TaxComponentDetail(nolock) 
				where	TaxComponent_Code = @GSTaxComponent

				--Entry for GS Tax Accounts
				if (isnull(@gst_payable,0)>0)
				begin
					execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,@nGSTaxAmt,0,@InvRefNum,@AccountType,"Cash Invoice Amended",@DocumentNumber                
					Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)  
				end
			end
			select @rowid = @rowid+1
		end 
	end 
	else  --GST flag Disabled in Invoice abstract
	begin
		if (( select isnull(flag,0)
			  from tbl_merp_configabstract(nolock)
			  where screencode = 'UTGST' ) = 1)
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'UTGST Output'
		end
		else
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'SGST Output'
		end	
		
		if ((@nVatTaxamount <> 0 ) and (isnull(@gst_payable,0)>0))   
		begin 
			execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,@nVatTaxamount,0,@InvRefNum,@AccountType,"VAT Cash Invoice Amended",@DocumentNumber                		
			Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)
		end
	end   	
 end
 else   --GST_Changes ends
 If @Vat_Exists = 1  
 Begin  
  if @nVatTaxamount <> 0    
  begin    
    -- Entry for VAT Tax Account         
  Execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,@nVatTaxamount,0,@InvRefNum,@AccountType,"Cash Invoice Amended",@DocumentNumber                        
  Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)                      
 end  
 End  
  
 If @Freight<>0                        
 Begin                        
  -- Entry for Debit Freight Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,@Freight,0,@InvRefNum,@AccountType,"Cash Invoice Amended",@DocumentNumber                        
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)                      
 End                        
 If @SalesValue<>0                         
 Begin                        
  -- Entry for Debit Sales Account              
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@SalesValue,0,@InvRefNum,@AccountType,"Cash Invoice Amended",@DocumentNumber                        
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)                      
 End                        
 If @NetValue<>0                        
 Begin                        
  -- Entry for Credit customer Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@NetValue,@InvRefNum,@AccountType,"Cash Invoice Amended",@DocumentNumber                        
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
 End                        
                        
--  SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @InvRefNum) as int)                        
--  IF Exists (select DocumentID from collections Where (IsNull(Status,0) & 64) = 0 And DocumentID = @PaymentDetails)                        
 If @CANCEL=1                        
 Begin                        
  Set @ColValue=0                      
  SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @InvRefNum) as int)                          
  select @ColValue=isnull(Value,0) from collections Where (IsNull(Status,0) & 64) <> 0 And DocumentID = @PaymentDetails                        
  -- To get the new TransactionID for Invoice Amendment                        
  Begin Tran                        
   update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=24                        
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
  Commit Tran                        
  -- To get the new DocumentID for Invoice Amendment                        
  Begin Tran                        
   update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=51                        
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
  Commit Tran                        
                        
-- Procedure to insert journal entries for Invoice Amended 2nd set in GJ table.                        
--   If @RoundOffAmount <> 0                        
--   Begin                        
--    Set @NetBalance=@NetValue + @RoundOffAmount                        
--   End                        
--   Else                 
--   Begin                        
--    Set @NetBalance=@NetValue                        
--   End                          
                        
  If @ColValue<>0                        
  Begin                        
   -- Entry for Debit Customer Account                        
   Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@ColValue,0,@CollectionID,@CollectionCancelType,"Cash Invoice Amended",@DocumentNumber                        
   -- Entry for Credit Cash Account                        
   Execute sp_acc_insertGJ @TransactionID,@AccountID1,@InvoiceDate,0,@ColValue,@CollectionID,@CollectionCancelType,"Cash Invoice Amended",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)                      
  End                        
 End                        
End                        
Else If (@PaymentMode = @CHEQUE) or (@PaymentMode = @DD)                      
Begin                        
 -- Procedure to insert journal entries for Invoice Amended 1st set in GJ table.                        
 --If @TotalSalesTax<>0                        
 --Begin                        
 -- -- Entry for Debit Sales tax Account                        
 -- Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,@TotalSalesTax,0,@InvRefNum,@AccountType,"Cheque/DD Invoice Amended",@DocumentNumber                        
 --Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)                      
 --End                        
 If @TotalTaxSuffered<>0                        
 Begin                        
  -- Entry for Debit Tax suffered Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,@TotalTaxSuffered,0,@InvRefNum,@AccountType,"Cheque/DD Invoice Amended",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)                      
 End  
  
  --GST_Changes starts
 if @GSTEnable = 1 
 begin		
	select @gstcount = max(id) from #GSTaxCalcAmend
	if ((@invabs_gstflag = 1)and (@gstcount > 0))--GST flag Enabled in Invoice abstract
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
				select  @gst_payable	  = OutputAccID 
				from	TaxComponentDetail(nolock) 
				where	TaxComponent_Code = @GSTaxComponent

				--Entry for GS Tax Accounts
				if (isnull(@gst_payable,0)>0)
				begin
					execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,@nGSTaxAmt,0,@InvRefNum,@AccountType,"Cheque/DD Invoice Amended",@DocumentNumber                
					Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)  
				end
			end
			select @rowid = @rowid+1
		end 
	end 
	else --GST flag Disabled in Invoice abstract
	begin
		if (( select isnull(flag,0)
			  from tbl_merp_configabstract(nolock)
			  where screencode = 'UTGST' ) = 1)
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'UTGST Output'
		end
		else
		begin
			select	@gst_payable =	accountid
			from	accountsmaster (nolock)
			where	accountname  = 'SGST Output'
		end	
		
		if ((@nVatTaxamount <> 0 ) and (isnull(@gst_payable,0)>0))   
		begin
			execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,@nVatTaxamount,0,@InvRefNum,@AccountType,"VAT Cheque/DD Invoice Amended",@DocumentNumber                		
			Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)
		end
	end   	
 end
 else   --GST_Changes ends
 If @Vat_Exists = 1  
 Begin  
  if @nVatTaxamount <> 0    
  begin    
    -- Entry for VAT Tax Account         
  Execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,@nVatTaxamount,0,@InvRefNum,@AccountType,"Cheque/DD Invoice Amended",@DocumentNumber                        
  Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)                      
 end  
 End  
  
 If @Freight<>0                        
 Begin                        
  -- Entry for Debit Freight Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,@Freight,0,@InvRefNum,@AccountType,"Cheque/DD Invoice Amended",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)                      
 End                        
 If @SalesValue<>0                    
 Begin                        
  -- Entry for Debit Sales Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@SalesValue,0,@InvRefNum,@AccountType,"Cheque/DD Invoice Amended",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)                      
 End                        
 If @NetValue<>0                        
 Begin                        
  -- Entry for Credit customer Account                        
  Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@NetValue,@InvRefNum,@AccountType,"Cheque/DD Invoice Amended",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
 End                        
                        
--  SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @InvRefNum) as int)                        
--  IF Exists (select DocumentID from collections Where (IsNull(Status,0) & 64) = 0 And DocumentID = @PaymentDetails)                        
 If @CANCEL=1                        
 Begin                        
  SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @InvRefNum) as int)                        
  select @ColValue=isnull(Value,0) from collections Where (IsNull(Status,0) & 64) <> 0 And DocumentID = @PaymentDetails                        
                        
  -- To get the new TransactionID for Invoice Amendment                        
  Begin Tran                        
   update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=24                        
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
  Commit Tran                        
  -- To get the new TransactionID for Invoice Amendment                        
  Begin Tran                        
   update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=51                        
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
  Commit Tran                        
                         
-- Procedure to insert journal entries for Invoice Amended 2nd set in GJ table.                        
--   If @RoundOffAmount <> 0                        
--   Begin                        
--    Set @NetBalance=@NetValue + @RoundOffAmount                      
-- End                        
--   Else                         
--   Begin                        
--    Set @NetBalance=@NetValue                        
--   End                          
  If @ColValue<>0                        
  Begin                        
   -- Entry for Debit Customer Account                        
   Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@ColValue,0,@CollectionID,@CollectionCancelType,"Cheque/DD Invoice Amended",@DocumentNumber                        
   -- Entry for Credit Cheque on Hand Account                        
   Execute sp_acc_insertGJ @TransactionID,@AccountID4,@InvoiceDate,0,@ColValue,@CollectionID,@CollectionCancelType,"Cheque/DD Invoice Amended",@DocumentNumber                        
   Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
   Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID4)                      
  End                        
 End                        
End                        
-------------------------------Reversal Entry for Discount Account---------------------------                      
Set @TradeDiscount = @TradeDiscount - @InvSchemeDiscountAmount                    
Set @ItemDiscount = @ItemDiscount - @ItmSchemeDiscountAmount                    
Set @TotalDiscount = @TradeDiscount + @AdditionalDiscount + @ItemDiscount                      
                      
If @TotalDiscount > 0                      
 Begin                      
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24                      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                      
  Commit Tran                      
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51                      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                      
  Commit Tran                      
  --Entry for Sales Account                      
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@TotalDiscount,0,@InvRefNum,@AccountType,"Invoice Amended - Discount On Sales",@DocumentNumber                      
  --Entry for Discount Account                      
  Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,0,@TotalDiscount,@InvRefNum,@AccountType,"Invoice Amended - Discount On Sales",@DocumentNumber                      
  --Update #TempBackdatedAccounts for Backdation Purpose                      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesDiscountAccount)                      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)                      
 End                      
Else If @TotalDiscount < 0                      
 Begin                      
  Set @TotalDiscount = ABS(@TotalDiscount)                      
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24                      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                      
  Commit Tran                      
  begin tran                      
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51             
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                      
  Commit Tran                      
  --Entry for Discount Account                      
  Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,@TotalDiscount,0,@InvRefNum,@AccountType,"Invoice Amended - Discount On Sales",@DocumentNumber                     
  --Entry for Sales Account                      
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@TotalDiscount,@InvRefNum,@AccountType,"Invoice Amended - Discount On Sales",@DocumentNumber                      
  --Update #TempBackdatedAccounts for Backdation Purpose                      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesDiscountAccount)                      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)                      
 End                      
--------------------------------------------------------------------------------------------                      
If @RoundOffAmount >0                        
Begin                        
 -- Get the last TransactionID from the DocumentNumbers table                        
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24                        
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
 Commit Tran                        
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51                        
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
Commit Tran                        
 -- Entry for RoundOff Account                        
 execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,@RoundOffAmount,0,@InvRefNum,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber                        
 -- Entry for Customer Account                        
 execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@RoundOffAmount,@InvRefNum,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)                      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                        
End                        
Else If @RoundOffAmount <0                        
Begin                        
 Set @RoundOffAmount=Abs(@RoundOffAmount)                        
 -- Get the last TransactionID from the DocumentNumbers table                        
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24                        
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
 Commit Tran                        
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51                        
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
 Commit Tran                        
 -- Entry for Customer Account                        
 execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@RoundOffAmount,0,@InvRefNum,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber   
 -- Entry for RoundOff Account                        
 execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,0,@RoundOffAmount,@InvRefNum,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)                      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)                      
End                        
----------------------------Reversal Entries for Sec Schemes---------------------------------------              
Set @SecSchemeValue = 0 -- Set the value to zero            
--DECLARE scanScheme CURSOR KEYSET FOR                        
--Select Type from SchemeSale where InvoiceId=@InvRefNum And IsNull(SaleType,0) = 0 Group By Type                        
--OPEN scanScheme                        
--FETCH FROM scanScheme INTO @SchType                        
--While @@FETCH_STATUS=0                        
--Begin                        
-- Select @SecScheme=IsNull(SecondaryScheme,0),@SchemeType=IsNull(SchemeType,0) from Schemes where SchemeID=IsNull(@SchType,0)                        
-- If IsNull(@SecScheme,0)<>0                        
-- Begin                        
--  If IsNull(@SchemeType,0) =19 -- Item based percentage scheme type                        
--  Begin                        
--   Select @SecSchemeValue= IsNull(@SecSchemeValue,0) + (Select Sum((isnull(Cost,0)*isnull(Value,0))/100) from SchemeSale where InvoiceId=@InvRefNum and Type=@SchType And IsNull(SaleType,0) = 0 group by Type)                        
--  End                        
--  Else                        
--  Begin                        
--   Select @SecSchemeValue=IsNull(@SecSchemeValue,0) + (Select Sum(isnull(Cost,0)) from SchemeSale where InvoiceId=@InvRefNum and Type=@SchType And IsNull(SaleType,0) = 0 group by Type)                        
--  End                        
-- End                        
-- FETCH NEXT FROM scanScheme INTO @SchType                        
--End                  
--CLOSE scanScheme                        
--DEALLOCATE scanScheme                        
--                  
--/*Add Invoice Based Secondary Scheme Values to the @SecSchemeValue Variable*/                  
--Select @SchemeID = IsNull(SchemeID,0), @SchemeDiscountValue = IsNull(SchemeDiscountAmount,0) from InvoiceAbstract Where InvoiceID = @InvRefNum                        
--Select @SecScheme = IsNull(SecondaryScheme,0) from Schemes where SchemeID = @SchemeID                  
--If IsNull(@SecScheme,0) <> 0                  
--Begin                  
-- Set @SecSchemeValue = IsNull(@SecSchemeValue,0) + IsNull(@SchemeDiscountValue,0)                  
--End                  
--

-- Begin: New Code for Schemes -37939
DECLARE scanScheme CURSOR KEYSET FOR                
Select SchemeID from tbl_mERP_SchemeSale where InvoiceId=@InvRefNum And IsNull(SaleType,0) = 0 Group By SchemeID
OPEN scanScheme                
FETCH FROM scanScheme INTO @Type1                
While @@FETCH_STATUS=0                
Begin                
 Select @SecScheme=IsNull(RFAApplicable,0)  from tbl_mERP_SchemeAbstract where SchemeID=IsNull(@Type1,0)                
 If IsNull(@SecScheme,0)<>0                
  Begin                
   Select @SecSchemeValue=IsNull(@SecSchemeValue,0) + (Select Sum(isnull(SChemeValue,0)) from tbl_mERP_SchemeSale where InvoiceId=@InvRefNum and SChemeID=@Type1 And IsNull(SaleType,0) = 0 group by SchemeID)                
  End                
 FETCH NEXT FROM scanScheme INTO @Type1                
End                
CLOSE scanScheme                
DEALLOCATE scanScheme                
          
/*Add Invoice Based Secondary Scheme Values to the @SecSchemeValue Variable*/          
-- Select @SchemeID = IsNull(SchemeID,0), @SchemeDiscountValue = IsNull(SchemeDiscountAmount,0) from InvoiceAbstract Where InvoiceID = @InvoiceID                

--Select @SchemeDiscountValue = IsNull(SchemeDiscountAmount,0) from InvoiceAbstract Where InvoiceID = @InvRefNum                
--Create table #TScheme1(SchemeID int)
--Select @InvSchemeID = InvoiceSchemeID from InvoiceAbstract Where InvoiceID = @InvRefNum                
--Truncate table #TScheme1 
--Insert Into #TScheme1 
--Select * from dbo.sp_SplitIn2Rows(@InvSchemeID, ',')
--Select @SchID = SchemeID  from #TScheme1 Order By 1 
--
--Select @SecScheme = IsNull(RFAApplicable,0) from tbl_mERP_SchemeAbstract where SchemeID = @SchID
--If IsNull(@SecScheme,0) <> 0          
--Begin          
-- Set @SecSchemeValue = IsNull(@SecSchemeValue,0) + IsNull(@SchemeDiscountValue,0)          
--End          
--Drop table #TScheme1
-- End: New Code for Schemes -37939


/*Add Invoice Based Secondary Scheme Values to the @SecSchemeValue Variable - Changed - ITC Phase III*/  
Create Table #tmpSch2(RowID Int Identity(1,1),SchemeDetail nVarchar(250))

Set @SchemeDiscountValue = 0

Select @MultiSchDet = isNull(MultipleSchemeDetails,'')  From InvoiceAbstract Where InvoiceID = @InvRefNum
If @MultiSchDet <> ''
Begin
		Truncate table #tmpSch2	
		Insert Into #tmpSch2
		Select * from dbo.sp_SplitIn2Rows(@MultiSchDet,@Delimeter)	
		Select @RecCnt = Count(*) From #tmpSch2 
		Set @i = 1
		While @i <= @RecCnt
		Begin
			
			Set @SchDet = ''			
			Set @SchmID = 0
			Set @szSchAmnt = 0
			Set @SlabID = 0
			Set @SchAmnt = 0
			Set @SecScheme = 0


			Select @SchDet =isNull(SchemeDetail,'') From #tmpSch2 Where RowID = @i

			Set @SchmID = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
			Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet)+1,len(@SchDet))
			Set @SlabID = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)
			Set @SchDet = Substring(@SchDet,Charindex('|',@SchDet) + 1,len(@SchDet))
			Set @szSchAmnt = Substring(@SchDet,1,Charindex('|',@SchDet) - 1)

			if (Charindex('E+',@szSchAmnt) > 0  Or Charindex('E-',@szSchAmnt) > 0)
				set @SchAmnt = convert(decimal(18,6), str(@szSchAmnt, 18, 6))
			Else
				set @SchAmnt = @szSchAmnt
		

 			Select @SecScheme=IsNull(RFAApplicable,0)  from tbl_mERP_SchemeAbstract where SchemeID=IsNull(@SchmID,0)   
			If  @SecScheme = 1 
			Begin
				Set @SchemeDiscountValue = isNull(@SchemeDiscountValue,0) + isNull(@SchAmnt,0)
			End
		
			Set @i = @i + 1
		End
		Drop Table #tmpSch2
End

Set @SecSchemeValue = IsNull(@SecSchemeValue,0) + IsNull(@SchemeDiscountValue,0)   

/*Ends: Add Invoice Based Secondary Scheme Values to the @SecSchemeValue Variable - Changed - ITC Phase III*/         


If @SecSchemeValue<>0                        
Begin                       
 -- Get the last TransactionID from the DocumentNumbers table                        
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24                        
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24                        
 Commit Tran                        
 begin tran                        
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51                        
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51                        
 Commit Tran                        
 -- Entry for ClaimsRecivable Account                        
 execute sp_acc_insertGJ @TransactionID,@ClaimsRecivable,@InvoiceDate,@SecSchemeValue,0,@InvRefNum,@AccountType,"Secondary Scheme",@DocumentNumber                        
 -- Entry for SecondarySchemeExpense Account           
 execute sp_acc_insertGJ @TransactionID,@SecondarySchemeExpense,@InvoiceDate,0,@SecSchemeValue,@InvRefNum,@AccountType,"Secondary Scheme",@DocumentNumber                        
 Insert Into #TempBackdatedAccounts(AccountID) Values(@ClaimsRecivable)                      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@SecondarySchemeExpense)                      
End         
---------------Credit/Debit Note cancellation journal entries for original invoice-----------                
Declare @ReferenceID Int,@Type Int                        
If exists(Select ReferenceID From AdjustmentReference Where InvoiceID = @InvRefNum And IsNull(TransactionType,0) = 0)                        
Begin                        
 DECLARE scanadjustmentreference CURSOR KEYSET FOR                        
 Select ReferenceID, DocumentType from AdjustmentReference where InvoiceID = @InvRefNum And IsNull(TransactionType,0) = 0                        
 OPEN scanadjustmentreference                        
 FETCH FROM scanadjustmentreference INTO @ReferenceID,@Type                        
 WHILE @@FETCH_STATUS=0                        
 Begin                        
  If @Type=5 -- Debit Note                        
  Begin                        
   Exec sp_acc_gj_debitnoteCancel @ReferenceID,@BackDate  
  End                        
  Else If @Type=2 -- Credit Note                        
  Begin                        
   Exec sp_acc_gj_creditnoteCancel @ReferenceID,@BackDate  
  End                        
  FETCH NEXT FROM scanadjustmentreference INTO @ReferenceID,@Type                        
 End                        
 CLOSE scanadjustmentreference                        
 DEALLOCATE scanadjustmentreference                        
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
Drop Table #GSTaxCalcAmend --GST_Changes
