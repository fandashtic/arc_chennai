CREATE Procedure sp_acc_gj_existinvoice (@INVOICEID INT,@BackDate DATETIME=Null)      
AS  -- Journal entry for Invoice      
Declare @InvoiceDate datetime      
Declare @NetValue float      
Declare @TaxAmount float      
Declare @TotalSalesTax decimal(18,6)      
Declare @TotalTaxSuffered decimal(18,6)      
Declare @AccountID int      
Declare @CustomerID nvarchar(15)      
Declare @TransactionID int      
Declare @PaymentMode int      
Declare @CollectionID int      
Declare @CollectionType int      
Declare @DispatchType int      
Declare @DispatchCancelType int      
Declare @DocumentNumber Int      
Declare @Freight Decimal(18,6)      
--Declare @ReferenceNumber nVarchar(255)      
Declare @Status Int      
Declare @RoundOffAmount Decimal(18,6)      
Declare @NetBalance Decimal(18,6)      
Declare @PaymentDetails Int      
Declare @ColValue Decimal(18,6)      
          
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
Set @AccountType =4      
      
set @CollectionType =13      
set @DispatchType =44      
set @DispatchCancelType =45      
      
--PaymentMode Types      
Declare @CASH INT      
Declare @CHEQUE INT      
Declare @CREDIT INT      
Declare @DD INT      
Set @CASH=1      
SET @CREDIT=0      
Set @Cheque=2      
Set @DD=3      
      
--Declare @SEP as Varchar(15)      
--Set @SEP=','      
      
Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation      
      
Select @InvoiceDate=InvoiceDate, @NetValue=IsNull(NetValue,0), @TotalSalesTax=IsNull(TotalTaxApplicable,0),      
@TradeDiscount = isnull(DiscountValue,0),@AdditionalDiscount = isnull(AddlDiscountValue,0),@ItemDiscount = isnull(ProductDiscount,0),          
@TotalTaxSuffered=IsNull(TotalTaxSuffered,0), @CustomerID=CustomerID,@PaymentMode=PaymentMode,      
@CollectionID = cast(PaymentDetails as int),@Freight=isnull(Freight,0),@InvSchemeDiscountAmount = IsNull(SchemeDiscountAmount,0),    
@Status=isnull(Status,0),@RoundOffAmount=isnull(RoundOffAmount,0) from InvoiceAbstract where InvoiceID=@InvoiceID      
    
Select @ItmSchemeDiscountAmount = Sum(IsNull(SchemeDiscAmount,0) + IsNull(SplCatDiscAmount,0)) from InvoiceDetail Where InvoiceID = @InvoiceID            
-- Tax Computation from InvoiceDetail table      
--Select @TaxAmount=Sum((isnull(STPayable,0)+isnull(CSTPayable,0))+((isnull(SalePrice,0)*isnull(Quantity,0))*(isnull(TaxSuffered,0)/100))) from InvoiceDetail where InvoiceID=@InvoiceID      
Set @TaxAmount=@TotalSalesTax+@TotalTaxsuffered      
-- Get AccountID of the customer from Customer master      
Select @AccountID=AccountID from Customer where CustomerID=@CustomerID      
      
Declare @SalesValue float      
SET @SalesValue=@NetValue-IsNull(@TaxAmount,0)-@Freight      
      
Declare @Value float,@RefID Int      
Declare @AccountID7 int      
Declare @AccountID8 int      
Set @AccountID7 = 28 --Bills Received Account      
Set @AccountID8 = 35 --Sales On DC Account      
      
--Reverse entry to close dispatch      
If (@Status & 1)<>0 -- invoice from dispatch      
Begin      
 DECLARE scanDispatch CURSOR KEYSET FOR      
 Select DispatchID from DispatchAbstract where InvoiceID=@INVOICEID      
 OPEN scanDispatch      
 FETCH FROM scanDispatch INTO @RefID      
 While @@FETCH_STATUS=0      
 Begin      
  If IsNull(@RefID,0) <> 0      
  Begin      
   Select @Value=sum(isnull(Quantity,0)*isnull(SalePrice,0)) from DispatchDetail where DispatchID = @RefID      
   If IsNull(@Value,0) <> 0      
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
    --Reverse entry to close dispatch      
    --Exec sp_acc_gj_dispatchcancel @ReferenceNumber      
    -- Entry for Sales on DC Account          
    execute sp_acc_insertGJ @TransactionID,@AccountID8,@InvoiceDate,@Value,0,@RefID,@DispatchCancelType,"Invoice from Dispatch",@DocumentNumber      
    -- Entry for Bills Receivable Account      
    execute sp_acc_insertGJ @TransactionID,@AccountID7,@InvoiceDate,0,@Value,@RefID,@DispatchCancelType,"Invoice from Dispatch",@DocumentNumber      
    Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID8)      
    Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID7)      
   End      
  End      
  FETCH NEXT FROM scanDispatch INTO @RefID       
 End      
 CLOSE ScanDispatch      
 DEALLOCATE ScanDispatch      
End      
Else      
Begin      
 DECLARE scanDispatch CURSOR KEYSET FOR      
 Select DispatchID from DispatchAbstract where InvoiceID=@INVOICEID      
 OPEN scanDispatch      
 FETCH FROM scanDispatch INTO @RefID      
 While @@FETCH_STATUS=0      
 Begin      
  If IsNull(@RefID,0) <> 0      
  Begin      
   Select @Value=sum(isnull(Quantity,0)*isnull(SalePrice,0)) from DispatchDetail where DispatchID = @RefID      
   If IsNull(@Value,0) <> 0      
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
    --Entry for implicit dispatch      
    --Exec sp_acc_gj_dispatch @ReferenceNumber      
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
    --Reverse entry to close implicit dispatch      
    --Exec sp_acc_gj_dispatchcancel @ReferenceNumber      
    -- Entry for Sales on DC Account      
    execute sp_acc_insertGJ @TransactionID,@AccountID8,@InvoiceDate,@Value,0,@RefID,@DispatchCancelType,"Close Implicit Dispatch",@DocumentNumber      
    -- Entry for Bills Receivable Account      
    execute sp_acc_insertGJ @TransactionID,@AccountID7,@InvoiceDate,0,@Value,@RefID,@DispatchCancelType,"Close Implicit Dispatch",@DocumentNumber      
    Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID8)      
    Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID7)      
   End      
  End      
  FETCH NEXT FROM scanDispatch INTO @RefID       
 End      
 CLOSE ScanDispatch      
 DEALLOCATE ScanDispatch      
End      
-- Get the last TransactionID from the DocumentNumbers table      
begin tran      
 update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24      
 Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
Commit Tran      
begin tran      
 update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51      
 Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
Commit Tran      
      
If @PaymentMode = @CREDIT      
Begin      
 If @NetValue<>0      
 Begin      
  -- Entry for Customer Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@NetValue,0,@InvoiceID,@AccountType,"Credit Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)      
 End      
 If @TotalSalesTax<>0      
 Begin      
  -- Entry for Sales Tax Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,0,@TotalSalesTax,@InvoiceID,@AccountType,"Credit Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)      
 End      
 If @TotalTaxSuffered<>0      
 Begin      
  -- Entry for Sales Tax Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,0,@TotalTaxSuffered,@InvoiceID,@AccountType,"Credit Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)      
 End      
 If @Freight<>0      
 Begin      
  -- Entry for Freight Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,0,@Freight,@InvoiceID,@AccountType,"Credit Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)      
 End      
 If @SalesValue<>0      
 Begin      
  -- Entry for Sales Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@SalesValue,@InvoiceID,@AccountType,"Credit Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)      
 End      
End      
Else if @PaymentMode=@CASH      
Begin      
 If @NetValue<>0      
 Begin      
  -- Entry for Customer Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@NetValue,0,@InvoiceID,@AccountType,"Cash Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)      
 End      
 If @TotalSalesTax<>0      
 Begin       
  -- Entry for Sales Tax Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,0,@TotalSalesTax,@InvoiceID,@AccountType,"Cash Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)      
 End      
 If @TotalTaxSuffered<>0      
 Begin       
  -- Entry for Sales Tax Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,0,@TotalTaxSuffered,@InvoiceID,@AccountType,"Cash Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)      
 End      
 If @Freight<>0      
 Begin       
  -- Entry for Freight Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,0,@Freight,@InvoiceID,@AccountType,"Cash Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)      
 End      
 If @SalesValue<>0      
 Begin      
  -- Entry for Sales Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@SalesValue,@InvoiceID,@AccountType,"Cash Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)      
 End      
 -- Get the last TransactionID from the DocumentNumbers table      
 begin tran      
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24      
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
 Commit Tran      
 begin tran      
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51      
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
 Commit Tran      
      
 SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @INVOICEID) as int)      
 select @ColValue=isnull(Value,0) from collections Where DocumentID = @PaymentDetails      
 Insert into TempImplicitCollection(ColDocumentID) Values (@PaymentDetails) --This is to avoid journal entry posting in collections      
--  If @RoundOffAmount <> 0      
--  Begin      
--   Set @NetBalance=@NetValue + @RoundOffAmount      
--  End      
--  Else       
--  Begin      
--   Set @NetBalance=@NetValue      
--  End        
--       
--  If @NetValue<>0      
--  Begin       
--   -- Entry for Cash Account      
--   execute sp_acc_insertGJ @TransactionID,@AccountID1,@InvoiceDate,@NetBalance,0,@CollectionID,@CollectionType,"Cash Invoice",@DocumentNumber      
--  End      
--  If @NetValue <> 0       
--  Begin      
--   -- Entry for Customer Account      
--   execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@NetBalance,@CollectionID,@CollectionType,"Cash Invoice",@DocumentNumber      
--  End      
  If @ColValue<>0      
  Begin       
   -- Entry for Cash Account      
   execute sp_acc_insertGJ @TransactionID,@AccountID1,@InvoiceDate,@ColValue,0,@CollectionID,@CollectionType,"Cash Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)      
  End      
  If @ColValue <> 0       
  Begin      
   -- Entry for Customer Account      
   execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@ColValue,@CollectionID,@CollectionType,"Cash Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)      
  End      
End      
Else If (@PaymentMode=@CHEQUE or @PaymentMode=@DD)      
Begin      
 If @NetValue<>0      
 Begin      
  -- Entry for Customer Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@NetValue,0,@InvoiceID,@AccountType,"Cheque/DD Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)      
 End      
 If @TotalSalesTax<>0      
 Begin      
  -- Entry for Sales Tax Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,0,@TotalSalesTax,@InvoiceID,@AccountType,"Cheque/DD Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)      
 End      
 If @TotalTaxSuffered<>0      
 Begin      
  -- Entry for Sales Tax Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,0,@TotalTaxSuffered,@InvoiceID,@AccountType,"Cheque/DD Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)      
 End      
 If @Freight<>0      
 Begin      
  -- Entry for Freight Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,0,@Freight,@InvoiceID,@AccountType,"Cheque/DD Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)      
 End      
 If @SalesValue<>0      
 Begin      
  -- Entry for Sales Account      
  execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@SalesValue,@InvoiceID,@AccountType,"Cheque/DD Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)      
 End      
 -- Get the last TransactionID from the DocumentNumbers table      
 begin tran      
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24      
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
 Commit Tran      
 begin tran      
  update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51      
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
 Commit Tran      
      
 SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @INVOICEID) as int)      
 select @ColValue=isnull(Value,0) from collections Where DocumentID = @PaymentDetails      
 Insert into TempImplicitCollection(ColDocumentID) Values (@PaymentDetails) --This is to avoid journal entry posting in collections      
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
--   -- Entry for Cheque on Hand Account      
--   execute sp_acc_insertGJ @TransactionID,@AccountID4,@InvoiceDate,@NetBalance,0,@CollectionID,@CollectionType,"Cheque/DD Invoice",@DocumentNumber      
--  End      
--  If @NetValue<>0      
--  Begin      
--   -- Entry for Customer Account      
--   execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@NetBalance,@CollectionID,@CollectionType,"Cheque/DD Invoice",@DocumentNumber      
--  End      
  If @ColValue<>0      
  Begin      
   -- Entry for Cheque on Hand Account      
   execute sp_acc_insertGJ @TransactionID,@AccountID4,@InvoiceDate,@ColValue,0,@CollectionID,@CollectionType,"Cheque/DD Invoice",@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID4)      
  End      
  If @ColValue<>0      
  Begin      
   -- Entry for Customer Account      
   execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@ColValue,@CollectionID,@CollectionType,"Cheque/DD Invoice",@DocumentNumber      
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
  Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,@TotalDiscount,0,@InvoiceID,@AccountType,"Invoice - Discount On Sales",@DocumentNumber          
  --Entry for Sales Account          
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@TotalDiscount,@InvoiceID,@AccountType,"Invoice - Discount On Sales",@DocumentNumber          
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
  Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@TotalDiscount,0,@InvoiceID,@AccountType,"Invoice - Discount On Sales",@DocumentNumber          
  --Entry for Discount Account          
  Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,0,@TotalDiscount,@InvoiceID,@AccountType,"Invoice - Discount On Sales",@DocumentNumber          
  --Update #TempBackdatedAccounts for Backdation Purpose          
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesDiscountAccount)          
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)          
 End          
--------------------------------------------------------------------------------------------          
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
