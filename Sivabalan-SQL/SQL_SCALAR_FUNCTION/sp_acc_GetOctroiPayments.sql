CREATE Function sp_acc_GetOctroiPayments(@BillID Integer, @DocType Integer)  
Returns Decimal(18,6)  
As  
Begin  
Declare @ReturnValue Decimal(18,6)  
Declare @PaymentID Integer  
  
Declare @Bill Integer  
Set @Bill = 8  
  
If @DocType = @Bill  
 Begin
  Select @PaymentID = FAPaymentID from BillAbstract Where BillID = @BillID  
  Select @ReturnValue = Value from Payments Where DocumentID = @PaymentID  
 End

Return IsNull(@ReturnValue,0)  
End  

