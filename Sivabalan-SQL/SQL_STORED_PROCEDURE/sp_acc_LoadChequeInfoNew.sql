CREATE Procedure sp_acc_LoadChequeInfoNew (@AccountID INT,@PaymentType INT)                  
As                  
Declare @User nVarChar(50)                  
Declare @PaymentMode INT                
Declare @PaymentModeValue nVarChar(255)                  
Declare @ProviderServiceCharge Decimal(18,6)                
Declare @InvPrefix nVarChar(10)                  
                  
Declare @CHEQUE INT                  
Declare @CREDITCARD INT                  
Declare @COUPON INT                  
                  
Set @CHEQUE = 2                  
Set @CREDITCARD = 3                  
Set @COUPON = 4                  
                  
Select @InvPrefix = Prefix from VoucherPrefix Where TranID = N'INVOICE'                  
                  
Select @User = UserName, @PaymentModeValue = Value, @PaymentMode = PaymentMode.Mode          
from AccountsMaster, PaymentMode Where AccountID = @AccountID                 
And PaymentMode.PaymentType = @PaymentType And PaymentMode.Mode = AccountsMaster.RetailPaymentMode                
                 
Set @PaymentModeValue = RTrim(LTrim(@PaymentModeValue))                
                  
If @PaymentType = @CHEQUE                  
 Begin                
  Select 'CollectionID' = Collections.FullDocID, 'InvoiceID' = @InvPrefix + CAST(InvoiceAbstract.DocumentID As nVarChar(20)),                
  'CollectionDate' = Collections.DocumentDate, 'Amount' = (Collections.Value + IsNULL(CustomerServiceCharge, 0)),                 
  'Cheque Number' = Collections.ChequeNumber, 'Cheque Date' = Collections.ChequeDate,                
  'Bank' = (Select BankName from BankMaster Where BankMaster.BankCode = Collections.BankCode),                
  'Branch' = (Select BranchName from BranchMaster Where BranchMaster.BankCode = Collections.BankCode                 
  And BranchMaster.BranchCode = Collections.BranchCode), 'Customer' = Case When IsNULL(InvoiceAbstract.CustomerID,0) = N'0' Then                 
  dbo.LookupDictionaryItem('WalkIn Customer',Default) Else (Select Company_Name from Customer Where CustomerID = InvoiceAbstract.CustomerID) End,                 
  'BankID' = Collections.BankCode, 'BranchID' = Collections.BranchCode, 'DocumentID' = Collections.DocumentID,                 
  'PaymentMode' = @PaymentModeValue from Collections, CollectionDetail, InvoiceAbstract                
  Where Collections.DocumentID = CollectionDetail.CollectionID And CollectionDetail.DocumentID = InvoiceAbstract.InvoiceID                
  And InvoiceAbstract.UserName = @User And InvoiceAbstract.InvoiceType = 2         
  And (IsNULL(Collections.RetailUserwise, 0) & 1) = 1 And (IsNULL(Collections.Status,0) & 192) = 0        
  And IsNULL(Collections.PaymentModeID, 0) = @PaymentMode And IsNULL(Collections.PaymentMode, 0) = 1 /* Cheque */                
  And Collections.DocumentID Not In (Select DocumentReference from ContraDetail, ContraAbstract                
  Where DocumentType = 2 And PaymentType = @CHEQUE And FromAccountID = @AccountID /*DocumentType 2 = CollectionsTable*/  
  And (IsNULL(Status, 0) & 192) = 0 And ContraDetail.ContraID = ContraAbstract.ContraID)                
 End                  
Else If @PaymentType = @CREDITCARD                
 Begin                
  Select 'CollectionID' = Collections.FullDocID, 'InvoiceID' = @InvPrefix + CAST(InvoiceAbstract.DocumentID As nVarChar(20)),                
  'CollectionDate' = Collections.DocumentDate, 'Amount' = (Collections.Value + IsNULL(CustomerServiceCharge, 0)),  
  'ServiceCharge' = IsNULL(ProviderServiceCharge,0), 'CreditCardNumber' = Collections.CreditCardNumber,                 
  'Party' = (Select Account_Number from Bank Where Bank.BankID = Collections.BankID),                
  'Customer' = Case When IsNull(CardHolder,N'') <> N'' Then CardHolder Else Case When IsNULL(InvoiceAbstract.CustomerID,0) = N'0' Then                 
  dbo.LookupDictionaryItem('WalkIn Customer',Default) Else (Select Company_Name from Customer Where CustomerID = InvoiceAbstract.CustomerID) End End,                 
  'PartyAccountID' = (Select AccountID from Bank Where Bank.BankID = Collections.BankID), 'DocumentID' = Collections.DocumentID,                 
  'PaymentMode' = @PaymentModeValue from Collections, CollectionDetail, InvoiceAbstract                
  Where Collections.DocumentID = CollectionDetail.CollectionID And CollectionDetail.DocumentID = InvoiceAbstract.InvoiceID                
  And InvoiceAbstract.UserName = @User And InvoiceAbstract.InvoiceType = 2         
  And (IsNULL(Collections.RetailUserwise, 0) & 1) = 1 And (IsNULL(Collections.Status,0) & 192) = 0        
  And IsNULL(Collections.PaymentModeID, 0) = @PaymentMode And IsNULL(Collections.PaymentMode, 0) = 3 /* CreditCard */                
  And Collections.DocumentID Not In (Select DocumentReference from ContraDetail, ContraAbstract                
  Where DocumentType = 2 And PaymentType = @CREDITCARD And FromAccountID = @AccountID /*DocumentType 2 = CollectionsTable*/  
  And (IsNULL(Status, 0) & 192) = 0 And ContraDetail.ContraID = ContraAbstract.ContraID)                
 End                  
Else If @PaymentType = @COUPON                  
 Begin                
  Select 'CollectionID' = Collections.FullDocID, 'InvoiceID' = @InvPrefix + CAST(InvoiceAbstract.DocumentID As nVarChar(20)),                
  'CollectionDate' = Collections.DocumentDate, 'FromSerial' = Coupon.FromSerial,                 
  'ToSerial' = Coupon.ToSerial, 'Qty' = Coupon.Qty, 'Value' = Coupon.Denomination,            
  'Amount' = Coupon.Value, 'Party' = (Select AccountName from AccountsMaster Where AccountID = Collections.BankID),  
  'ServiceCharge' = IsNULL(ProviderServiceCharge, 0), 'PartyAccountID' = IsNULL(Collections.BankID, 0),                
  'DocumentID' = Coupon.SerialNo, 'PaymentMode' = @PaymentModeValue                 
  from Collections, CollectionDetail, InvoiceAbstract, Coupon                
  Where Collections.DocumentID = CollectionDetail.CollectionID And CollectionDetail.DocumentID = InvoiceAbstract.InvoiceID                
  And InvoiceAbstract.UserName = @User And InvoiceAbstract.InvoiceType = 2         
  And (IsNULL(Collections.RetailUserwise, 0) & 1) = 1 And (IsNULL(Collections.Status,0) & 192) = 0        
  And IsNULL(Collections.PaymentModeID, 0) = @PaymentMode And IsNULL(Collections.PaymentMode, 0) = 5 /* Coupon */                
  And Coupon.CollectionID = Collections.DocumentID And Coupon.SerialNo Not In (Select DocumentReference       
  from ContraDetail, ContraAbstract Where DocumentType = 3 And PaymentType = @COUPON /*DocumentType 3 = CouponTable*/  
  And FromAccountID = @AccountID And (IsNULL(Status, 0) & 192) = 0 And ContraDetail.ContraID = ContraAbstract.ContraID)             
 End 
