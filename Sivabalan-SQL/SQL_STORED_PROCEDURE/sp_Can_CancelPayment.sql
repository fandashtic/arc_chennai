CREATE Procedure sp_Can_CancelPayment(@PaymentID Int)
As
--Restrict implicit payments that were done during bill
If Exists(Select * From BillAbstract Where PaymentID = @PaymentID)
Begin
	Select 0
End
--This check is to verify whether the current selected paymentid has
--been already adjusted in any other payment transaction.
Else If Exists(Select PaymentID From Payments, PaymentDetail Where 
PaymentDetail.DocumentID = @PaymentID And 
--PaymentDetail.DocumentId means adjusted Documentid
--Payments.DocumentId means Payment Transaction Identity Field
--PaymentDetail.PaymentID means Payment Transaction Identity Field
Payments.DocumentID = PaymentDetail.PaymentID And
PaymentDetail.DocumentType = 3 And
IsNull(Payments.Status, 0) & 128 = 0)
Begin
	Select 0
End
--Allow the payment transaction to cancel or amend only when the payment value
--and its balance are same.
Else
Begin
	Select 1
-- 	Select Case When Payments.Balance = Payments.Value Then 1 Else 0 End
-- 	From Payments Where DocumentID = @PaymentID And IsNull(Payments.Status, 0) & 128 = 0
End

