CREATE Procedure sp_acc_gj_RetailInvoiceAmendment(@InvoiceID INT, @BackDate DateTime=NULL)  
AS -- Journal entry for Retail Invoice Amendment               
Declare @InvoiceDate DateTime                
Declare @NetValue Float                
Declare @SalesValue Float                
Declare @TaxAmount Float                
Declare @UserName nVarchar(15)                
Declare @PaymentDetails nVarchar(255)                
Declare @ServiceChargeDetails nVarchar(255)                
Declare @InternalRemarks nVarChar(255)  
Declare @IntlRmksDisc nVarChar(255)  
Declare @IntlRmksRndOff nVarChar(255)  
Declare @IntlRmksSecSch nVarChar(255)  
Declare @TotalSalesTax Decimal(18,6)                
Declare @TotalTaxSuffered Decimal(18,6)                
Declare @AmountRecd Decimal(18,6)                
Declare @RoundOffAmount Decimal(18,6)                
Declare @TradeDiscount Decimal(18,6)                  
Declare @AdditionalDiscount Decimal(18,6)                  
Declare @ItemDiscount Decimal(18,6)                  
Declare @TotalDiscount Decimal(18,6)                  
Declare @InvSchemeDiscountAmount Decimal(18,6)                    
Declare @ItmSchemeDiscountAmount Decimal(18,6)                    
Declare @RetailCustomerID nVarChar(50)  
Declare @Customer_AccountID INT                
Declare @InvoiceType INT                
Declare @CollectionType INT  
Declare @CollectionCancelType INT  
Declare @RoundOffAccount INT                
Declare @Discount_Account INT  
Declare @SalesDiscountAccount INT                  
Declare @Cash_Account INT                
Declare @SalesTax_Account INT                
Declare @Sales_Account INT                
Declare @TaxSuffered_Account INT                
Declare @TransactionID INT                
Declare @DocumentNumber INT           
Declare @RetailPaymentMode INT       
Declare @InvRefNum INT  
Declare @FindPos INT  
Declare @Gift_Voucher INT  
Declare @RetailUserWise INT  
  
Set @InvoiceType = 2                
Set @CollectionType = 13  
Set @CollectionCancelType = 25  
Set @RoundOffAccount = 92                
Set @Discount_Account = 13  
Set @SalesDiscountAccount = 107 -- Discount On Sales A/c                  
Set @Cash_Account = 3  -- Cash Account                
Set @Sales_Account = 5  -- Sales Account                
Set @SalesTax_Account = 1  -- SalesTax Account                
Set @TaxSuffered_Account = 29 -- Tax Suffered Account                
Set @Gift_Voucher = 114 -- Gift Voucher Account ID  
  
Declare @Vat_Exists Integer  
Declare @VAT_Payable Integer  
Declare @nVatTaxamount decimal(18,6)  
Set @VAT_Payable  = 116  /* Constant to store the VAT Payable (Output Tax) AccountID*/       
Set @Vat_Exists = 0   
If dbo.columnexists('InvoiceAbstract','VATTaxAmount') = 1  
 Begin  
  Set @Vat_Exists = 1  
 End  
  
Select @ItmSchemeDiscountAmount = Sum(IsNULL(SchemeDiscAmount,0) + IsNULL(SplCatDiscAmount,0)) from InvoiceDetail Where InvoiceID = @InvoiceID                    
If @Vat_Exists  = 1  
 Begin  
  Set @nVatTaxamount = 0   

  Select @RetailCustomerID=IsNULL(CustomerID,0),@InvoiceDate=InvoiceDate,@NetValue=IsNULL(NetValue,0),@TotalSalesTax=IsNULL(TotalTaxApplicable,0) - IsNULL(VATTaxAmount,0),                
  @RetailPaymentMode=PaymentMode,@TradeDiscount=IsNULL(DiscountValue,0),@AdditionalDiscount=IsNULL(AddlDiscountValue,0),@ItemDiscount=IsNULL(ProductDiscount,0),  
  @TotalTaxSuffered=IsNULL(TotalTaxSuffered,0),@InvRefNum=InvoiceReference,@RoundOffAmount=IsNULL(RoundOffAmount,0),@InvSchemeDiscountAmount=IsNULL(SchemeDiscountAmount,0),              
  @UserName=UserName,@PaymentDetails=IsNULL(PaymentDetails,N''),@ServiceChargeDetails=ServiceCharge,@AmountRecd = IsNULL(AmountRecd,0)                ,
  @nVatTaxamount = IsNULL(VATTaxAmount,0)
  from InvoiceAbstract Where InvoiceID=@InvoiceID                
   
  Set @TaxAmount=@TotalSalesTax+@TotalTaxsuffered+@nVatTaxamount  
 End  
Else  
 Begin  
  Select @RetailCustomerID=IsNULL(CustomerID,0),@InvoiceDate=InvoiceDate,@NetValue=IsNULL(NetValue,0),@TotalSalesTax=IsNULL(TotalTaxApplicable,0),                
  @RetailPaymentMode=PaymentMode,@TradeDiscount=IsNULL(DiscountValue,0),@AdditionalDiscount=IsNULL(AddlDiscountValue,0),@ItemDiscount=IsNULL(ProductDiscount,0),  
  @TotalTaxSuffered=IsNULL(TotalTaxSuffered,0),@InvRefNum=InvoiceReference,@RoundOffAmount=IsNULL(RoundOffAmount,0),@InvSchemeDiscountAmount=IsNULL(SchemeDiscountAmount,0),              
  @UserName=UserName,@PaymentDetails=IsNULL(PaymentDetails,N''),@ServiceChargeDetails=ServiceCharge,@AmountRecd = IsNULL(AmountRecd,0)                
  from InvoiceAbstract Where InvoiceID=@InvoiceID   

  Set @TaxAmount=@TotalSalesTax+@TotalTaxsuffered                
 End  
------------------------------------Set Customer AccountID-----------------------------------  
If IsNULL(@RetailCustomerID,0) = N'0' Or IsNULL(@RetailCustomerID,0) = N''   
 Begin  
  Set @Customer_AccountID = 93 /*Retail Customer Account*/  
 End  
Else  
 Begin  
  Select @Customer_AccountID = AccountID from Customer Where CustomerID = @RetailCustomerID  
 End  
--------------------------------------Get CollectionIDs--------------------------------------  
Declare @RECSPLIT As nVarChar(15)  
Set @RECSPLIT = N','  
  
Set @FindPos = CharIndex(N':', @PaymentDetails, 1)  
If @FindPos > 0 GOTO OLDIMPL /*This is to Handle Old Implementation*/  
  
CREATE Table #TempBackdatedAccounts(AccountID INT) -- for Backdated Operation                
CREATE Table #TempCollections(CollectionID INT)   
  
Insert Into #TempCollections  
Exec Sp_acc_SQLSplit @PaymentDetails, @RECSPLIT  
------------------------------------Set Internal Remarks-------------------------------------  
If IsNULL(@RetailPaymentMode,0) = 0 /*Zero = Credit RetailInvoice*/  
 Begin  
  Set @InternalRemarks = 'Credit Retail Invoice Amendment'  
 End  
Else  
 Begin  
  Set @InternalRemarks = 'Retail Invoice Amendment'  
 End  
Set @IntlRmksDisc = @InternalRemarks + N'-Discount On Sales' /*Internal Remarks for DiscountOnSales*/  
Set @IntlRmksRndOff = @InternalRemarks + N'-RoundOff Amount' /*Internal Remarks for RoundOff Amount*/  
Set @IntlRmksSecSch = @InternalRemarks + N'-Secondary Scheme' /*Internal Remarks for Secondary Scheme*/  
--------------------------------------Entry for Sales-----------------------------------------  
Set @SalesValue = IsNULL(@NetValue,0)-IsNULL(@TaxAmount,0)                
If @NetValue > 0  
 Begin                
  /*Get last DocumentNumber from DocumentNumbers Table*/  
  Begin Tran   
   Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
   Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
  Commit Tran                
  Begin Tran                
   Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
  Commit Tran                
    
  If @NetValue <> 0                
   Begin -- Entry for Retail Customer Account                
    Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@NetValue,0,@InvoiceID,@InvoiceType,@InternalRemarks,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
   End                
  If @TotalSalesTax <> 0                
   Begin -- Entry for Sales Tax Account                
    Execute sp_acc_insertGJ @TransactionID,@SalesTax_Account,@InvoiceDate,0,@TotalSalesTax,@InvoiceID,@InvoiceType,@InternalRemarks,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesTax_Account)                
   End                
  If @TotalTaxSuffered <> 0  
   Begin -- Entry for Tax Suffered Account                
    Execute sp_acc_insertGJ @TransactionID,@TaxSuffered_Account,@InvoiceDate,0,@TotalTaxSuffered,@InvoiceID,@InvoiceType,@InternalRemarks,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@TaxSuffered_Account)                
   End                
  If @Vat_Exists = 1  
   Begin  
    If @nVatTaxamount <> 0    
     Begin -- Entry for VAT Tax Account                
      Execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,0,@nVatTaxamount,@InvoiceID,@InvoiceType,@InternalRemarks,@DocumentNumber                
      Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)                
     End  
   End  
  If @SalesValue <> 0                
   Begin -- Entry for Sales Account                
    Execute sp_acc_insertGJ @TransactionID,@Sales_Account,@InvoiceDate,0,@SalesValue,@InvoiceID,@InvoiceType,@InternalRemarks,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Sales_Account)                
   End                
-----------------------------------Entry for Discount Account----------------------------------                  
  Set @TradeDiscount = @TradeDiscount - @InvSchemeDiscountAmount                    
  Set @ItemDiscount = @ItemDiscount - @ItmSchemeDiscountAmount                    
  Set @TotalDiscount = @TradeDiscount + @AdditionalDiscount + @ItemDiscount                  
  If @TotalDiscount > 0                  
   Begin            
    Begin Tran                  
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                  
     Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                  
    Commit Tran                  
    Begin Tran                  
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                  
     Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51     
    Commit Tran                  
    -- Entry for Discount Account                  
    Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,@TotalDiscount,0,@InvoiceID,@InvoiceType,@IntlRmksDisc,@DocumentNumber                  
    -- Entry for Sales Account                  
    Execute sp_acc_insertGJ @TransactionID,@Sales_Account,@InvoiceDate,0,@TotalDiscount,@InvoiceID,@InvoiceType,@IntlRmksDisc,@DocumentNumber                  
    -- Update #TempBackdatedAccounts for Backdation Purpose                  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesDiscountAccount)                  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Sales_Account)                  
   End                  
  Else If @TotalDiscount < 0                  
   Begin                  
    Set @TotalDiscount = ABS(@TotalDiscount)                  
    Begin Tran                  
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                  
     Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                  
    Commit Tran                  
    Begin Tran                  
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                  
     Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                  
    Commit Tran                  
    -- Entry for Sales Account                  
    Execute sp_acc_insertGJ @TransactionID,@Sales_Account,@InvoiceDate,@TotalDiscount,0,@InvoiceID,@InvoiceType,@IntlRmksDisc,@DocumentNumber                  
    -- Entry for Discount Account                  
    Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,0,@TotalDiscount,@InvoiceID,@InvoiceType,@IntlRmksDisc,@DocumentNumber                  
    -- Update #TempBackdatedAccounts for Backdation Purpose                  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesDiscountAccount)                  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Sales_Account)                
   End                  
--------------------------------Entry for RoundOff Amount------------------------------------  
  If @RoundOffAmount > 0                
   Begin                
    Begin Tran                
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
     Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
    Commit Tran                
    Begin Tran                
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
     Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51    
    Commit Tran                
    -- Entry for Retail Customer Account                
    Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@InvoiceType,@IntlRmksRndOff,@DocumentNumber                
    -- Entry for RoundOff Account                
    Execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@InvoiceType,@IntlRmksRndOff,@DocumentNumber      
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)                
   End                
  Else If @RoundOffAmount < 0         
   Begin                
    Set @RoundOffAmount = ABS(@RoundOffAmount)                
    Begin Tran                
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
     Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
    Commit Tran                
    Begin Tran                
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
     Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
    Commit Tran                
    -- Entry for RoundOff Account                
    Execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@InvoiceType,@IntlRmksRndOff,@DocumentNumber                
    -- Entry for Retail Customer Account                
    Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@InvoiceType,@IntlRmksRndOff,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
    Set @RoundOffAmount = 0 - ABS(@RoundOffAmount)                
   End                
-----------------------------Entry for Secondary Scheme--------------------------------------  
  Declare @SecSchemeValue Decimal(18,6),@SchemeDiscountValue Decimal(18,6)                  
  Declare @SecondarySchemeExpense INT,@ClaimsRecivable INT                
  Declare @Type INT,@SecScheme INT,@SchemeType INT,@SchemeID INT                  
  Set @SecondarySchemeExpense = 39                
  Set @ClaimsRecivable = 10                
                 
  DECLARE ScanScheme CURSOR KEYSET FOR                
  Select Type from SchemeSale Where InvoiceId=@InvoiceID And IsNULL(SaleType,0) = 0 Group By Type                
  OPEN ScanScheme                
  FETCH FROM ScanScheme Into @Type                
  While @@FETCH_STATUS=0                
   Begin                
    Select @SecScheme=IsNULL(SecondaryScheme,0),@SchemeType=IsNULL(SchemeType,0) from Schemes Where SchemeID=IsNULL(@Type,0)                
    If IsNULL(@SecScheme,0)<>0                
     Begin                
      If IsNULL(@SchemeType,0) = 19 -- Item based percentage scheme type                
       Begin                
        Select @SecSchemeValue= IsNULL(@SecSchemeValue,0) + (Select Sum((IsNULL(Cost,0)*IsNULL(Value,0))/100) from SchemeSale Where InvoiceId=@InvoiceID and Type=@Type And IsNULL(SaleType,0) = 0 Group by Type)                
       End                
      Else                
       Begin                
        Select @SecSchemeValue=IsNULL(@SecSchemeValue,0) + (Select Sum(IsNULL(Cost,0)) from SchemeSale Where InvoiceId=@InvoiceID and Type=@Type And IsNULL(SaleType,0) = 0 Group by Type)                
       End                
     End                
    FETCH NEXT FROM ScanScheme Into @Type                
   End                
  CLOSE ScanScheme                
  DEALLOCATE ScanScheme                
                
  /*Add Invoice Based Secondary Scheme Values to the @SecSchemeValue Variable*/       
  Select @SchemeID = IsNULL(SchemeID,0), @SchemeDiscountValue = IsNULL(SchemeDiscountAmount,0) from InvoiceAbstract Where InvoiceID = @InvoiceID                        
  Select @SecScheme = IsNULL(SecondaryScheme,0) from Schemes Where SchemeID = @SchemeID                  
  If IsNULL(@SecScheme,0) <> 0                  
   Begin                  
    Set @SecSchemeValue = IsNULL(@SecSchemeValue,0) + IsNULL(@SchemeDiscountValue,0)                  
   End                  
              
  If @SecSchemeValue <> 0                
   Begin                
    Begin Tran            
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
     Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
    Commit Tran                
    Begin Tran                
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
     Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
    Commit Tran                
    -- Entry for SecondarySchemeExpense Account                
    Execute sp_acc_insertGJ @TransactionID,@SecondarySchemeExpense,@InvoiceDate,@SecSchemeValue,0,@InvoiceID,@InvoiceType,@IntlRmksSecSch,@DocumentNumber                
    -- Entry for Claims Receivable Account                
    Execute sp_acc_insertGJ @TransactionID,@ClaimsRecivable,@InvoiceDate,0,@SecSchemeValue,@InvoiceID,@InvoiceType,@IntlRmksSecSch,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@SecondarySchemeExpense)              
    Insert Into #TempBackdatedAccounts(AccountID) Values(@ClaimsRecivable)                
   End                
------------------------------Entry for PaymentMode(Collections)-----------------------------  
  Declare @AccountName nVarchar(255),@GroupID INT,@User_AccountID INT,@CollectionID INT,@ColtnPayMode INT  
  Declare @AdjustedAmount Decimal(18,6),@AmtRecd Decimal(18,6),@SumAmtRecd Decimal(18,6)                
  Declare @PayModeID INT, @PayModeType INT, @PayModeName nVarchar(150)   
  Declare @SumServiceCharge Decimal(18,6), @ServiceCharge Decimal(18,6), @ServiceCharge_AccountID INT  
  Declare @CASHTYPE INT,@CHEQUETYPE INT,@CREDITCARDTYPE INT,@COUPONTYPE INT,@OTHERSTYPE INT                
  Declare @Discount Decimal(18,6),@Total Decimal(18,6)  
  
  Set @CASHTYPE = 1                
  Set @CHEQUETYPE = 2                
  Set @CREDITCARDTYPE = 3             
  Set @COUPONTYPE = 4                
  Set @OTHERSTYPE = 5                
  
  If IsNULL(@RetailPaymentMode,0) <> 0  
   Begin  
    DECLARE ScanCollections CURSOR KEYSET FOR  
    Select CollectionID from #TempCollections  
    OPEN ScanCollections  
    FETCH FROM ScanCollections Into @CollectionID  
    WHILE @@FETCH_STATUS = 0  
     Begin  
      Select @PayModeID = PaymentModeID, @AmtRecd = Value, @ColtnPayMode = PaymentMode, @ServiceCharge = IsNULL(CustomerServiceCharge,0) from Collections Where DocumentID = @CollectionID  
      Select @PayModeName = Value, @PayModeType = IsNULL(PaymentType,0) from PaymentMode Where Mode = @PayModeID  
      Set @SumAmtRecd = IsNULL(@SumAmtRecd,0) + IsNULL(@AmtRecd,0)  
      Set @SumServiceCharge = IsNULL(@SumServiceCharge,0) + IsNULL(@ServiceCharge,0)                
      Set @AmtRecd = @AmtRecd + IsNULL(@ServiceCharge,0)  
      If @ColtnPayMode = 7 -- Gift Voucher  
       Begin  
        Select @Total = IsNULL(Adjustedamount,0) + IsNULL(Adjustment,0) , @AdjustedAmount = IsNULL(Adjustedamount,0),@Discount = IsNULL(Adjustment,0)  
        From CollectionDetail where collectionid = @CollectionID  and DocumentType = N'6' -- Invoice  
        -- Entry for Userwise PaymentMode  
        If IsNULL(@Total,0) <> 0   
         Begin  
          Begin Tran                
           Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
           Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
          Commit Tran                
          Begin Tran                
           Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
           Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
          Commit Tran               
          If IsNULL(@AdjustedAmount,0) > 0   
           Begin  
            Execute sp_acc_insertGJ @TransactionID,@Gift_Voucher,@InvoiceDate,@AdjustedAmount,0,@CollectionID,@CollectionType,'Retail Invoice Amendment-Redeem Collection',@DocumentNumber  
            Insert Into #TempBackdatedAccounts(AccountID) Values(@Gift_Voucher)             
           End  
          If IsNULL(@Discount,0) > 0   
           Begin  
            Execute sp_acc_insertGJ @TransactionID,@Discount_Account,@InvoiceDate,@Discount,0,@CollectionID,@CollectionType,'Retail Invoice Amendment-Redeem Collection',@DocumentNumber  
            Insert Into #TempBackdatedAccounts(AccountID) Values(@Discount_Account)                
           End  
          -- Entry for Customer Account  
          Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@Total,@CollectionID,@CollectionType,'Retail Invoice Amendment-Redeem Collection',@DocumentNumber                
          Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
         End  
       End  
      Else If IsNULL(@AmtRecd,0) <> 0 And @ColtnPayMode <> 6 /*6 = Credit Note Adjustments*/  
       Begin                
        Select @RetailUserWise = IsNULL(RetailUserWise, 0) from Collections Where DocumentID = @CollectionID  
        If @RetailUserWise = 1 /*Then It should go to the LocalUser Account*/  
         Begin  
          If NOT EXISTS(Select Top 1 AccountID from AccountsMaster Where UserName = @Username And RetailPaymentMode = @PayModeID)  
           Begin                
            Set @AccountName = @PayModeName + N'-' + @UserName  
            If @PayModeType = @CASHTYPE                
             Set @GroupID = 19 -- CashInHand AccountGroup                 
            Else If @PayModeType = @CHEQUETYPE                 
             Set @GroupID = 20 -- ChequesInHand AccountGroup                
            Else If @PayModeType = @CREDITCARDTYPE                
             Set @GroupID = 50 -- CreditCardsInHand AccountGroup                 
            Else If @PayModeType = @COUPONTYPE                
             Set @GroupID = 51 -- CouponsInHand AccountGroup                    
            Else If @PayModeType = @OTHERSTYPE                 
             Set @GroupID = 52 -- OthersInHand AccountGroup                   
            Exec sp_acc_insertaccounts @AccountName, @GroupID, 0                
            Set @User_AccountID = @@Identity                
            Update AccountsMaster Set UserName = @UserName, RetailPaymentMode = @PayModeID Where AccountID = @User_AccountID                 
           End                
          Else                
           Begin                 
            Select @User_AccountID = AccountID from AccountsMaster Where UserName = @Username and RetailPaymentMode = @PayModeID           
  End                
         End          
        Else  
         Begin  
          If @PayModeType = @CASHTYPE                
           Set @User_AccountID = 3 -- Cash Account  
          Else If @PayModeType = @CHEQUETYPE                 
           Set @User_AccountID = 7 -- Cheque In Hand Account  
          Else If @PayModeType = @CREDITCARDTYPE                
           Set @User_AccountID = 94 -- CreditCard Account  
          Else If @PayModeType = @COUPONTYPE                
           Set @User_AccountID = 95 -- Coupon Account  
          Else If @PayModeType = @OTHERSTYPE                 
           Set @User_AccountID = 96 -- Others Account  
         End  
        /*Entry for Collection Value*/  
        Begin Tran                
         Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
         Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
        Commit Tran                
        Begin Tran                
         Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
         Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
        Commit Tran                
        -- Entry for Userwise PaymentMode  
        Execute sp_acc_insertGJ @TransactionID,@User_AccountID,@InvoiceDate,@AmtRecd,0,@CollectionID,@CollectionType,'Retail Invoice Amendment-Collection',@DocumentNumber  
        -- Entry for Customer Account  
        Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@AmtRecd,@CollectionID,@CollectionType,'Retail Invoice Amendment-Collection',@DocumentNumber                
        Insert Into #TempBackdatedAccounts(AccountID) Values(@User_AccountID)                
        Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
        /*Entry for Service Charge Amount*/  
        If IsNULL(@ServiceCharge,0) <> 0  
         Begin  
          If @PayModeType = @CASHTYPE                
           Set @ServiceCharge_AccountID = 101 -- Cash Service Charge  
          Else If @PayModeType = @CHEQUETYPE                 
           Set @ServiceCharge_AccountID = 102 -- Cheque Service Charge  
          Else If @PayModeType = @CREDITCARDTYPE                
           Set @ServiceCharge_AccountID = 103 -- CreditCards Service Charge  
          Else If @PayModeType = @COUPONTYPE                
           Set @ServiceCharge_AccountID = 104 -- Coupons Service Charge  
          Else If @PayModeType = @OTHERSTYPE                 
           Set @ServiceCharge_AccountID = 105 -- Others Service Charge  
          Begin Tran                
           Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
           Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
          Commit Tran                
          Begin Tran                
           Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
           Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
          Commit Tran                
          -- Entry for Customer Account  
          Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@ServiceCharge,0,@CollectionID,@CollectionType,'Retail Invoice Amendment-Service Charge',@DocumentNumber                
          -- Entry for Service Charge Account  
          Execute sp_acc_insertGJ @TransactionID,@ServiceCharge_AccountID,@InvoiceDate,0,@ServiceCharge,@CollectionID,@CollectionType,'Retail Invoice Amendment-Service Charge',@DocumentNumber                
          Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
          Insert Into #TempBackdatedAccounts(AccountID) Values(@ServiceCharge_AccountID)                
         End  
       End  
      FETCH NEXT FROM ScanCollections Into @CollectionID  
     End    
    CLOSE ScanCollections                
    DEALLOCATE ScanCollections                
-------------------------------Entry for Shortage Amount-------------------------------------  
    If (@Netvalue + @RoundOffAmount) > @SumAmtRecd                
     Begin                
      Begin Tran                
       Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
       Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
      Commit Tran                
      Begin Tran                
       Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
      Commit Tran                
      Set @AdjustedAmount = (@Netvalue + @RoundOffAmount) - @SumAmtRecd                
      -- Entry for Discount Account(write off)  
      Execute sp_acc_insertGJ @TransactionID,@Discount_Account,@InvoiceDate,@AdjustedAmount,0,@InvoiceID,@InvoiceType,'Retail Invoice Amendment',@DocumentNumber  
      -- Entry for Customer Account  
      Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@AdjustedAmount,@InvoiceID,@InvoiceType,'Retail Invoice Amendment',@DocumentNumber  
      Insert Into #TempBackdatedAccounts(AccountID) Values(@Discount_Account)                
  Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
     End                
   End  
 End  
Delete #TempCollections  
--------------------------------Entries for Amended Invoice----------------------------------  
  
Select @ItmSchemeDiscountAmount = Sum(IsNULL(SchemeDiscAmount,0) + IsNULL(SplCatDiscAmount,0)) from InvoiceDetail Where InvoiceID = @InvRefNum                    
If @Vat_Exists  = 1  
 Begin  
  Set @nVatTaxamount = 0   

  Select @RetailCustomerID=IsNULL(CustomerID,0),@InvoiceDate=InvoiceDate,@NetValue=IsNULL(NetValue,0),@TotalSalesTax=IsNULL(TotalTaxApplicable,0)-IsNULL(VATTaxAmount,0),                
  @RetailPaymentMode=PaymentMode,@TradeDiscount=IsNULL(DiscountValue,0),@AdditionalDiscount=IsNULL(AddlDiscountValue,0),@ItemDiscount=IsNULL(ProductDiscount,0),  
  @TotalTaxSuffered=IsNULL(TotalTaxSuffered,0),@RoundOffAmount=IsNULL(RoundOffAmount,0),@InvSchemeDiscountAmount=IsNULL(SchemeDiscountAmount,0),  
  @UserName=UserName,@PaymentDetails=IsNULL(PaymentDetails,N''),@ServiceChargeDetails=ServiceCharge,@AmountRecd = IsNULL(AmountRecd,0)                ,
  @nVatTaxamount = IsNULL(VATTaxAmount,0)  
  from InvoiceAbstract Where InvoiceID=@InvRefNum                

  Set @TaxAmount=@TotalSalesTax+@TotalTaxsuffered+@nVatTaxamount  
 End  
Else  
 Begin  
  Select @RetailCustomerID=IsNULL(CustomerID,0),@InvoiceDate=InvoiceDate,@NetValue=IsNULL(NetValue,0),@TotalSalesTax=IsNULL(TotalTaxApplicable,0),                
  @RetailPaymentMode=PaymentMode,@TradeDiscount=IsNULL(DiscountValue,0),@AdditionalDiscount=IsNULL(AddlDiscountValue,0),@ItemDiscount=IsNULL(ProductDiscount,0),  
  @TotalTaxSuffered=IsNULL(TotalTaxSuffered,0),@RoundOffAmount=IsNULL(RoundOffAmount,0),@InvSchemeDiscountAmount=IsNULL(SchemeDiscountAmount,0),  
  @UserName=UserName,@PaymentDetails=IsNULL(PaymentDetails,N''),@ServiceChargeDetails=ServiceCharge,@AmountRecd = IsNULL(AmountRecd,0)                
  from InvoiceAbstract Where InvoiceID=@InvRefNum                
  Set @TaxAmount=@TotalSalesTax+@TotalTaxsuffered                
 End  
------------------------------------Set Customer AccountID-----------------------------------  
If IsNULL(@RetailCustomerID,0) = N'0' Or IsNULL(@RetailCustomerID,0) = N''   
 Begin  
  Set @Customer_AccountID = 93 /*Retail Customer Account*/  
 End  
Else  
 Begin  
  Select @Customer_AccountID = AccountID from Customer Where CustomerID = @RetailCustomerID  
 End  
--------------------------------------Get CollectionIDs--------------------------------------  
Set @RECSPLIT = N','  
  
Insert Into #TempCollections  
Exec Sp_acc_SQLSplit @PaymentDetails, @RECSPLIT  
------------------------------------Set Internal Remarks-------------------------------------  
If IsNULL(@RetailPaymentMode,0) = 0 /*Zero = Credit RetailInvoice*/  
 Begin  
  Set @InternalRemarks = 'Credit Retail Invoice Amended'  
 End  
Else  
 Begin  
  Set @InternalRemarks = 'Retail Invoice Amended'  
 End  
Set @IntlRmksDisc = @InternalRemarks + N'-Discount On Sales' /*Internal Remarks for DiscountOnSales*/  
Set @IntlRmksRndOff = @InternalRemarks + N'-RoundOff Amount' /*Internal Remarks for RoundOff Amount*/  
Set @IntlRmksSecSch = @InternalRemarks + N'-Secondary Scheme' /*Internal Remarks for Secondary Scheme*/  
--------------------------------------Entry for Sales-----------------------------------------  
Set @SalesValue = IsNULL(@NetValue,0)-IsNULL(@TaxAmount,0)                
If @NetValue > 0  
 Begin                
  /*Get last DocumentNumber from DocumentNumbers Table*/  
  Begin Tran   
   Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
   Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
  Commit Tran     
  Begin Tran                
   Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
  Commit Tran                
    
  If @TotalSalesTax <> 0                
   Begin -- Entry for Sales Tax Account                
    Execute sp_acc_insertGJ @TransactionID,@SalesTax_Account,@InvoiceDate,@TotalSalesTax,0,@InvRefNum,@InvoiceType,@InternalRemarks,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesTax_Account)                
   End                
  If @TotalTaxSuffered <> 0  
   Begin -- Entry for Tax Suffered Account                
    Execute sp_acc_insertGJ @TransactionID,@TaxSuffered_Account,@InvoiceDate,@TotalTaxSuffered,0,@InvRefNum,@InvoiceType,@InternalRemarks,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@TaxSuffered_Account)                
   End                
  If @Vat_Exists = 1  
   Begin  
    If @nVatTaxamount <> 0    
     Begin -- Entry for VAT Tax Account        
      Execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,@nVatTaxamount,0,@InvRefNum,@InvoiceType,@InternalRemarks,@DocumentNumber                
      Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)                
     End  
   End  
  If @SalesValue <> 0                
   Begin -- Entry for Sales Account                
    Execute sp_acc_insertGJ @TransactionID,@Sales_Account,@InvoiceDate,@SalesValue,0,@InvRefNum,@InvoiceType,@InternalRemarks,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Sales_Account)                
   End                
  If @NetValue <> 0                
   Begin -- Entry for Retail Customer Account                
    Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@NetValue,@InvRefNum,@InvoiceType,@InternalRemarks,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
   End                
-----------------------------------Entry for Discount Account----------------------------------                  
  Set @TradeDiscount = @TradeDiscount - @InvSchemeDiscountAmount                    
  Set @ItemDiscount = @ItemDiscount - @ItmSchemeDiscountAmount                    
  Set @TotalDiscount = @TradeDiscount + @AdditionalDiscount + @ItemDiscount                  
  If @TotalDiscount > 0                  
   Begin            
    Begin Tran                  
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                  
     Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                  
    Commit Tran                  
    Begin Tran                  
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                  
     Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51     
    Commit Tran                  
    -- Entry for Sales Account                  
    Execute sp_acc_insertGJ @TransactionID,@Sales_Account,@InvoiceDate,@TotalDiscount,0,@InvRefNum,@InvoiceType,@IntlRmksDisc,@DocumentNumber                  
    -- Entry for Discount Account                  
    Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,0,@TotalDiscount,@InvRefNum,@InvoiceType,@IntlRmksDisc,@DocumentNumber                  
    -- Update #TempBackdatedAccounts for Backdation Purpose                  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesDiscountAccount)                  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Sales_Account)                  
   End                  
  Else If @TotalDiscount < 0                  
   Begin                  
    Set @TotalDiscount = ABS(@TotalDiscount)                  
    Begin Tran     
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                  
     Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                  
    Commit Tran                  
    Begin Tran                  
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                  
     Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                  
    Commit Tran                  
    -- Entry for Discount Account                  
    Execute sp_acc_insertGJ @TransactionID,@SalesDiscountAccount,@InvoiceDate,@TotalDiscount,0,@InvRefNum,@InvoiceType,@IntlRmksDisc,@DocumentNumber                  
    -- Entry for Sales Account                  
    Execute sp_acc_insertGJ @TransactionID,@Sales_Account,@InvoiceDate,0,@TotalDiscount,@InvRefNum,@InvoiceType,@IntlRmksDisc,@DocumentNumber                  
    -- Update #TempBackdatedAccounts for Backdation Purpose                  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@SalesDiscountAccount)                  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Sales_Account)                
   End                  
--------------------------------Entry for RoundOff Amount------------------------------------  
  If @RoundOffAmount > 0                
   Begin                
    Begin Tran                
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
     Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
    Commit Tran                
    Begin Tran                
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51      
     Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
    Commit Tran                
    -- Entry for RoundOff Account                
    Execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,@RoundOffAmount,0,@InvRefNum,@InvoiceType,@IntlRmksRndOff,@DocumentNumber                
    -- Entry for Retail Customer Account                
    Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@RoundOffAmount,@InvRefNum,@InvoiceType,@IntlRmksRndOff,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)                
   End                
  Else If @RoundOffAmount < 0         
   Begin                
    Set @RoundOffAmount = ABS(@RoundOffAmount)                
    Begin Tran   
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
     Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
    Commit Tran                
    Begin Tran                
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
     Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
    Commit Tran                
    -- Entry for Retail Customer Account                
    Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@RoundOffAmount,0,@InvRefNum,@InvoiceType,@IntlRmksRndOff,@DocumentNumber                
    -- Entry for RoundOff Account                
    Execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,0,@RoundOffAmount,@InvRefNum,@InvoiceType,@IntlRmksRndOff,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@RoundOffAccount)                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
    Set @RoundOffAmount = 0 - ABS(@RoundOffAmount)                
   End                
-----------------------------Entry for Secondary Scheme--------------------------------------  
  Set @SecSchemeValue = 0 /* De-Initialize Previous Value*/  
  DECLARE ScanScheme CURSOR KEYSET FOR                
  Select Type from SchemeSale Where InvoiceId=@InvRefNum And IsNULL(SaleType,0) = 0 Group By Type                
  OPEN ScanScheme                
  FETCH FROM ScanScheme Into @Type                
  While @@FETCH_STATUS=0                
   Begin                
    Select @SecScheme=IsNULL(SecondaryScheme,0),@SchemeType=IsNULL(SchemeType,0) from Schemes Where SchemeID=IsNULL(@Type,0)                
    If IsNULL(@SecScheme,0)<>0                
     Begin                
      If IsNULL(@SchemeType,0) = 19 -- Item based percentage scheme type                
       Begin                
        Select @SecSchemeValue= IsNULL(@SecSchemeValue,0) + (Select Sum((IsNULL(Cost,0)*IsNULL(Value,0))/100) from SchemeSale Where InvoiceId=@InvRefNum and Type=@Type And IsNULL(SaleType,0) = 0 Group by Type)                
       End                
      Else                
       Begin                
        Select @SecSchemeValue=IsNULL(@SecSchemeValue,0) + (Select Sum(IsNULL(Cost,0)) from SchemeSale Where InvoiceId=@InvRefNum and Type=@Type And IsNULL(SaleType,0) = 0 Group by Type)                
       End                
     End                
    FETCH NEXT FROM ScanScheme Into @Type                
   End                
  CLOSE ScanScheme                
  DEALLOCATE ScanScheme                
                
  /*Add Invoice Based Secondary Scheme Values to the @SecSchemeValue Variable*/                  
  Select @SchemeID = IsNULL(SchemeID,0), @SchemeDiscountValue = IsNULL(SchemeDiscountAmount,0) from InvoiceAbstract Where InvoiceID = @InvRefNum                        
  Select @SecScheme = IsNULL(SecondaryScheme,0) from Schemes Where SchemeID = @SchemeID                  
  If IsNULL(@SecScheme,0) <> 0                  
   Begin                  
    Set @SecSchemeValue = IsNULL(@SecSchemeValue,0) + IsNULL(@SchemeDiscountValue,0)                  
   End                  
              
  If @SecSchemeValue <> 0                
   Begin                
    Begin Tran                
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
     Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
    Commit Tran                
    Begin Tran                
     Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
     Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
    Commit Tran                
    -- Entry for Claims Receivable Account                
    Execute sp_acc_insertGJ @TransactionID,@ClaimsRecivable,@InvoiceDate,@SecSchemeValue,0,@InvRefNum,@InvoiceType,@IntlRmksSecSch,@DocumentNumber                
    -- Entry for SecondarySchemeExpense Account           
    Execute sp_acc_insertGJ @TransactionID,@SecondarySchemeExpense,@InvoiceDate,0,@SecSchemeValue,@InvRefNum,@InvoiceType,@IntlRmksSecSch,@DocumentNumber                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@SecondarySchemeExpense)                
    Insert Into #TempBackdatedAccounts(AccountID) Values(@ClaimsRecivable)                
   End                
------------------------------Entry for PaymentMode(Collections)-----------------------------  
  /*De-Initiliaze Previous Values*/  
  Set @SumServiceCharge = 0  
  Set @SumAmtRecd = 0  
  If IsNULL(@RetailPaymentMode,0) <> 0  
   Begin  
    DECLARE ScanCollections CURSOR KEYSET FOR  
    Select CollectionID from #TempCollections  
    OPEN ScanCollections  
    FETCH FROM ScanCollections Into @CollectionID  
    WHILE @@FETCH_STATUS = 0  
     Begin  
      Select @PayModeID = PaymentModeID, @AmtRecd = Value, @ColtnPayMode = PaymentMode, @ServiceCharge = IsNULL(CustomerServiceCharge,0) from Collections Where DocumentID = @CollectionID  
      Select @PayModeName = Value, @PayModeType = IsNULL(PaymentType,0) from PaymentMode Where Mode = @PayModeID  
      Set @SumAmtRecd = IsNULL(@SumAmtRecd,0) + IsNULL(@AmtRecd,0)  
      Set @SumServiceCharge = IsNULL(@SumServiceCharge,0) + IsNULL(@ServiceCharge,0)                
      Set @AmtRecd = @AmtRecd + IsNULL(@ServiceCharge,0)  
      Set @Discount = 0   
      Set @Total = 0  
      If @ColtnPayMode = 7   
       Begin  
        Select @Total = IsNULL(Adjustedamount,0) + IsNULL(Adjustment,0) , @AdjustedAmount = IsNULL(Adjustedamount,0),@Discount = IsNULL(Adjustment,0)  
        From CollectionDetail where collectionid = @CollectionID  and DocumentType = N'6' -- Invoice  
        -- Entry for Userwise PaymentMode  
        If IsNULL(@Total,0) <> 0   
         Begin  
          Begin Tran                
           Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
           Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
          Commit Tran                
          Begin Tran                
           Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
           Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
          Commit Tran               
          -- Entry for Customer Account  
          Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@Total,0,@CollectionID,@CollectionCancelType,'Retail Invoice Amended-Redeem Collection',@DocumentNumber                
          Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
            
          If IsNULL(@AdjustedAmount,0) > 0   
           Begin  
            Execute sp_acc_insertGJ @TransactionID,@Gift_Voucher,@InvoiceDate,0,@AdjustedAmount,@CollectionID,@CollectionCancelType,'Retail Invoice Amended-Redeem Collection',@DocumentNumber  
            Insert Into #TempBackdatedAccounts(AccountID) Values(@Gift_Voucher)                
           End  
          If IsNULL(@Discount,0) > 0   
           Begin  
            Execute sp_acc_insertGJ @TransactionID,@Discount_Account,@InvoiceDate,0,@Discount,@CollectionID,@CollectionCancelType,'Retail Invoice Amended-Redeem Collection',@DocumentNumber  
            Insert Into #TempBackdatedAccounts(AccountID) Values(@Discount_Account)                
           End  
         End  
       End  
      Else If IsNULL(@AmtRecd,0) <> 0 And @ColtnPayMode <> 6 /*6 = Credit Note Adjustments*/  
       Begin                
        Select @RetailUserWise = IsNULL(RetailUserWise, 0) from Collections Where DocumentID = @CollectionID  
   If @RetailUserWise = 1 /*Then It should go to the LocalUser Account*/  
         Begin  
          If NOT EXISTS(Select Top 1 AccountID from AccountsMaster Where UserName = @Username And RetailPaymentMode = @PayModeID)  
           Begin                
            Set @AccountName = @PayModeName + N'-' + @UserName  
            If @PayModeType = @CASHTYPE                
             Set @GroupID = 19 -- CashInHand AccountGroup                 
            Else If @PayModeType = @CHEQUETYPE                 
             Set @GroupID = 20 -- ChequesInHand AccountGroup                
            Else If @PayModeType = @CREDITCARDTYPE                
             Set @GroupID = 50 -- CreditCardsInHand AccountGroup                 
            Else If @PayModeType = @COUPONTYPE                
             Set @GroupID = 51 -- CouponsInHand AccountGroup                    
            Else If @PayModeType = @OTHERSTYPE                 
             Set @GroupID = 52 -- OthersInHand AccountGroup                   
            Exec sp_acc_insertaccounts @AccountName, @GroupID, 0                
            Set @User_AccountID = @@Identity                
            Update AccountsMaster Set UserName = @UserName, RetailPaymentMode = @PayModeID Where AccountID = @User_AccountID           
           End                
          Else                
           Begin                 
            Select @User_AccountID = AccountID from AccountsMaster Where UserName = @Username and RetailPaymentMode = @PayModeID                
           End                
         End          
        Else  
         Begin  
          If @PayModeType = @CASHTYPE                
           Set @User_AccountID = 3 -- Cash Account  
          Else If @PayModeType = @CHEQUETYPE                 
           Set @User_AccountID = 7 -- Cheque In Hand Account  
          Else If @PayModeType = @CREDITCARDTYPE                
           Set @User_AccountID = 94 -- CreditCard Account  
          Else If @PayModeType = @COUPONTYPE                
           Set @User_AccountID = 95 -- Coupon Account  
          Else If @PayModeType = @OTHERSTYPE                 
           Set @User_AccountID = 96 -- Others Account  
         End  
        /*Entry for Collection Value*/  
        Begin Tran                
         Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
         Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
        Commit Tran                
        Begin Tran                
         Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
         Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
        Commit Tran                
-- Entry for Customer Account  
        Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@AmtRecd,0,@CollectionID,@CollectionCancelType,'Retail Invoice Amended-Collection',@DocumentNumber                
        -- Entry for Userwise PaymentMode  
        Execute sp_acc_insertGJ @TransactionID,@User_AccountID,@InvoiceDate,0,@AmtRecd,@CollectionID,@CollectionCancelType,'Retail Invoice Amended-Collection',@DocumentNumber  
        Insert Into #TempBackdatedAccounts(AccountID) Values(@User_AccountID)                
        Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
        /*Entry for Service Charge Amount*/  
        If IsNULL(@ServiceCharge,0) <> 0  
         Begin  
          If @PayModeType = @CASHTYPE                
           Set @ServiceCharge_AccountID = 101 -- Cash Service Charge  
          Else If @PayModeType = @CHEQUETYPE                 
           Set @ServiceCharge_AccountID = 102 -- Cheque Service Charge  
          Else If @PayModeType = @CREDITCARDTYPE                
           Set @ServiceCharge_AccountID = 103 -- CreditCards Service Charge  
      Else If @PayModeType = @COUPONTYPE                
           Set @ServiceCharge_AccountID = 104 -- Coupons Service Charge  
          Else If @PayModeType = @OTHERSTYPE                 
           Set @ServiceCharge_AccountID = 105 -- Others Service Charge  
          Begin Tran                
           Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
           Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
          Commit Tran                
          Begin Tran                
           Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
           Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
          Commit Tran                
          -- Entry for Service Charge Account  
          Execute sp_acc_insertGJ @TransactionID,@ServiceCharge_AccountID,@InvoiceDate,@ServiceCharge,0,@CollectionID,@CollectionCancelType,'Retail Invoice Amended-Service Charge',@DocumentNumber                
          -- Entry for Customer Account  
          Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,0,@ServiceCharge,@CollectionID,@CollectionCancelType,'Retail Invoice Amended-Service Charge',@DocumentNumber                
          Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
          Insert Into #TempBackdatedAccounts(AccountID) Values(@ServiceCharge_AccountID)                
         End  
       End  
      FETCH NEXT FROM ScanCollections Into @CollectionID  
     End    
    CLOSE ScanCollections                
    DEALLOCATE ScanCollections                
-------------------------------Entry for Shortage Amount-------------------------------------  
    If (@Netvalue + @RoundOffAmount) > @SumAmtRecd                
     Begin                
      Begin Tran                
       Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=24                
       Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24                
      Commit Tran                
      Begin Tran                
       Update DocumentNumbers set DocumentID=DocumentID+1 Where DocType=51                
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers Where DocType=51                
      Commit Tran                
      Set @AdjustedAmount = (@Netvalue + @RoundOffAmount) - @SumAmtRecd                
      -- Entry for Customer Account  
      Execute sp_acc_insertGJ @TransactionID,@Customer_AccountID,@InvoiceDate,@AdjustedAmount,0,@InvRefNum,@InvoiceType,'Retail Invoice Amended',@DocumentNumber  
      -- Entry for Discount Account(write off)  
      Execute sp_acc_insertGJ @TransactionID,@Discount_Account,@InvoiceDate,0,@AdjustedAmount,@InvRefNum,@InvoiceType,'Retail Invoice Amended',@DocumentNumber  
      Insert Into #TempBackdatedAccounts(AccountID) Values(@Discount_Account)                
      Insert Into #TempBackdatedAccounts(AccountID) Values(@Customer_AccountID)                
     End                
   End  
 End  
Drop Table #TempCollections  
---------------------------------------Backdated Operation-----------------------------------  
If @BackDate Is Not Null                  
Begin                
 Declare @TempAccountID INT                
 DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR               
 Select AccountID From #TempBackdatedAccounts                
 OPEN scantempbackdatedaccounts                
 FETCH FROM scantempbackdatedaccounts Into @TempAccountID                
 WHILE @@FETCH_STATUS =0                
 Begin                
  Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID                
  FETCH NEXT FROM scantempbackdatedaccounts Into @TempAccountID                
 End                
 CLOSE scantempbackdatedaccounts   
 DEALLOCATE scantempbackdatedaccounts                
End                
Drop Table #TempBackdatedAccounts  
GOTO EXITPROC /*All done for New Implementation So Just Exit*/  
---------------------------------Old Implementation of Retail Invoice------------------------  
OLDIMPL: /*This will handle the Old Implementation*/  
 Exec sp_acc_gj_RetailInvoiceAmendmentOld @InvoiceID, @BackDate  
EXITPROC: 

