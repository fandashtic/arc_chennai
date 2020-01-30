CREATE Procedure sp_acc_gj_salesreturncancellation(@INVOICEID INT,@BackDate DATETIME=Null)  
AS  
--Journal entries for Sales Return Cancellation  
Declare @InvoiceDate datetime  
Declare @NetValue float  
Declare @TaxAmount float  
Declare @TotalSalesTax decimal(18,6)  
Declare @TotalTaxSuffered decimal(18,6)  
Declare @AccountID int  
Declare @CustomerID nvarchar(15)  
Declare @Status Int  
Declare @TransactionID int  
Declare @DocumentNumber Int  
Declare @Freight Decimal(18,6)  
Declare @RoundOffAmount Decimal(18,6)  
  
Declare @TradeDiscount Decimal(18,6)      
Declare @AdditionalDiscount Decimal(18,6)      
Declare @ItemDiscount Decimal(18,6)      
Declare @TotalDiscount Decimal(18,6)      
Declare @InvSchemeDiscountAmount Decimal(18,6)          
Declare @ItmSchemeDiscountAmount Decimal(18,6)          

Declare @SalesDiscountAccount Int      
Set @SalesDiscountAccount = 107 --Discount On Sales A/c      
  
Declare @AccountID2 int  
Declare @AccountID3 int  
Declare @AccountID5 int  
Declare @AccountID6 int  
--Set @AccountID3 = 30  --Sales Return Account  
Set @AccountID2 = 1  --SalesTax Account  
Set @AccountID5 = 29 --Tax Suffered Account  
Set @AccountID6 = 33 --Freight Account  
  
Declare @AccountType Int  
Set @AccountType =40 --SalesReturnCancellation  

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
declare @GSTEnable int,
		@GSTCount int , 
		@Rowid int, 
		@GST_Payable int, 
		@GSTaxComponent int ,
		@nGSTaxAmt decimal(18,6),
		@invabs_gstflag int			

select @GSTEnable = isnull(flag,0) 
from tbl_merp_configabstract(nolock)
where screencode = 'GSTaxEnabled'  

create table #gstaxcalc  --for gs tax calculation
(	id int identity(1,1), 
	invoiceid int,
	tax_component_code int, 
	tax_value decimal(18,6),
	gst_flag  int
)
--GST_Changes ends here
  
If @Vat_Exists  = 1
Begin
	Select @InvoiceDate=InvoiceDate, @NetValue=IsNull(NetValue,0), @TotalSalesTax=IsNull(TotalTaxApplicable,0)- isnull(VATTaxAmount,0),
	@TradeDiscount = isnull(DiscountValue,0),@AdditionalDiscount = isnull(AddlDiscountValue,0),@ItemDiscount = isnull(ProductDiscount,0),      
	@TotalTaxSuffered=IsNull(TotalTaxSuffered,0), @CustomerID=CustomerID,@Status = IsNull(Status,0),@InvSchemeDiscountAmount = IsNull(SchemeDiscountAmount,0),
	@Freight=isnull(Freight,0),@RoundOffAmount=isnull(RoundOffAmount,0) ,
	@nVatTaxamount = isnull(VATTaxAmount,0), @invabs_gstflag = GSTFlag --GST_Changes
	from InvoiceAbstract where InvoiceID=@INVOICEID  
End
Else
Begin
	Select @InvoiceDate=InvoiceDate, @NetValue=IsNull(NetValue,0), @TotalSalesTax=IsNull(TotalTaxApplicable,0),
	@TradeDiscount = isnull(DiscountValue,0),@AdditionalDiscount = isnull(AddlDiscountValue,0),@ItemDiscount = isnull(ProductDiscount,0),      
	@TotalTaxSuffered=IsNull(TotalTaxSuffered,0), @CustomerID=CustomerID,@Status = IsNull(Status,0),@InvSchemeDiscountAmount = IsNull(SchemeDiscountAmount,0),
	@Freight=isnull(Freight,0),@RoundOffAmount=isnull(RoundOffAmount,0), @invabs_gstflag = GSTFlag from InvoiceAbstract where InvoiceID=@INVOICEID --GST_Changes
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
	on(		tx.Tax_Code			= iv.Tax_Code
	and		isnull(tx.GSTFlag,0)= 1
	)
	where invoiceid = @invoiceid
	group by tax_component_code,invoiceid,tx.GSTFlag	
end
--GST_Changes ends here

Select @ItmSchemeDiscountAmount = Sum(IsNull(SchemeDiscAmount,0) + IsNull(SplCatDiscAmount,0)) from InvoiceDetail Where InvoiceID = @INVOICEID          
-- Tax Computation from InvoiceDetail table  
--Select @TaxAmount=Sum((isnull(STPayable,0)+isnull(CSTPayable,0))+((isnull(SalePrice,0)*isnull(Quantity,0))*(isnull(TaxSuffered,0)/100))) from InvoiceDetail where InvoiceID=@INVOICEID  
Set @TaxAmount=IsNull(@TotalSalesTax,0)+IsNull(@TotalTaxsuffered,0)  
-- Get AccountID of the customer from Customer master  
Select @AccountID=AccountID from Customer where CustomerID=@CustomerID  
  
If (isnull(@status,0) & 32)<>0  
 Set @AccountID3 = 32  --Sales Return - Damage  
Else  
 Set @AccountID3 = 30  --Sales Return - Saleable  
  
Declare @SalesValue float

If @Vat_Exists  = 1
Begin
	SET @SalesValue= IsNull(@NetValue,0)-IsNull(@TaxAmount,0)-IsNull(@Freight,0)  - isnull(@nVatTaxamount,0)
End
Else
Begin          
	SET @SalesValue= IsNull(@NetValue,0)-IsNull(@TaxAmount,0)-IsNull(@Freight,0)
End

-- To get the new TransactionID for GJ entry  
Begin Tran  
 update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=24  
 Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24  
Commit Tran  
-- To get the new DocumentNumber for GJ entry  
Begin Tran  
 update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=51  
 Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51  
Commit Tran  
-- Procedure to insert journal entries for Sales Return Cancellation in GJ table.  
If @NetValue<>0  
Begin  
 -- Entry for customer account  
 Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@NetValue,0,@INVOICEID,@AccountType,"Sales Return Cancellation",@DocumentNumber  
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)  
End  
  
--If @TotalSalesTax<>0  
--Begin  
-- -- Entry for Sales tax account  
-- Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,0,@TotalSalesTax,@INVOICEID,@AccountType,"Sales Return Cancellation",@DocumentNumber  
-- Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)  
--End  
If @TotalTaxSuffered<>0  
Begin  
 -- Entry for Sales tax account  
 Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,0,@TotalTaxSuffered,@INVOICEID,@AccountType,"Sales Return Cancellation",@DocumentNumber  
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
					execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,0,@nGSTaxAmt,@InvoiceID,@AccountType,"Sales Return Cancellation",@DocumentNumber                
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
				
		if ((@nVatTaxamount <> 0 ) and (isnull(@gst_payable,0) > 0))
		begin 
			execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,0,@nVatTaxamount,@InvoiceID,@AccountType,"VAT Sales Return Cancellation",@DocumentNumber                
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
		Execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,0,@nVatTaxamount,@INVOICEID,@AccountType,"Sales Return Cancellation",@DocumentNumber  
		Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)  
	end
End

If @Freight<>0  
Begin  
 -- Entry for Sales tax account  
 Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,0,@Freight,@INVOICEID,@AccountType,"Sales Return Cancellation",@DocumentNumber  
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)  
End  
If @SalesValue<>0  
Begin  
 -- Entry for Sales account  
 Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@SalesValue,@INVOICEID,@AccountType,"Sales Return Cancellation",@DocumentNumber  
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)  
End  
-----------------------------------Entry for Discount Account----------------------------------      
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
   Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,@TotalDiscount,0,@InvoiceID,@AccountType,"Retail Invoice - Discount On Sales",@DocumentNumber      
   --Entry for Sales Account      
   Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@TotalDiscount,@InvoiceID,@AccountType,"Retail Invoice - Discount On Sales",@DocumentNumber      
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
   Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@TotalDiscount,0,@InvoiceID,@AccountType,"Retail Invoice - Discount On Sales",@DocumentNumber      
   --Entry for Discount Account      
   Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,0,@TotalDiscount,@InvoiceID,@AccountType,"Retail Invoice - Discount On Sales",@DocumentNumber      
   --Update #TempBackdatedAccounts for Backdation Purpose      
   Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesDiscountAccount)      
   Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)      
  End      
-----------------------------------------------------------------------------------------------    
Declare @RoundOffAccount Int  
Set @RoundOffAccount=92  
  
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
 Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@RoundOffAmount,0,@INVOICEID,@AccountType,"Sales Return Cancellation - RoundOff Amount",@DocumentNumber  
 -- Entry for RoundOff Account  
 Execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,0,@RoundOffAmount,@INVOICEID,@AccountType,"Sales Return Cancellation - RoundOff Amount",@DocumentNumber  
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
 -- Entry for RoundOff Account  
 execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@AccountType,"Sales Return Cancellation - RoundOff Amount",@DocumentNumber  
 -- Entry for Customer Account  
 execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@AccountType,"Sales Return Cancellation - RoundOff Amount",@DocumentNumber  
 Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)  
 Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)  
End  
-------------------------------------Entry for Schemes----------------------------------------
/* Commented for Central Scheme implementation*/
/*
Declare @SecSchemeValue Decimal(18,6),@SchemeDiscountValue Decimal(18,6)        
Declare @SecondarySchemeExpense Int,@ClaimsRecivable Int              
Declare @Type Int,@SecScheme Int,@SchemeType Int,@SchemeID Int        
Set @SecondarySchemeExpense = 39              
Set @ClaimsRecivable = 10              
              
DECLARE scanScheme CURSOR KEYSET FOR              
Select Type from SchemeSale where InvoiceId=@InvoiceId And IsNull(SaleType,0) = 0 Group By Type              
OPEN scanScheme              
FETCH FROM scanScheme INTO @Type              
While @@FETCH_STATUS=0              
Begin              
 Select @SecScheme=IsNull(SecondaryScheme,0),@SchemeType=IsNull(SchemeType,0) from Schemes where SchemeID=IsNull(@Type,0)              
 If IsNull(@SecScheme,0)<>0              
 Begin              
  If IsNull(@SchemeType,0) =19 -- Item based percentage scheme type              
  Begin              
   Select @SecSchemeValue= IsNull(@SecSchemeValue,0) + (Select Sum((isnull(Cost,0)*isnull(Value,0))/100) from SchemeSale where InvoiceId=@InvoiceId and Type=@Type And IsNull(SaleType,0) = 0 group by Type)              
  End              
  Else              
  Begin              
   Select @SecSchemeValue=IsNull(@SecSchemeValue,0) + (Select Sum(isnull(Cost,0)) from SchemeSale where InvoiceId=@InvoiceId and Type=@Type And IsNull(SaleType,0) = 0 group by Type)              
  End              
 End              
 FETCH NEXT FROM scanScheme INTO @Type              
End              
CLOSE scanScheme              
DEALLOCATE scanScheme              
        
/*Add Invoice Based Secondary Scheme Values to the @SecSchemeValue Variable*/        
Select @SchemeID = IsNull(SchemeID,0), @SchemeDiscountValue = IsNull(SchemeDiscountAmount,0) from InvoiceAbstract Where InvoiceID = @InvoiceID              
Select @SecScheme = IsNull(SecondaryScheme,0) from Schemes where SchemeID = @SchemeID        
Set @SecSchemeValue = ABS(@SecSchemeValue)
Set @SchemeDiscountValue = ABS(@SchemeDiscountValue)
If IsNull(@SecScheme,0) <> 0        
Begin        
 Set @SecSchemeValue = IsNull(@SecSchemeValue,0) + IsNull(@SchemeDiscountValue,0)      
End 
*/

-- Begin: New Code for Central Schemes -37939
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

Select @SchemeDiscountValue = IsNull(SchemeDiscountAmount,0) from InvoiceAbstract Where InvoiceID = @InvoiceID                

Create table #TScheme(SchemeID int)
Select @InvSchemeID = InvoiceSchemeID from InvoiceAbstract Where InvoiceID = @InvoiceId
Truncate table #TScheme 
Insert Into #TScheme 
Select * from dbo.sp_SplitIn2Rows(@InvSchemeID, ',')
Select @SchID = SchemeID  from #TScheme Order By 1 

Select @SecScheme = IsNull(RFAApplicable,0) from tbl_mERP_SchemeAbstract where SchemeID = @SchID
If IsNull(@SecScheme,0) <> 0          
Begin          
 Set @SecSchemeValue = IsNull(@SecSchemeValue,0) + IsNull(@SchemeDiscountValue,0)          
End          
Drop table #TScheme
-- End: New Code for Central Schemes -37939
        
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
 -- Entry for ClaimsRecivable Account              
 execute sp_acc_insertGJ @TransactionID,@ClaimsRecivable,@InvoiceDate,0,@SecSchemeValue,@InvoiceID,@AccountType,"Secondary Scheme",@DocumentNumber              

 Insert Into #TempBackdatedAccounts(AccountID) Values(@SecondarySchemeExpense)              
 Insert Into #TempBackdatedAccounts(AccountID) Values(@ClaimsRecivable)              
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
