CREATE Procedure sp_acc_gj_RetailInvoiceOld(@INVOICEID INT,@BackDate DATETIME=Null)              
AS -- Journal entry for Retail Invoice              
Declare @InvoiceDate datetime              
Declare @NetValue float              
Declare @TaxAmount float              
Declare @TotalSalesTax decimal(18,6)              
Declare @TotalTaxSuffered decimal(18,6)              
Declare @AccountID int              
Declare @TransactionID int              
Declare @DocumentNumber int              
Declare @UserName nVarchar(15)              
Declare @PaymentDetails nVarchar(255)              
Declare @AmountRecd Decimal(18,6)              
Declare @ServiceChargeDetails nVarchar(255)              
Declare @RoundOffAmount Decimal(18,6)              
            
Declare @RoundOffAccount Int              
Set @RoundOffAccount=92              
              
Declare @RetailCustomer Int              
Set @RetailCustomer=93              
              
Declare @TradeDiscount Decimal(18,6)                
Declare @AdditionalDiscount Decimal(18,6)                
Declare @ItemDiscount Decimal(18,6)                
Declare @TotalDiscount Decimal(18,6)                
Declare @InvSchemeDiscountAmount Decimal(18,6)                  
Declare @ItmSchemeDiscountAmount Decimal(18,6)                  
            
Declare @SalesDiscountAccount Int                
Set @SalesDiscountAccount = 107 --Discount On Sales A/c                
              
Declare @AccountID1 int              
Declare @AccountID2 int              
Declare @AccountID3 int              
Declare @AccountID5 int              
Set @AccountID1 = 3  --Cash Account              
Set @AccountID3 = 5  --Sales Account              
Set @AccountID2 = 1  --SalesTax Account              
Set @AccountID5 = 29 --Tax Suffered Account              
Declare @AccountType Int              
Set @AccountType =1              

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
              
            
Select @ItmSchemeDiscountAmount = Sum(IsNull(SchemeDiscAmount,0) + IsNull(SplCatDiscAmount,0)) from InvoiceDetail Where InvoiceID = @InvoiceID                  
-- Tax Computation from InvoiceDetail table              
--Select @TaxAmount=Sum((isnull(STPayable,0)+isnull(CSTPayable,0))+((isnull(SalePrice,0)*isnull(Quantity,0))*(isnull(TaxSuffered,0)/100))) from InvoiceDetail where InvoiceID=@InvoiceID              
If @Vat_Exists  = 1
Begin
	Select @InvoiceDate=InvoiceDate, @NetValue=IsNull(NetValue,0),@TotalSalesTax=IsNull(TotalTaxApplicable,0)-isnull(VATTaxAmount,0) ,              
	@TradeDiscount = isnull(DiscountValue,0),@AdditionalDiscount = isnull(AddlDiscountValue,0),@ItemDiscount = isnull(ProductDiscount,0),                
	@TotalTaxSuffered=IsNull(TotalTaxSuffered,0), @RoundOffAmount=isnull(RoundOffAmount,0),@InvSchemeDiscountAmount = IsNull(SchemeDiscountAmount,0),            
	@UserName=UserName,@PaymentDetails=PaymentDetails,@ServiceChargeDetails=ServiceCharge,@AmountRecd = isnull(AmountRecd,0),
	@nVatTaxamount = isnull(VATTaxAmount,0) 
	from InvoiceAbstract where InvoiceID=@InvoiceID              

	Set @TaxAmount=@TotalSalesTax+@TotalTaxsuffered + @nVatTaxamount
End
Else
Begin
	Select @InvoiceDate=InvoiceDate, @NetValue=IsNull(NetValue,0),@TotalSalesTax=IsNull(TotalTaxApplicable,0),              
	@TradeDiscount = isnull(DiscountValue,0),@AdditionalDiscount = isnull(AddlDiscountValue,0),@ItemDiscount = isnull(ProductDiscount,0),                
	@TotalTaxSuffered=IsNull(TotalTaxSuffered,0), @RoundOffAmount=isnull(RoundOffAmount,0),@InvSchemeDiscountAmount = IsNull(SchemeDiscountAmount,0),            
	@UserName=UserName,@PaymentDetails=PaymentDetails,@ServiceChargeDetails=ServiceCharge,@AmountRecd = isnull(AmountRecd,0)              
	from InvoiceAbstract where InvoiceID=@InvoiceID              

	Set @TaxAmount=@TotalSalesTax+@TotalTaxsuffered              
End
----New Implementation of retail invoice-----------              
 Create Table #TempFirstSplit(FirstSplitRecords nVarchar(4000))              
 Create Table #TempSecondSplit(SecondSplitRecords nVarchar(4000))              
 Create Table #DynamicPaymentTable(PaymentMode nVarchar(150),AmtRecd Decimal(18,6),Detail nVarchar(255),AmtReturned Decimal(18,6))              
 Declare @FirstSplitRecords nVarchar(4000)              
 Declare @SecondSplitRecords nVarchar(4000)              
 Declare @Flag Int              
 Declare @Local as nVarchar(250)              
 Declare @ColumnCount Int              
              
 Set @Flag=0              
 Set @ColumnCount=1              
              
 Declare @FIRSTSPLIT nVarchar(15),@SECONDSPLIT nVarchar(15)              
 Set @FIRSTSPLIT = N';'              
 Set @SECONDSPLIT = N':'              
              
 Declare @SumAmtRecd Decimal(18,6),@SumAmtReturned Decimal(18,6),@AccountName nVarchar(255),@GroupID Int,@NewAccountID Int              
 Declare @AdjustedAmount Decimal(18,6),@ExtraAmount Decimal(18,6),@PaymentID Int,@PaymentType Int            
 Declare @PayMode nVarchar(150),@AmtRecd Decimal(18,6),@Detail nVarchar(255),@AmtReturned Decimal(18,6)              
 Declare @CASHTYPE Int,@CHEQUETYPE Int,@CREDITCARDTYPE Int,@COUPONTYPE Int,@OTHERSTYPE INT              
 Set @CASHTYPE=1              
 Set @CHEQUETYPE=2              
 Set @CREDITCARDTYPE=3           
 Set @COUPONTYPE=4              
 Set @OTHERSTYPE=5              
              
 Insert #TempFirstSplit              
 Exec Sp_acc_SQLSplit @PaymentDetails,@FIRSTSPLIT              
 --Select * From #TempAssetRow              
 DECLARE scantempfirst CURSOR KEYSET FOR              
 select FirstSplitRecords from #TempFirstSplit               
 OPEN scantempfirst              
 FETCH FROM scantempfirst INTO @FirstSplitRecords              
 WHILE @@FETCH_STATUS =0              
 BEGIN              
  Insert #TempSecondSplit              
  Exec Sp_acc_SQLSplit @FirstSplitRecords,@SECONDSPLIT              
              
  DECLARE scantempsecond CURSOR KEYSET FOR              
  select SecondSplitRecords from #TempSecondSplit               
  OPEN scantempsecond              
  FETCH FROM scantempsecond INTO @SecondSplitRecords              
  WHILE @@FETCH_STATUS =0              
  BEGIN              
   If @Flag=0              
   Begin              
    Insert #DynamicPaymentTable Values(@SecondSplitRecords,0,0,0)              
    Set @Flag=1              
    Set @Local=@SecondSplitRecords              
    Set @ColumnCount=@ColumnCount+1              
   End              
   Else              
   Begin              
    If @ColumnCount=2              
     Update #DynamicPaymentTable Set AmtRecd=Cast(@SecondSplitRecords as Decimal(18,6)) where PaymentMode=@Local              
    Else If @ColumnCount=3              
     Update #DynamicPaymentTable Set Detail=@SecondSplitRecords where PaymentMode=@Local              
    Else If @ColumnCount=4              
     Update #DynamicPaymentTable Set AmtReturned=Cast(@SecondSplitRecords as Decimal(18,6)) where PaymentMode=@Local              
    Set @ColumnCount=@ColumnCount+1              
   End              
   FETCH NEXT FROM scantempsecond INTO @SecondSplitRecords              
  END              
  CLOSE scantempsecond              
  DEALLOCATE scantempsecond              
  Set @Flag=0              
  Set @local=Null              
  Delete #TempSecondSplit              
  Set @ColumnCount=1              
  FETCH NEXT FROM scantempfirst INTO @FirstSplitRecords              
 END              
 CLOSE scantempfirst              
 DEALLOCATE scantempfirst              
---------------------------Service Charge implementation-----------------------              
 Delete #TempFirstSplit               
 Create Table #DynamicServiceChargeTable(PaymentMode nVarchar(150),ServiceCharge Decimal(18,6))              
              
 Set @Flag=0              
 Set @ColumnCount=1              
              
 Declare @SumServiceCharge Decimal(18,6)              
 Declare @ServiceCharge Decimal(18,6)              
              
 Insert #TempFirstSplit              
 Exec Sp_acc_SQLSplit @ServiceChargeDetails,@FIRSTSPLIT              
 --Select * From #TempAssetRow              
 DECLARE scantempfirstsc CURSOR KEYSET FOR              
 select FirstSplitRecords from #TempFirstSplit               
 OPEN scantempfirstsc              
 FETCH FROM scantempfirstsc INTO @FirstSplitRecords              
 WHILE @@FETCH_STATUS =0              
 BEGIN              
  Insert #TempSecondSplit              
  Exec Sp_acc_SQLSplit @FirstSplitRecords,@SECONDSPLIT              
              
  DECLARE scantempsecondsc CURSOR KEYSET FOR              
  select SecondSplitRecords from #TempSecondSplit               
  OPEN scantempsecondsc              
  FETCH FROM scantempsecondsc INTO @SecondSplitRecords              
  WHILE @@FETCH_STATUS =0              
  BEGIN              
   If @Flag=0              
   Begin              
 Insert #DynamicServiceChargeTable Values(@SecondSplitRecords,0)              
    Set @Flag=1              
    Set @Local=@SecondSplitRecords              
    Set @ColumnCount=@ColumnCount+1              
   End              
   Else              
   Begin              
    If @ColumnCount=2              
     Update #DynamicServiceChargeTable Set ServiceCharge=Cast(@SecondSplitRecords as Decimal(18,6)) where PaymentMode=@Local              
   End              
   FETCH NEXT FROM scantempsecondsc INTO @SecondSplitRecords              
  END              
  CLOSE scantempsecondsc              
  DEALLOCATE scantempsecondsc              
  Set @Flag=0              
  Set @local=Null       
  Delete #TempSecondSplit              
  Set @ColumnCount=1              
  FETCH NEXT FROM scantempfirstsc INTO @FirstSplitRecords              
 END              
 CLOSE scantempfirstsc              
 DEALLOCATE scantempfirstsc              
-------------------------------------------------------------------------------              
-- Get the last TransactionID from the DocumentNumbers table              
begin tran              
 update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24              
 Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24              
Commit Tran              
begin tran              
 update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51              
 Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51              
Commit Tran              
              
Declare @SalesValue float              
SET @SalesValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0)              
If @NetValue >0              
Begin              
--Retail Invoice              
 If @NetValue<>0              
 Begin              
  -- Entry for Retail Customer Account              
  execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,@NetValue,0,@InvoiceID,@AccountType,"Retail Invoice",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
 End              
 If @TotalSalesTax<>0              
 Begin              
  -- Entry for Sales Tax Account              
  execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,0,@TotalSalesTax,@InvoiceID,@AccountType,"Retail Invoice",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)              
 End              
 If @TotalTaxSuffered<>0              
 Begin              
  -- Entry for Sales Tax Account              
  execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,0,@TotalTaxSuffered,@InvoiceID,@AccountType,"Retail Invoice",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)              
 End              

 If @Vat_Exists = 1
 Begin
 	if @nVatTaxamount <> 0  
 	begin  
  		-- Entry for VAT Tax Account              
		execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,0,@nVatTaxamount,@InvoiceID,@AccountType,"Retail Invoice",@DocumentNumber              
		Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)              
	end
 End

 If @SalesValue<>0              
 Begin              
  -- Entry for Sales Account              
  execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@SalesValue,@InvoiceID,@AccountType,"Retail Invoice",@DocumentNumber              
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
  -- Entry for Retail Customer Account              
  execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@AccountType,"Retail Invoice-RoundOff Amount",@DocumentNumber              
  -- Entry for RoundOff Account              
  execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@AccountType,"Retail Invoice-RoundOff Amount",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
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
  execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@AccountType,"Retail Invoice-RoundOff Amount",@DocumentNumber              
  -- Entry for Retail Customer Account              
  execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@AccountType,"Retail Invoice-RoundOff Amount",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
  Set @RoundOffAmount=0-Abs(@RoundOffAmount)              
 End              
 -----------------------------------For Secondary Scheme-------------------------------------      
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
 If IsNull(@SecScheme,0) <> 0                
 Begin                
  Set @SecSchemeValue = IsNull(@SecSchemeValue,0) + IsNull(@SchemeDiscountValue,0)                
 End                
            
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
  -- Entry for SecondarySchemeExpense Account              
  execute sp_acc_insertGJ @TransactionID,@SecondarySchemeExpense,@InvoiceDate,@SecSchemeValue,0,@InvoiceID,@AccountType,"Retail Invoice - Secondary Scheme",@DocumentNumber              
  -- Entry for Customer Account              
  execute sp_acc_insertGJ @TransactionID,@ClaimsRecivable,@InvoiceDate,0,@SecSchemeValue,@InvoiceID,@AccountType,"Retail Invoice - Secondary Scheme",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SecondarySchemeExpense)              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@ClaimsRecivable)              
 End              
---------------------------------------------------------------------------------------------      
 -- Get the last TransactionID from the DocumentNumbers table              
 begin tran              
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24              
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24              
 Commit Tran              
 begin tran              
 update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51              
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51              
 Commit Tran              
              
 DECLARE scandynamictable CURSOR KEYSET FOR              
 Select PaymentMode,AmtRecd,Detail,AmtReturned from #DynamicPaymentTable              
 OPEN scandynamictable              
 FETCH FROM scandynamictable INTO @PayMode,@AmtRecd,@Detail,@AmtReturned              
 WHILE @@FETCH_STATUS =0              
 BEGIN              
  Select @PaymentID=Mode,@PaymentType=isnull(PaymentType,0) from PaymentMode where Value=@PayMode               
  Set @SumAmtRecd=isnull(@SumAmtRecd,0) + isnull(@AmtRecd,0)              
  --Set @SumAmtReturned=isnull(@SumAmtReturned,0) + isnull(@AmtReturned,0)              
  If isnull(@AmtRecd,0) <> 0              
  Begin              
   If Not exists(Select top 1 AccountID from AccountsMaster where UserName=@Username and RetailPaymentMode=@PaymentID)              
   Begin              
    Set @AccountName=@PayMode + N'-' + @UserName              
                  
    If @PaymentType =@CASHTYPE              
     Set @GROUPID=19 --Cashinhand account group               
    Else If @PaymentType =@CHEQUETYPE               
     Set @GROUPID=20 --Chequesinhand account group              
    Else If @PaymentType =@CREDITCARDTYPE              
     Set @GROUPID=50 --CreditCardsinHand account group               
    Else If @PaymentType =@COUPONTYPE              
     Set @GROUPID=51 --Couponsinhand account group                  
    Else If @PaymentType =@OTHERSTYPE               
     Set @GROUPID=52 --Othersinhand account group                 
            
    Exec sp_acc_insertaccounts @AccountName,@GROUPID,0              
    Set @NewAccountID=@@Identity              
    Update AccountsMaster Set UserName =@UserName,RetailPaymentMode=@PaymentID where AccountID=@NewAccountID                 
   End              
   Else              
   Begin               
    Select @NewAccountID=AccountID from AccountsMaster where UserName=@Username and RetailPaymentMode=@PaymentID              
   End              
   -- Entry for new payment accounts  Account              
   execute sp_acc_insertGJ @TransactionID,@NewAccountID,@InvoiceDate,@AmtRecd,0,@InvoiceID,@AccountType,"Retail Invoice",@DocumentNumber              
   Insert Into #TempBackdatedAccounts(AccountID) Values(@NewAccountID)              
  End              
  FETCH NEXT FROM scandynamictable INTO @PayMode,@AmtRecd,@Detail,@AmtReturned               
 END              
 CLOSE scandynamictable              
 DEALLOCATE scandynamictable              
 If @SumAmtRecd <>0              
 Begin              
  -- Entry for Retail Customer Account              
  execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,0,@SumAmtRecd,@InvoiceID,@AccountType,"Retail Invoice",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)              
 End              
 --NetValue + Roundoff value < AmountReceived then shortage amount              
 If (@Netvalue + @RoundOffAmount) > @SumAmtRecd              
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
  Set @AdjustedAmount = (@Netvalue + @RoundOffAmount) - @SumAmtRecd              
  -- Entry for Discount Account              
  execute sp_acc_insertGJ @TransactionID,13,@InvoiceDate,@AdjustedAmount,0,@InvoiceID,@AccountType,"Retail Invoice",@DocumentNumber --13 ->DiscountAccount              
  -- Entry for Retail Customer Account              
  execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,0,@AdjustedAmount,@InvoiceID,@AccountType,"Retail Invoice",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(13)              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
 End              
 Else If (@Netvalue + @RoundOffAmount) < @SumAmtRecd              
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
               
  DECLARE scandynamictable2 CURSOR KEYSET FOR              
  Select PaymentMode,AmtRecd,Detail,AmtReturned from #DynamicPaymentTable              
  OPEN scandynamictable2              
  FETCH FROM scandynamictable2 INTO @PayMode,@AmtRecd,@Detail,@AmtReturned              
  WHILE @@FETCH_STATUS =0              
  BEGIN              
   Select @PaymentID=Mode,@PaymentType=isnull(PaymentType,0) from PaymentMode where Value=@PayMode               
   Set @SumAmtReturned=isnull(@SumAmtReturned,0) + isnull(@AmtReturned,0)              
   If isnull(@AmtReturned,0) <>0              
   Begin              
    If Not exists(Select top 1 AccountID from AccountsMaster where UserName=@Username and RetailPaymentMode=@PaymentID)              
    Begin              
     Set @AccountName=@PayMode + N'-' + @UserName               
     If @PaymentType =@CASHTYPE              
      Set @GROUPID=19 --Cashinhand account group               
     Else If @PaymentType =@CHEQUETYPE               
      Set @GROUPID=20 --Chequesinhand account group              
     Else If @PaymentType =@CREDITCARDTYPE              
      Set @GROUPID=50 --CreditCardsinHand account group               
     Else If @PaymentType =@COUPONTYPE              
      Set @GROUPID=51 --Couponsinhand account group                  
     Else If @PaymentType =@OTHERSTYPE               
      Set @GROUPID=52 --Othersinhand account group                 
            
     Exec sp_acc_insertaccounts @AccountName,@GROUPID,0              
     Set @NewAccountID=@@Identity              
     Update AccountsMaster Set UserName =@UserName,RetailPaymentMode=@PaymentID where AccountID=@NewAccountID              
    End              
    Else              
    Begin               
     Select @NewAccountID=AccountID from AccountsMaster where UserName=@Username and RetailPaymentMode=@PaymentID              
    End              
    -- Entry for new payment Account              
    execute sp_acc_insertGJ @TransactionID,@NewAccountID,@InvoiceDate,0,@AmtReturned,@InvoiceID,@AccountType,"Retail Invoice",@DocumentNumber              
    Insert Into #TempBackdatedAccounts(AccountID) Values(@NewAccountID)               
   End              
   FETCH NEXT FROM scandynamictable2 INTO @PayMode,@AmtRecd,@Detail,@AmtReturned               
  END              
  CLOSE scandynamictable2              
  DEALLOCATE scandynamictable2       
              
  If @SumAmtReturned <>0              
  Begin              
   -- Entry for Retail Customer Account              
   execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,@SumAmtReturned,0,@InvoiceID,@AccountType,"Retail Invoice",@DocumentNumber              
   Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
  End              
 End              
------------------------------Service Charge journal entries-----------------------------              
 -- Get the last TransactionID from the DocumentNumbers table              
 begin tran              
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24              
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24              
 Commit Tran              
 begin tran              
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51              
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51              
 Commit Tran              
              
 Declare @CashSC Decimal(18,6),@ChequeSC Decimal(18,6),@CreditCardSC Decimal(18,6)       
 Declare @CouponSC Decimal(18,6),@OthersSC Decimal(18,6)              
            
 DECLARE scanscdynamictable CURSOR KEYSET FOR              
 Select PaymentMode,ServiceCharge from #DynamicServiceChargeTable              
 OPEN scanscdynamictable              
 FETCH FROM scanscdynamictable INTO @PayMode,@ServiceCharge              
 WHILE @@FETCH_STATUS =0              
 BEGIN              
  Select @PaymentID=Mode,@PaymentType=isnull(PaymentType,0) from PaymentMode where Value=@PayMode               
  Set @SumServiceCharge=isnull(@SumServiceCharge,0) + isnull(@ServiceCharge,0)              
  If isnull(@ServiceCharge,0)<>0              
  Begin              
   If @PaymentType =@CASHTYPE              
    --Set @NewAccountID=101 --Cash Service Charge account              
    Set @CashSC = IsNull(@CashSC,0) + @ServiceCharge              
   Else If @PaymentType =@CHEQUETYPE               
    --Set @NewAccountID=102 --Cheque Service Charge account              
    Set @ChequeSC = IsNull(@ChequeSC,0) + @ServiceCharge              
   Else If @PaymentType =@CREDITCARDTYPE              
    --Set @NewAccountID=103 --CreditCard Service Charge account              
    Set @CreditCardSC = IsNull(@CreditCardSC,0) + @ServiceCharge              
   Else If @PaymentType =@COUPONTYPE              
    --Set @NewAccountID=104 --Coupon Service Charge account              
    Set @CouponSC = IsNull(@CouponSC,0) + @ServiceCharge              
   Else If @PaymentType =@OTHERSTYPE               
    --Set @NewAccountID=105 --Other Service Charge account              
    Set @OthersSC = IsNull(@OthersSC,0) + @ServiceCharge              
   -- Entry for new payment accounts  Account              
   --execute sp_acc_insertGJ @TransactionID,@NewAccountID,@InvoiceDate,0,@ServiceCharge,@InvoiceID,@AccountType,"Retail Invoice-Service Charge",@DocumentNumber              
   --Insert Into #TempBackdatedAccounts(AccountID) Values(@NewAccountID)              
  End              
  FETCH NEXT FROM scanscdynamictable INTO @PayMode,@ServiceCharge              
 END              
 CLOSE scanscdynamictable              
 DEALLOCATE scanscdynamictable              
            
 If IsNull(@CashSc,0)<>0              
 Begin              
  execute sp_acc_insertGJ @TransactionID,101,@InvoiceDate,0,@CashSc,@InvoiceID,@AccountType,"Retail Invoice-Service Charge",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(101) --Cash Service Charge account              
 End              
 If IsNull(@ChequeSc,0)<>0              
 Begin              
  execute sp_acc_insertGJ @TransactionID,102,@InvoiceDate,0,@ChequeSc,@InvoiceID,@AccountType,"Retail Invoice-Service Charge",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(102) --Cheque Service Charge account              
 End              
 If IsNull(@CreditCardSc,0)<>0             
 Begin              
  execute sp_acc_insertGJ @TransactionID,103,@InvoiceDate,0,@CreditCardSc,@InvoiceID,@AccountType,"Retail Invoice-Service Charge",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(103) --Credit Card Service Charge account              
 End              
 If IsNull(@CouponSc,0)<>0              
 Begin              
  execute sp_acc_insertGJ @TransactionID,104,@InvoiceDate,0,@CouponSc,@InvoiceID,@AccountType,"Retail Invoice-Service Charge",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(104) --Coupon Service Charge account              
 End              
 If IsNull(@OthersSc,0)<>0              
 Begin              
  execute sp_acc_insertGJ @TransactionID,105,@InvoiceDate,0,@OthersSc,@InvoiceID,@AccountType,"Retail Invoice-Service Charge",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(105) --Others Service Charge account              
 End              
 If @SumServiceCharge <>0              
 Begin              
  -- Entry for Retail Customer Account              
  execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,@SumServiceCharge,0,@InvoiceID,@AccountType,"Retail Invoice-Service Charge",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
 End              
 Set @CashSC=0              
 Set @ChequeSC=0              
 Set @CreditCardSC=0              
 Set @CouponSC=0              
 Set @OthersSC=0              
End              
----------------------------------------------------------------------------------------------------      
Else if @Netvalue<0 --Retail Invoice Salese Return               
Begin              
 Set @NetValue=abs(@NetValue)              
 Set @TotalSalesTax = abs(@TotalSalesTax)              
 Set @TotalTaxSuffered = abs(@TotalTaxSuffered)              
 Set @SalesValue = abs(@SalesValue)              
               
 If @Vat_Exists = 1
 Begin
	Set @nVatTaxamount = abs(@nVatTaxamount)
 End

 If @NetValue<>0              
 Begin              
  -- Entry for Retail Customer Account              
  execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,0,@NetValue,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
 End              
 If @TotalSalesTax<>0              
 Begin              
  -- Entry for Sales Tax Account              
  execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,@TotalSalesTax,0,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)              
 End              
 If @TotalTaxSuffered<>0              
 Begin         
  -- Entry for Tax Suffered Account              
  execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,@TotalTaxSuffered,0,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)              
 End    
          
 If @Vat_Exists = 1
 Begin
 	if @nVatTaxamount <> 0  
 	begin  
  		-- Entry for VAT Tax Account              
		execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,@nVatTaxamount,0,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber              
		Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)              
	end
 End

 If @SalesValue<>0              
 Begin              
  -- Entry for Sales Account              
  execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@SalesValue,0,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)              
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
   Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,@TotalDiscount,0,@InvoiceID,@AccountType,"Retail Invoice - Discount On Sales",@DocumentNumber                
   --Entry for Discount Account                
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
   --Entry for Discount Account                
   Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@TotalDiscount,0,@InvoiceID,@AccountType,"Retail Invoice - Discount On Sales",@DocumentNumber                
   --Entry for Sales Account                
   Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,0,@TotalDiscount,@InvoiceID,@AccountType,"Retail Invoice - Discount On Sales",@DocumentNumber                
   --Update #TempBackdatedAccounts for Backdation Purpose                
   Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesDiscountAccount)                
   Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)                
  End                
--------------------------------------------------------------------------------------------                  
 If @RoundOffAmount <0              
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
  execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@AccountType,"Retail Invoice Return-RoundOff Amount",@DocumentNumber              
  -- Entry for Retail Customer Account              
  execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@AccountType,"Retail Invoice Return-RoundOff Amount",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)              
  Set @RoundOffAmount=0-Abs(@RoundOffAmount)              
 End              
 Else If @RoundOffAmount >0              
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
  -- Entry for Retail Customer Account              
  execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@AccountType,"Retail Invoice Return-RoundOff Amount",@DocumentNumber              
  -- Entry for RoundOff Account              
  execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@AccountType,"Retail Invoice Return-RoundOff Amount",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
 End              
              
---------------------------------------For Secondary Scheme----------------------------------        
/*Code Temporarily Commented
 Set @SecSchemeValue = 0              
              
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
  
 Select @SchemeID = IsNull(SchemeID,0), @SchemeDiscountValue = IsNull(SchemeDiscountAmount,0) from InvoiceAbstract Where InvoiceID = @InvoiceID                      
 Select @SecScheme = IsNull(SecondaryScheme,0) from Schemes where SchemeID = @SchemeID                
 If IsNull(@SecScheme,0) <> 0                
 Begin                
  Set @SecSchemeValue = IsNull(@SecSchemeValue,0) + IsNull(@SchemeDiscountValue,0)                
 End                
            
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
  execute sp_acc_insertGJ @TransactionID,@ClaimsRecivable,@InvoiceDate,@SecSchemeValue,0,@InvoiceID,@AccountType,"Retail Invoice - Secondary Scheme",@DocumentNumber              
  -- Entry for SecondarySchemeExpense Account   
  execute sp_acc_insertGJ @TransactionID,@SecondarySchemeExpense,@InvoiceDate,0,@SecSchemeValue,@InvoiceID,@AccountType,"Retail Invoice - Secondary Scheme",@DocumentNumber              
 End              
*/
---------------------------------------------------------------------------------------------              
 -- Get the last TransactionID from the DocumentNumbers table              
 begin tran              
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24              
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24              
 Commit Tran              
 begin tran              
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51              
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51              
 Commit Tran              
              
 DECLARE scandynamictable1 CURSOR KEYSET FOR              
 Select PaymentMode,AmtRecd,Detail,AmtReturned from #DynamicPaymentTable              
 OPEN scandynamictable1              
 FETCH FROM scandynamictable1 INTO @PayMode,@AmtRecd,@Detail,@AmtReturned              
 WHILE @@FETCH_STATUS =0              
 BEGIN              
  Select @PaymentID=Mode,@PaymentType=isnull(PaymentType,0) from PaymentMode where Value=@PayMode               
  --Set @SumAmtRecd=isnull(@SumAmtRecd,0) + isnull(@AmtRecd,0)              
  Set @SumAmtReturned=isnull(@SumAmtReturned,0) + isnull(@AmtReturned,0)              
  If isnull(@AmtReturned,0) <> 0              
  Begin              
   If Not exists(Select top 1 AccountID from AccountsMaster where UserName=@Username and RetailPaymentMode=@PaymentID)              
   Begin              
    Set @AccountName=@PayMode + N'-' + @UserName               
                  
    If @PaymentType =@CASHTYPE              
     Set @GROUPID=19 --Cashinhand account group               
    Else If @PaymentType =@CHEQUETYPE               
     Set @GROUPID=20 --Chequesinhand account group              
    Else If @PaymentType =@CREDITCARDTYPE              
     Set @GROUPID=50 --CreditCardsinHand account group               
    Else If @PaymentType =@COUPONTYPE              
     Set @GROUPID=51 --Couponsinhand account group                  
    Else If @PaymentType =@OTHERSTYPE               
     Set @GROUPID=52 --Othersinhand account group                 
    --insert              
    Exec sp_acc_insertaccounts @AccountName,@GROUPID,0              
    Set @NewAccountID=@@Identity              
    Update AccountsMaster Set UserName =@UserName,RetailPaymentMode=@PaymentID where AccountID=@NewAccountID                 
   End              
   Else              
   Begin               
    Select @NewAccountID=AccountID from AccountsMaster where UserName=@Username and RetailPaymentMode=@PaymentID              
   End              
   -- Entry for new payment accounts  Account              
   execute sp_acc_insertGJ @TransactionID,@NewAccountID,@InvoiceDate,0,@AmtReturned,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber              
   Insert Into #TempBackdatedAccounts(AccountID) Values(@NewAccountID)              
  End              
  FETCH NEXT FROM scandynamictable1 INTO @PayMode,@AmtRecd,@Detail,@AmtReturned               
 END              
 CLOSE scandynamictable1              
 DEALLOCATE scandynamictable1       
              
 If @SumAmtReturned <>0              
 Begin              
  -- Entry for Retail Customer Account              
  execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,@SumAmtReturned,0,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber              
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)              
 End              
 --NetValue + Roundoff value < AmountReceived then shortage amount              
 If ((0-Abs(@Netvalue)) + @RoundOffAmount) > (0-@SumAmtReturned)              
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
  Set @AdjustedAmount = ((0-Abs(@Netvalue)) + @RoundOffAmount) - (0-@SumAmtReturned)              
  If IsNull(@AdjustedAmount,0)<>0              
  Begin              
   Set @AdjustedAmount=Abs(@AdjustedAmount)              
   -- Entry for Retail Customer Account              
   execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,@AdjustedAmount,0,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber              
   -- Entry for Discount Account              
   execute sp_acc_insertGJ @TransactionID,13,@InvoiceDate,0,@AdjustedAmount,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber --13 ->DiscountAccount              
   Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
   Insert Into #TempBackdatedAccounts(AccountID) Values(13)              
  End              
 End              
 Else If ((0-Abs(@Netvalue)) + @RoundOffAmount) < (0-@SumAmtReturned)              
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
               
  Set @SumAmtRecd=0              
  DECLARE scandynamictable2 CURSOR KEYSET FOR              
  Select PaymentMode,AmtRecd,Detail,AmtReturned from #DynamicPaymentTable              
  OPEN scandynamictable2              
  FETCH FROM scandynamictable2 INTO @PayMode,@AmtRecd,@Detail,@AmtReturned              
  WHILE @@FETCH_STATUS =0              
  BEGIN              
   Select @PaymentID=Mode,@PaymentType=isnull(PaymentType,0) from PaymentMode where Value=@PayMode               
   Set @SumAmtRecd=isnull(@SumAmtRecd,0) + isnull(@AmtRecd,0)              
   If isnull(@AmtRecd,0) <>0              
   Begin              
    If Not exists(Select top 1 AccountID from AccountsMaster where UserName=@Username and RetailPaymentMode=@PaymentID)              
    Begin              
     Set @AccountName=@PayMode + N'-' + @UserName               
     If @PaymentType =@CASHTYPE              
      Set @GROUPID=19 --Cashinhand account group               
     Else If @PaymentType =@CHEQUETYPE               
      Set @GROUPID=20 --Chequesinhand account group              
     Else If @PaymentType =@CREDITCARDTYPE              
      Set @GROUPID=50 --CreditCardsinHand account group               
     Else If @PaymentType =@COUPONTYPE              
      Set @GROUPID=51 --Couponsinhand account group                  
     Else If @PaymentType =@OTHERSTYPE               
      Set @GROUPID=52 --Othersinhand account group                 
      
     Exec sp_acc_insertaccounts @AccountName,@GROUPID,0              
     Set @NewAccountID=@@Identity              
     Update AccountsMaster Set UserName =@UserName,RetailPaymentMode=@PaymentID where AccountID=@NewAccountID              
    End              
    Else              
    Begin               
     Select @NewAccountID=AccountID from AccountsMaster where UserName=@Username and RetailPaymentMode=@PaymentID              
    End              
    -- Entry for new payment Account              
    execute sp_acc_insertGJ @TransactionID,@NewAccountID,@InvoiceDate,@AmtRecd,0,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber        
    Insert Into #TempBackdatedAccounts(AccountID) Values(@NewAccountID)               
   End              
   FETCH NEXT FROM scandynamictable2 INTO @PayMode,@AmtRecd,@Detail,@AmtReturned               
  END              
  CLOSE scandynamictable2              
  DEALLOCATE scandynamictable2              
              
  If @SumAmtRecd <>0              
  Begin 
   -- Entry for Retail Customer Account              
   execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,0,@SumAmtRecd,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber              
   Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
  End              
--   -- Get the last TransactionID from the DocumentNumbers table              
--   begin tran              
--    update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24              
--    Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24              
--   Commit Tran              
--   begin tran              
--    update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51              
--    Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51              
--   Commit Tran              
--   Set @ExtraAmount = (Abs(@Netvalue) + @RoundOffAmount) - @SumAmtReturned              
--   -- Entry for OtherCharges Account              
--   execute sp_acc_insertGJ @TransactionID,14,@InvoiceDate,@ExtraAmount,0,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber --14 ->OtherChargesAccount           
--   -- Entry for Retail Customer Account              
--   execute sp_acc_insertGJ @TransactionID,@RetailCustomer,@InvoiceDate,0,@ExtraAmount,@InvoiceID,@AccountType,"Retail Invoice Return",@DocumentNumber              
--   Insert Into #TempBackdatedAccounts(AccountID) Values(14)              
--   Insert Into #TempBackdatedAccounts(AccountID) Values(@RetailCustomer)              
 End              
-------------------------------------------------------------------------              
End               
----------------New implememtation of Retail Invoice---------------------              
Drop Table #TempFirstSplit              
Drop Table #TempSecondSplit              
Drop Table #DynamicPaymentTable  
-------------------------------------------------------------------------              
              
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



