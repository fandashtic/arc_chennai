CREATE Procedure sp_acc_CancelBillFAPayment(@PaymentID As Integer)
As
Declare @PaymentDate Datetime
Select @PaymentDate = DocumentDate from Payments Where DocumentID = @PaymentID
Set @PaymentDate = dbo.stripdatefromtime(@PaymentDate)
---------------------------Update Status First---------------------------------------------
Update Payments Set Status = (IsNull(Status,0) | 192) Where DocumentID = @PaymentID
-------------------Pass Journal Entries for the Closed Payment-----------------------------
Exec sp_acc_gj_paymentcancellation @PaymentID,@PaymentDate

