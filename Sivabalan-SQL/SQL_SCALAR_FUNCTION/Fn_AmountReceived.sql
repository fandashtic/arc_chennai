CREATE function Fn_AmountReceived(@invID as int)  
Returns Decimal(18,6)  
As  
Begin  
Declare @PaymentIDs Varchar(4000)  
Declare @AmountReceived Decimal(18,6)  
  
Select @PaymentIDs = PaymentDetails from InvoiceAbstract Where InvoiceID = @invID  
  
Select @AmountReceived = IsNull(Sum(Value),0) From Collections  
Where Cast(DocumentID As Varchar) In (Select * from Dbo.SP_SplitIn2Rows(@PaymentIDs,','))
  
Return @AmountReceived
  
End  


