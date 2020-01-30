CREATE Procedure sp_acc_UpdateFAPaymentID(@BillID As Integer, @PaymentID As Integer)
As
Update BillAbstract 
Set FAPaymentID = @PaymentID
Where BillID = @BillID

