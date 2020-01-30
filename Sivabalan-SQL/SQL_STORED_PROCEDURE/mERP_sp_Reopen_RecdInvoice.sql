CREATE PROCEDURE mERP_sp_Reopen_RecdInvoice(@RecdInvID INT)
AS

Update InvoiceAbstractReceived Set Status = 0 where InvoiceID = @RecdInvID
Update InvoiceDetailReceived Set Pending = Quantity where InvoiceID = @RecdInvID

