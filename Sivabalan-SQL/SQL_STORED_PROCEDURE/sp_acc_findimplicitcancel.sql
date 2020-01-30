
Create Procedure sp_acc_findimplicitcancel(@InvoiceID Int)
As
Declare @PaymentDetails Int

SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @InvoiceID) as int)
IF Exists (select DocumentID from collections Where (IsNull(Status,0) & 64) = 0 And DocumentID = @PaymentDetails)
BEGIN
Select 1
END
ELSE
BEGIN
Select 0
END

