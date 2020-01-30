CREATE Procedure [dbo].[sp_acc_GetContraDetailNew] (@PaymentType As INT, @PartyAccountID As INT)          
As          
If @PaymentType = 3 /*Credit Card*/          
 Begin          
  Select 0 'Checked', Collections.DocumentID 'DOCID', FullDocID,           
  'Name' = Case When IsNULL(Collections.CustomerID,N'') <> N'' Then 
  (Select Company_Name from Customer Where CustomerID = Collections.CustomerID)
  Else Case When IsNULL(Collections.Others,N'') <> N'' Then
  (Select AccountName from AccountsMaster Where AccountID = Collections.Others)
  Else IsNULL(CardHolder,N'') End End,
  CreditCardNumber, dbo.LookupDictionaryItem(PayMentMode.Value,Default) 'CreditCardType', IsNULL(ContraDetail.OriginalID,N'') 'INVID',           
  'Amount' = (Collections.Value + IsNull(Collections.CustomerServiceCharge, 0)),           
  IsNULL(ProviderServiceCharge, 0) 'ServiceCharge', IsNULL(ContraSerialCode, 0) 'ContraSerial'        
  from Collections
  Inner Join Bank on Collections.BankID = Bank.BankID 
  Inner Join PaymentMode on Collections.PaymentModeID = PaymentMode.Mode
  Left Join ContraDetail on Collections.DocumentID = ContraDetail.DocumentReference 

  --Collections, Bank, PaymentMode, ContraDetail          
  Where 
  --Collections.BankID = Bank.BankID 
  --And Collections.PaymentModeID = PaymentMode.Mode          
  --And Collections.DocumentID *= ContraDetail.DocumentReference          
  --And 
  dbo.sp_acc_CheckContraStatus(ContraSerialCode) = 1          
  And ContraDetail.PaymentType = 3 And ContraDetail.ToAccountID = 94           
  And AdditionalInfo_Party = @PartyAccountID And IsNULL(AdjustedFlag, 0) = 0          
  And (IsNULL(Collections.Status, 0) & 192) = 0 And IsNULL(Collections.PaymentMode, 0) = 3          
  And IsNULL(OtherDepositID, 0) = 0 And Bank.AccountID = @PartyAccountID          
  And ContraDetail.DocumentType = 2 And (((IsNULL(Collections.RetailUserwise, 0) & 1) = 0)           
  Or ((IsNULL(Collections.RetailUserwise, 0) & 1) = 1) And Collections.DocumentID In           
  (Select DocumentReference from ContraDetail, ContraAbstract Where DocumentType = 2          
  And ContraAbstract.ContraID = ContraDetail.ContraID And (IsNULL(ContraAbstract.Status, 0) & 192) = 0          
  And PaymentType = @PaymentType And ContraAbstract.ToUser = N'Main' And ToAccountID = 94          
  And AdditionalInfo_Party = @PartyAccountID And IsNULL(AdjustedFlag, 0) = 0))          
 End          
Else If @PaymentType = 4 /*Coupon*/          
 Begin          
  Select 0 'Checked', Coupon.SerialNO 'DOCID', Collections.FullDocID,           
  'Name' = Case When IsNULL(Collections.CustomerID,N'') <> N'' Then 
  (Select Company_Name from Customer Where CustomerID = Collections.CustomerID)
  Else Case When IsNULL(Collections.Others,N'') <> N'' Then
  (Select AccountName from AccountsMaster Where AccountID = Collections.Others)
  Else IsNULL(CardHolder,N'') End End,
  dbo.LookupDictionaryItem(PaymentMode.Value,Default) 'CouponName', Coupon.Qty 'Qty', Coupon.Denomination 'Rate', Coupon.Value 'Amount',           
  Collections.ProviderServiceCharge 'ServiceCharge', IsNULL(ContraSerialCode, 0) 'ContraSerial'           
  from Collections
  Inner Join PaymentMode on Collections.PaymentModeID = PaymentMode.Mode
  Inner Join Coupon on Coupon.CollectionID = Collections.DocumentID
  Left Join ContraDetail on Coupon.SerialNo = ContraDetail.DocumentReference
  --ContraDetail          
  --Collections, Coupon, PaymentMode, ContraDetail          
  Where 
  --Collections.PaymentModeID = PaymentMode.Mode And Coupon.CollectionID = Collections.DocumentID          
  --And Coupon.SerialNo *= ContraDetail.DocumentReference          
  --And 
  dbo.sp_acc_CheckContraStatus(ContraSerialCode) = 1          
  And ContraDetail.PaymentType = 4 And ContraDetail.ToAccountID = 95           
  And AdditionalInfo_Party = @PartyAccountID And IsNULL(AdjustedFlag, 0) = 0          
  And (IsNULL(Collections.Status, 0) & 192) = 0 And IsNULL(Collections.PaymentMode, 0) = 5          
  And IsNULL(CouponDepositID, 0) = 0 And IsNull(BankID,0) =  @PartyAccountID          
  And ContraDetail.DocumentType = 3 And (((IsNULL(Collections.RetailUserwise, 0) & 1) = 0)           
  Or ((IsNULL(Collections.RetailUserwise, 0) & 1) = 1) And Coupon.SerialNo In      
  (Select DocumentReference from ContraDetail, ContraAbstract Where DocumentType = 3          
  And ContraAbstract.ContraID = ContraDetail.ContraID And (IsNULL(ContraAbstract.Status, 0) & 192) = 0          
  And PaymentType = @PaymentType And ContraAbstract.ToUser = N'Main' And ToAccountID = 95          
  And AdditionalInfo_Party = @PartyAccountID And IsNULL(AdjustedFlag, 0) = 0))          
 End 

