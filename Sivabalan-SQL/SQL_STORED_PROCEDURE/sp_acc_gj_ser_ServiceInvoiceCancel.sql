CREATE Procedure sp_acc_gj_ser_ServiceInvoiceCancel(@InvoiceID Int,@BackDate Datetime=Null)      
AS      
---------------------Journal entry for Service Invoice Cancellation------------------------------  
DECLARE @InvoiceDate Datetime      
DECLARE @NetValue float      
DECLARE @TaxAmount float      
DECLARE @TotalSalesTax Decimal(18,6)      
DECLARE @TotalServiceTax Decimal(18,6)  
DECLARE @TotalTaxSuffered Decimal(18,6)      
DECLARE @CustomerID nVarchar(15)      
DECLARE @Customer_AccountID Int      
DECLARE @TransactionID Int      
DECLARE @PaymentMode Int      
DECLARE @CollectionID Int      
DECLARE @DocumentNumber Int      
DECLARE @Freight Decimal(18,6)      
DECLARE @Status Int      
DECLARE @IsVAT_Exists Int
DECLARE @RoundOffAmount Decimal(18,6)      
DECLARE @NetBalance Decimal(18,6)      
DECLARE @ColValue Decimal(18,6)      
DECLARE @Customer_Service_Charge Decimal(18,6)  
DECLARE @TradeDiscount_Sales Decimal(18,6)      
DECLARE @AdditionalDiscount_Sales Decimal(18,6)      
DECLARE @TradeDiscount_Service Decimal(18,6)  
DECLARE @AdditionalDiscount_Service Decimal(18,6)  
DECLARE @ItemDiscount Decimal(18,6)      
DECLARE @TotalDiscount_Sales Decimal(18,6)      
DECLARE @TotalDiscount_Service Decimal(18,6)      
DECLARE @VAT_TaxAmount Decimal(18,6)      
DECLARE @SalesValue float      
DECLARE @ServiceValue float  
      
DECLARE @CASH_ACCOUNT Int      
DECLARE @SALESTAX_ACCOUNT Int      
DECLARE @SALES_ACCOUNT Int      
DECLARE @CHEQUEONHAND_ACCOUNT Int      
DECLARE @TAXSUFFERED_ACCOUNT Int      
DECLARE @FREIGHT_ACCOUNT Int      
DECLARE @BILLSRECEIVABLE_ACCOUNT Int      
DECLARE @SALESONDC_ACCOUNT Int      
DECLARE @SERVICE_ACCOUNT Int  
DECLARE @SERVICETAX_ACCOUNT Int  
DECLARE @DISCOUNT_ON_SERVICE_ACCOUNT Int  
DECLARE @SALESDISCOUNT_ACCOUNT Int      
DECLARE @ROUNDOFF_ACCOUNT Int      
DECLARE @SECONDARY_SCHEME_EXPENSE_ACCOUNT Int  
DECLARE @CLAIMS_RECEIVABLE_ACCOUNT Int      
DECLARE @CREDITCARD_ACCOUNT Int  
DECLARE @CREDITCARD_SERVICECHARGE_ACCOUNT Int  
DECLARE @COUPON_ACCOUNT Int
DECLARE @COUPON_SERVICECHARGE_ACCOUNT Int
DECLARE @VAT_TAXPAYABLE_ACCOUNT Int
  
SET @CASH_ACCOUNT = 3  -- Cash Account      
SET @SALESTAX_ACCOUNT = 1  -- SalesTax Account      
SET @SALES_ACCOUNT = 5  -- Sales Account      
SET @CHEQUEONHAND_ACCOUNT = 7  -- Cheque on Hand      
SET @TAXSUFFERED_ACCOUNT = 29 -- Tax Suffered Account      
SET @FREIGHT_ACCOUNT = 33 -- Freight Account      
SET @BILLSRECEIVABLE_ACCOUNT = 28 -- Bills Received Account      
SET @SALESONDC_ACCOUNT = 35 -- Sales On DC Account      
SET @SERVICE_ACCOUNT = 109 -- Service Account  
SET @SERVICETAX_ACCOUNT = 110 -- Service Tax Account  
SET @DISCOUNT_ON_SERVICE_ACCOUNT = 111 -- Discount On Service Account  
SET @SALESDISCOUNT_ACCOUNT = 107 -- Discount On Sales A/c      
SET @ROUNDOFF_ACCOUNT=92 -- RoundOff Account  
SET @SECONDARY_SCHEME_EXPENSE_ACCOUNT = 39 -- Secondary Scheme Expense Account  
SET @CLAIMS_RECEIVABLE_ACCOUNT = 10 -- Claims Receivable Account  
SET @CREDITCARD_ACCOUNT = 94 -- Credit Card Account  
SET @CREDITCARD_SERVICECHARGE_ACCOUNT = 103 -- Credit Card Service Charge Account  
SET @COUPON_ACCOUNT = 95 -- COUPON Account
SET @COUPON_SERVICECHARGE_ACCOUNT = 104 -- COUPON Service Charge Account
SET @VAT_TAXPAYABLE_ACCOUNT = 116 -- VAT Payable (Output Tax) Account
  
DECLARE @ISSUE_TYPE Int      
DECLARE @ISSUE_TYPE_CANCEL Int      
DECLARE @SERVICEINVOICE_TYPE_CANCEL Int      
DECLARE @COLLECTION_TYPE Int      
DECLARE @TASK_TYPE Int  
DECLARE @SPARE_TYPE Int  
DECLARE @JOB_TYPE Int  
  
SET @SERVICEINVOICE_TYPE_CANCEL = 89      
SET @ISSUE_TYPE = 85      
SET @ISSUE_TYPE_CANCEL = 86  
SET @COLLECTION_TYPE = 13      
SET @JOB_TYPE = 1  
SET @TASK_TYPE = 2  
SET @SPARE_TYPE = 3  
      
DECLARE @CASH_MODE Int      
DECLARE @CHEQUE_MODE Int      
DECLARE @CREDIT_MODE Int      
DECLARE @DD_MODE Int      
DECLARE @CREDITCARD_MODE Int  
DECLARE @COUPON_MODE INT
  
SET @CASH_MODE = 1      
SET @CREDIT_MODE = 0      
SET @CHEQUE_MODE = 2      
SET @DD_MODE = 3      
SET @CREDITCARD_MODE = 4  
SET @COUPON_MODE = 5
  
If dbo.columnexists('ServiceInvoiceAbstract','VATTaxAmount_Spares') = 1
 Set @IsVat_Exists = 1
Else
 Set @IsVat_Exists = 0

Create Table #TempBackdatedAccounts(AccountID Int)   

If @IsVat_Exists = 1
 Begin
  Select @InvoiceDate = ServiceInvoiceDate, @NetValue = NetValue, @CustomerID = CustomerID,  
  @TotalSalesTax=(IsNull(TotalTaxApplicable,0)-IsNULL(VATTaxAmount_Spares,0)),@TotalServiceTax=IsNull(TotalServiceTax,0),   
  @TotalTaxSuffered=IsNull(TotalTaxSuffered,0),@PaymentMode=PaymentMode,@TradeDiscount_Sales=IsNull(TradeDiscountValue_Spare,0),  
  @AdditionalDiscount_Sales=IsNull(AdditionalDiscountValue_Spare,0),@ItemDiscount=IsNull(ItemDiscount,0),  
  @TradeDiscount_Service=IsNull(TradeDiscountValue_Task,0),@AdditionalDiscount_Service=IsNull(AdditionalDiscountValue_Task,0),  
  @Freight=IsNull(Freight,0),@Status=IsNull(Status,0),@RoundOffAmount=IsNull(RoundOffAmount,0),@VAT_TaxAmount=IsNULL(VATTaxAmount_Spares,0)
  from ServiceInvoiceAbstract where ServiceInvoiceID = @InvoiceID  
 End
Else
 Begin
  Select @InvoiceDate = ServiceInvoiceDate, @NetValue = NetValue, @CustomerID = CustomerID,  
  @TotalSalesTax = IsNull(TotalTaxApplicable,0), @TotalServiceTax = IsNull(TotalServiceTax,0),   
  @TotalTaxSuffered = IsNull(TotalTaxSuffered,0), @PaymentMode = PaymentMode, @TradeDiscount_Sales = IsNull(TradeDiscountValue_Spare,0),  
  @AdditionalDiscount_Sales = IsNull(AdditionalDiscountValue_Spare,0), @ItemDiscount = IsNull(ItemDiscount,0),  
  @TradeDiscount_Service = IsNull(TradeDiscountValue_Task,0), @AdditionalDiscount_Service = IsNull(AdditionalDiscountValue_Task,0),  
  @Freight = IsNull(Freight,0), @Status = IsNull(Status,0), @RoundOffAmount = IsNull(RoundOffAmount,0)   
  from ServiceInvoiceAbstract where ServiceInvoiceID = @InvoiceID  
 End

Select @ServiceValue = Sum(Amount) from ServiceInvoiceDetail Where Type = @TASK_TYPE   
And TaskID Is Not NULL And SpareCode Is NULL And ServiceInvoiceID = @InvoiceID  
      
Select @SalesValue = Sum(Amount) from ServiceInvoiceDetail Where Type in (@TASK_TYPE,@SPARE_TYPE)  
And SpareCode Is Not NULL And ServiceInvoiceID = @InvoiceID  
  
SET @TaxAmount = @TotalSalesTax + @TotalServiceTax + @TotalTaxsuffered  
  
Select @Customer_AccountID = AccountID from Customer where CustomerID = @CustomerID      
  
SET @TotalDiscount_Sales = @TradeDiscount_Sales + @AdditionalDiscount_Sales + @ItemDiscount      
SET @TotalDiscount_Service = @TradeDiscount_Service + @AdditionalDiscount_Service  
SET @SalesValue = @SalesValue - @TotalDiscount_Sales  
SET @ServiceValue = @ServiceValue - @TotalDiscount_Service  
-------------------------Issue from Job Card(Reversal Entries alone)-------------------------  
DECLARE @Value float,@RefID Int      
DECLARE ScanInvoice CURSOR KEYSET FOR      
Select Distinct(IssueID) from ServiceInvoiceDetail Where ServiceInvoiceID = @InvoiceID And IssueID Is NOT NULL  
OPEN ScanInvoice      
FETCH FROM ScanInvoice Into @RefID  
While @@FETCH_STATUS=0      
Begin      
 If IsNull(@RefID,0) <> 0      
 Begin      
  If (Select Count(*) from IssueAbstract Where IssueID = @RefID And IsNULL(Status,0) & 64 = 0) <> 0
  Begin
   Begin Tran      
    Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
    Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
   Commit Tran      
   Begin Tran      
    update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
    Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
   Commit Tran      
      
   Select @Value = Sum((IsNull(IssuedQty,0)-IsNull(ReturnedQty,0))*IsNull(PurchasePrice,0)) from IssueDetail where IssueID = @RefID  
      
   Execute sp_acc_insertGJ @TransactionID,@BILLSRECEIVABLE_ACCOUNT,@InvoiceDate,@Value,0,@RefID,@ISSUE_TYPE,'Issue Spares',@DocumentNumber      
   Execute sp_acc_insertGJ @TransactionID,@SALESONDC_ACCOUNT,@InvoiceDate,0,@Value,@RefID,@ISSUE_TYPE,'Issue Spares',@DocumentNumber      
      
   Insert Into #TempBackdatedAccounts(AccountID) Values(@SALESONDC_ACCOUNT)      
   Insert Into #TempBackdatedAccounts(AccountID) Values(@BILLSRECEIVABLE_ACCOUNT)      
  End
 End      
 FETCH NEXT FROM ScanInvoice Into @RefID  
End      
CLOSE ScanInvoice      
DEALLOCATE ScanInvoice      
---------------------------------Direct Service Invoice Entries---------------------------------  
Begin Tran      
 Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
 Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
Commit Tran      
Begin Tran      
 Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
 Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
Commit Tran      
      
If @PaymentMode = @CREDIT_MODE      
Begin      
 If @TotalTaxSuffered <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@TAXSUFFERED_ACCOUNT,@InvoiceDate,@TotalTaxSuffered,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@TAXSUFFERED_ACCOUNT)      
 End      
 If @TotalSalesTax <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SALESTAX_ACCOUNT,@InvoiceDate,@TotalSalesTax,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALESTAX_ACCOUNT)      
 End      
 If @IsVAT_Exists = 1 And @VAT_TaxAmount <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@VAT_TAXPAYABLE_ACCOUNT,@InvoiceDate,@VAT_TaxAmount,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_TAXPAYABLE_ACCOUNT)      
 End      
 If @SalesValue <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SALES_ACCOUNT,@InvoiceDate,@SalesValue,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALES_ACCOUNT)      
 End      
 If @TotalServiceTax <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SERVICETAX_ACCOUNT,@InvoiceDate,@TotalServiceTax,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICETAX_ACCOUNT)      
 End      
 If @ServiceValue <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SERVICE_ACCOUNT,@InvoiceDate,@ServiceValue,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICE_ACCOUNT)      
 End      
 If @Freight <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@FREIGHT_ACCOUNT,@InvoiceDate,@Freight,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@FREIGHT_ACCOUNT)      
 End      
 If @NetValue <> 0  
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@NetValue,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
 End      
End      
Else if @PaymentMode = @CASH_MODE      
Begin      
 If @TotalTaxSuffered <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@TAXSUFFERED_ACCOUNT,@InvoiceDate,@TotalTaxSuffered,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cash Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@TAXSUFFERED_ACCOUNT)      
 End      
 If @TotalSalesTax <> 0  
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SALESTAX_ACCOUNT,@InvoiceDate,@TotalSalesTax,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cash Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALESTAX_ACCOUNT)      
 End      
 If @IsVAT_Exists = 1 And @VAT_TaxAmount <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@VAT_TAXPAYABLE_ACCOUNT,@InvoiceDate,@VAT_TaxAmount,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cash Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_TAXPAYABLE_ACCOUNT)      
 End      
 If @SalesValue <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SALES_ACCOUNT,@InvoiceDate,@SalesValue,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cash Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALES_ACCOUNT)      
 End      
 If @TotalServiceTax <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SERVICETAX_ACCOUNT,@InvoiceDate,@TotalServiceTax,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cash Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICETAX_ACCOUNT)      
 End      
 If @ServiceValue <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SERVICE_ACCOUNT,@InvoiceDate,@ServiceValue,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cash Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICE_ACCOUNT)      
 End      
 If @Freight <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@FREIGHT_ACCOUNT,@InvoiceDate,@Freight,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cash Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@FREIGHT_ACCOUNT)      
 End      
 If @NetValue <> 0  
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@NetValue,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cash Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
 End      
  
 SET @CollectionID = Cast((Select PaymentDetails From ServiceInvoiceAbstract Where ServiceInvoiceId = @InvoiceID) As Int)      
 Select @ColValue = IsNull(Value,0) from Collections Where DocumentID = @CollectionID      
     
 If @ColValue <> 0      
 Begin       
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
  Commit Tran      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
  Commit Tran      
  
  Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@ColValue,0,@CollectionID,@COLLECTION_TYPE,'Cash Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
  
  Execute sp_acc_insertGJ @TransactionID,@CASH_ACCOUNT,@InvoiceDate,0,@ColValue,@CollectionID,@COLLECTION_TYPE,'Cash Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@CASH_ACCOUNT)      
 End      
End      
Else If (@PaymentMode = @CHEQUE_MODE Or @PaymentMode = @DD_MODE)      
Begin      
 If @TotalTaxSuffered <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@TAXSUFFERED_ACCOUNT,@InvoiceDate,@TotalTaxSuffered,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cheque/DD Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@TAXSUFFERED_ACCOUNT)      
 End      
 If @TotalSalesTax <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SALESTAX_ACCOUNT,@InvoiceDate,@TotalSalesTax,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cheque/DD Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALESTAX_ACCOUNT)      
 End      
 If @IsVAT_Exists = 1 And @VAT_TaxAmount <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@VAT_TAXPAYABLE_ACCOUNT,@InvoiceDate,@VAT_TaxAmount,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cheque/DD Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_TAXPAYABLE_ACCOUNT)      
 End      
 If @SalesValue <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SALES_ACCOUNT,@InvoiceDate,@SalesValue,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cheque/DD Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALES_ACCOUNT)      
 End      
 If @TotalServiceTax <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SERVICETAX_ACCOUNT,@InvoiceDate,@TotalServiceTax,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cheque/DD Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICETAX_ACCOUNT)      
 End      
 If @ServiceValue <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SERVICE_ACCOUNT,@InvoiceDate,@ServiceValue,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cheque/DD Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICE_ACCOUNT)      
 End      
 If @Freight <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@FREIGHT_ACCOUNT,@InvoiceDate,@Freight,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cheque/DD Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@FREIGHT_ACCOUNT)      
 End      
 If @NetValue <> 0  
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@NetValue,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Cheque/DD Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
 End      
  
 SET @CollectionID = cast((Select PaymentDetails From ServiceInvoiceAbstract Where ServiceInvoiceId = @InvoiceID) as Int)      
 Select @ColValue = IsNull(Value,0) from collections Where DocumentID = @CollectionID      
      
 If @ColValue <> 0      
 Begin      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
  Commit Tran      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
  Commit Tran      
  
  Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@ColValue,0,@CollectionID,@COLLECTION_TYPE,'Cheque/DD Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
  
  Execute sp_acc_insertGJ @TransactionID,@CHEQUEONHAND_ACCOUNT,@InvoiceDate,0,@ColValue,@CollectionID,@COLLECTION_TYPE,'Cheque/DD Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@CHEQUEONHAND_ACCOUNT)      
 End      
End      
Else If @PaymentMode = @CREDITCARD_MODE  
Begin      
 If @TotalTaxSuffered <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@TAXSUFFERED_ACCOUNT,@InvoiceDate,@TotalTaxSuffered,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'CreditCard Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@TAXSUFFERED_ACCOUNT)      
 End      
 If @TotalSalesTax <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SALESTAX_ACCOUNT,@InvoiceDate,@TotalSalesTax,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Card Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALESTAX_ACCOUNT)      
 End      
 If @IsVAT_Exists = 1 And @VAT_TaxAmount <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@VAT_TAXPAYABLE_ACCOUNT,@InvoiceDate,@VAT_TaxAmount,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Card Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_TAXPAYABLE_ACCOUNT)      
 End      
 If @SalesValue <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SALES_ACCOUNT,@InvoiceDate,@SalesValue,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Card Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALES_ACCOUNT)      
 End      
 If @TotalServiceTax <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SERVICETAX_ACCOUNT,@InvoiceDate,@TotalServiceTax,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Card Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICETAX_ACCOUNT)      
 End      
 If @ServiceValue <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SERVICE_ACCOUNT,@InvoiceDate,@ServiceValue,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Card Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICE_ACCOUNT)      
 End      
 If @Freight <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@FREIGHT_ACCOUNT,@InvoiceDate,@Freight,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Card Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@FREIGHT_ACCOUNT)      
 End      
 If @NetValue <> 0  
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@NetValue,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Credit Card Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
 End      
     
 SET @CollectionID = cast((Select PaymentDetails From ServiceInvoiceAbstract Where ServiceInvoiceId = @InvoiceID) as Int)      
 Select @ColValue = IsNull(Value,0),@Customer_Service_Charge = IsNull(CustomerServiceCharge,0) from collections Where DocumentID = @CollectionID      
 SET @ColValue = @ColValue + @Customer_Service_Charge  
  
 If @Customer_Service_Charge <> 0      
 Begin      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
  Commit Tran      
  Begin Tran      
 Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
  Commit Tran      
  
  Execute sp_acc_insertGJ @TransactionID,@CREDITCARD_SERVICECHARGE_ACCOUNT,@InvoiceDate,@Customer_Service_Charge,0,@CollectionID,@COLLECTION_TYPE,'Credit Card Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@CREDITCARD_SERVICECHARGE_ACCOUNT)      
  
  Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@Customer_Service_Charge,@CollectionID,@COLLECTION_TYPE,'Credit Card Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
 End      
      
 If @ColValue <> 0      
 Begin      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
  Commit Tran      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51    
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
  Commit Tran      
  
  Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@ColValue,0,@CollectionID,@COLLECTION_TYPE,'Credit Card Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
  
  Execute sp_acc_insertGJ @TransactionID,@CREDITCARD_ACCOUNT,@InvoiceDate,0,@ColValue,@CollectionID,@COLLECTION_TYPE,'Credit Card Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@CREDITCARD_ACCOUNT)      
 End      
End      
Else If @PaymentMode = @COUPON_MODE
Begin      
 If @TotalTaxSuffered <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@TAXSUFFERED_ACCOUNT,@InvoiceDate,@TotalTaxSuffered,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@TAXSUFFERED_ACCOUNT)      
 End      
 If @TotalSalesTax <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SALESTAX_ACCOUNT,@InvoiceDate,@TotalSalesTax,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALESTAX_ACCOUNT)      
 End      
 If @IsVAT_Exists = 1 And @VAT_TaxAmount <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@VAT_TAXPAYABLE_ACCOUNT,@InvoiceDate,@VAT_TaxAmount,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_TAXPAYABLE_ACCOUNT)      
 End      
 If @SalesValue <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SALES_ACCOUNT,@InvoiceDate,@SalesValue,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALES_ACCOUNT)      
 End      
 If @TotalServiceTax <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SERVICETAX_ACCOUNT,@InvoiceDate,@TotalServiceTax,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICETAX_ACCOUNT)      
 End      
 If @ServiceValue <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@SERVICE_ACCOUNT,@InvoiceDate,@ServiceValue,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICE_ACCOUNT)      
 End      
 If @Freight <> 0      
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@FREIGHT_ACCOUNT,@InvoiceDate,@Freight,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@FREIGHT_ACCOUNT)      
 End      
 If @NetValue <> 0  
 Begin      
  Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@NetValue,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
 End      
     
 SET @CollectionID = cast((Select PaymentDetails From ServiceInvoiceAbstract Where ServiceInvoiceId = @InvoiceID) as Int)      
 Select @ColValue = IsNull(Value,0),@Customer_Service_Charge = IsNull(CustomerServiceCharge,0) from collections Where DocumentID = @CollectionID      
 SET @ColValue = @ColValue + @Customer_Service_Charge  
  
 If @Customer_Service_Charge <> 0      
 Begin      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24     
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
  Commit Tran      
  Begin Tran      
  Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51     
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
  Commit Tran      
  
  Execute sp_acc_insertGJ @TransactionID,@COUPON_SERVICECHARGE_ACCOUNT,@InvoiceDate,@Customer_Service_Charge,0,@CollectionID,@COLLECTION_TYPE,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@COUPON_SERVICECHARGE_ACCOUNT)      
  
  Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@Customer_Service_Charge,@CollectionID,@COLLECTION_TYPE,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
 End      
      
 If @ColValue <> 0      
 Begin      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
  Commit Tran      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
  Commit Tran      
  
  Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@ColValue,0,@CollectionID,@COLLECTION_TYPE,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
  
  Execute sp_acc_insertGJ @TransactionID,@COUPON_ACCOUNT,@InvoiceDate,0,@ColValue,@CollectionID,@COLLECTION_TYPE,'Coupon Service Invoice - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@COUPON_ACCOUNT)      
 End      
End      
----------------------------Entry for Sales Discount Account----------------------------------      
If @TotalDiscount_Sales > 0      
 Begin      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
  Commit Tran      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
  Commit Tran      
  
  Execute sp_acc_insertGJ @TransactionID,@SALES_ACCOUNT,@InvoiceDate,@TotalDiscount_Sales,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - Discount On Sales - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALES_ACCOUNT)      
  
  Execute sp_acc_insertGJ @TransactionID,@SALESDISCOUNT_ACCOUNT,@InvoiceDate,0,@TotalDiscount_Sales,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - Discount On Sales - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALESDISCOUNT_ACCOUNT)      
 End      
Else If @TotalDiscount_Sales < 0      
 Begin      
  SET @TotalDiscount_Sales = ABS(@TotalDiscount_Sales)      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
  Commit Tran      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
  Commit Tran      
  
  Execute sp_acc_insertGJ @TransactionID,@SALESDISCOUNT_ACCOUNT,@InvoiceDate,@TotalDiscount_Sales,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - Discount On Sales - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALES_ACCOUNT)      
  
  Execute sp_acc_insertGJ @TransactionID,@SALES_ACCOUNT,@InvoiceDate,0,@TotalDiscount_Sales,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - Discount On Sales - Cancellation',@DocumentNumber  
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SALESDISCOUNT_ACCOUNT)      
 End      
----------------------------Entry for Service Discount Account----------------------------------      
If @TotalDiscount_Service > 0      
 Begin      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
  Commit Tran      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
  Commit Tran      
  
  Execute sp_acc_insertGJ @TransactionID,@SERVICE_ACCOUNT,@InvoiceDate,@TotalDiscount_Service,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - Discount On Service - Cancellation',@DocumentNumber   
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICE_ACCOUNT)      
  
  Execute sp_acc_insertGJ @TransactionID,@DISCOUNT_ON_SERVICE_ACCOUNT,@InvoiceDate,0,@TotalDiscount_Service,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - Discount On Service - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@DISCOUNT_ON_SERVICE_ACCOUNT)      
 End      
Else If @TotalDiscount_Service < 0      
 Begin      
  SET @TotalDiscount_Service = ABS(@TotalDiscount_Service)      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
  Commit Tran      
  Begin Tran      
   Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
  Commit Tran      
  
  Execute sp_acc_insertGJ @TransactionID,@DISCOUNT_ON_SERVICE_ACCOUNT,@InvoiceDate,@TotalDiscount_Service,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - Discount On Service - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@DISCOUNT_ON_SERVICE_ACCOUNT)      
  
  Execute sp_acc_insertGJ @TransactionID,@SERVICE_ACCOUNT,@InvoiceDate,0,@TotalDiscount_Service,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - Discount On Service - Cancellation',@DocumentNumber      
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SERVICE_ACCOUNT)      
 End      
--------------------------------Entry for RoundOff Amount-------------------------------------      
If @RoundOffAmount > 0      
Begin      
 Begin Tran      
  Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
 Commit Tran      
 Begin Tran      
  Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
 Commit Tran      
  
 Execute sp_acc_insertGJ @TransactionID,@ROUNDOFF_ACCOUNT,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - RoundOff Amount - Cancellation',@DocumentNumber      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@ROUNDOFF_ACCOUNT)      
  
 Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - RoundOff Amount - Cancellation',@DocumentNumber      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
End      
Else If @RoundOffAmount < 0      
Begin      
 SET @RoundOffAmount = Abs(@RoundOffAmount)      
 Begin Tran      
  Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
 Commit Tran      
 Begin Tran      
  Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
 Commit Tran      
  
 Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - RoundOff Amount - Cancellation',@DocumentNumber      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)      
  
 Execute sp_acc_insertGJ @TransactionID,@ROUNDOFF_ACCOUNT,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Service Invoice - RoundOff Amount - Cancellation',@DocumentNumber      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@ROUNDOFF_ACCOUNT)      
End      
--------------------------Entry for Secondary Secheme Expenses-------------------------------      
DECLARE @SecSchemeValue Decimal(18,6)      
DECLARE @Type Int,@SecScheme Int,@SchemeType Int      
      
DECLARE ScanScheme CURSOR KEYSET FOR      
Select Type from SchemeSale Where InvoiceId=@InvoiceID Group By Type      
OPEN ScanScheme      
FETCH FROM ScanScheme IntO @Type      
While @@FETCH_STATUS = 0      
Begin      
 Select @SecScheme = IsNull(SecondaryScheme,0),@SchemeType = IsNull(SchemeType,0) from Schemes where SchemeID = IsNull(@Type,0)      
 If IsNull(@SecScheme,0) <> 0      
 Begin      
  If IsNull(@SchemeType,0) = 19 --------------Item based percentage scheme type--------------  
  Begin      
   Select @SecSchemeValue = IsNull(@SecSchemeValue,0) + (Select Sum((IsNull(Cost,0)*IsNull(Value,0))/100) from SchemeSale where InvoiceId = @InvoiceID And Type = @Type group by Type)      
  End      
  Else      
  Begin      
   Select @SecSchemeValue = IsNull(@SecSchemeValue,0) + (Select Sum(IsNull(Cost,0)) from SchemeSale where InvoiceId = @InvoiceID and Type = @Type group by Type)      
  End      
 End      
 FETCH NEXT FROM ScanScheme Into @Type      
End      
CLOSE ScanScheme      
DEALLOCATE ScanScheme      
      
If IsNull(@SecSchemeValue,0) <> 0      
Begin      
 Begin Tran      
  Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24      
  Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
 Commit Tran      
 Begin Tran      
  Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51      
  Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
 Commit Tran      
  
 Execute sp_acc_insertGJ @TransactionID,@CLAIMS_RECEIVABLE_ACCOUNT,@InvoiceDate,@SecSchemeValue,0,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Secondary Scheme - Cancellation',@DocumentNumber      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@CLAIMS_RECEIVABLE_ACCOUNT)      
  
 Execute sp_acc_insertGJ @TransactionID,@SECONDARY_SCHEME_EXPENSE_ACCOUNT,@InvoiceDate,0,@SecSchemeValue,@InvoiceID,@SERVICEINVOICE_TYPE_CANCEL,'Secondary Scheme - Cancellation',@DocumentNumber      
 Insert Into #TempBackdatedAccounts(AccountID) Values(@SECONDARY_SCHEME_EXPENSE_ACCOUNT)      
End      
------------------------Credit/Debit Note Cancellation Journal Entries-----------------------
Declare @ReferenceID Int,@NoteType Int
If Exists(Select ReferenceID From Service_AdjustmentReference Where ServiceInvoiceID=@InvoiceID)
 Begin            
  DECLARE ScanAdjustmentReference CURSOR KEYSET FOR            
  Select ReferenceID,DocumentType from Service_AdjustmentReference Where ServiceInvoiceID=@InvoiceID
  OPEN ScanAdjustmentReference            
  FETCH FROM ScanAdjustmentReference INTO @ReferenceID,@NoteType
  WHILE @@FETCH_STATUS=0
   Begin
    If @NoteType=5 /* Debit Note */
     Begin
      Exec sp_acc_gj_debitnoteCancel @ReferenceID,@BackDate
     End
    Else If @NoteType=2 /* Credit Note */
     Begin
      Exec sp_acc_gj_creditnoteCancel @ReferenceID,@BackDate
     End
    FETCH NEXT FROM ScanAdjustmentReference INTO @ReferenceID,@NoteType
   End
  CLOSE ScanAdjustmentReference
  DEALLOCATE ScanAdjustmentReference
 End
------------------------------------Back dated Operation----------------------------------------  
If @BackDate Is Not Null        
Begin      
 DECLARE @TempAccountID Int      
 DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR      
 Select AccountID From #TempBackdatedAccounts      
 OPEN scantempbackdatedaccounts      
 FETCH FROM scantempbackdatedaccounts IntO @TempAccountID      
 WHILE @@FETCH_STATUS = 0      
 Begin   
  Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID      
  FETCH NEXT FROM scantempbackdatedaccounts IntO @TempAccountID      
 End      
 CLOSE scantempbackdatedaccounts      
 DEALLOCATE scantempbackdatedaccounts      
End      
Drop Table #TempBackdatedAccounts 
