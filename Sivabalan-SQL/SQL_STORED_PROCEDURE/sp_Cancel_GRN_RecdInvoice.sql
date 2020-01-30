CREATE Procedure sp_Cancel_GRN_RecdInvoice(@GRNID Int)
As
Declare @RecdInvoiceID Int
Select @RecdInvoiceID = RecdInvoiceID  From GRNAbstract Where GRNID = @GRNID
Update InvoiceAbstractReceived Set Status = 0 Where InvoiceID = @RecdInvoiceID

