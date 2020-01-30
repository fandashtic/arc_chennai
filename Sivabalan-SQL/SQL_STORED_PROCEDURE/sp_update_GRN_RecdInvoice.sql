CREATE Procedure sp_update_GRN_RecdInvoice(@GRNID Int,
					   @RecdInvoiceID Int)
As
Update GRNAbstract Set RecdInvoiceID = @RecdInvoiceID Where GRNID = @GRNID
IF (SELECT SUM(Pending) from InvoiceDetailReceived WHERE InvoiceID = @RecdInvoiceID) = 0
Update InvoiceAbstractReceived Set Status = IsNull(Status, 1) | 129 Where InvoiceID = @RecdInvoiceID
Else
Update InvoiceAbstractReceived Set Status = 32 | 128 Where InvoiceID = @RecdInvoiceID
--Update InvoiceAbstractReceived Set Status = IsNull(Status,0) | 32 Where InvoiceID = @RecdInvoiceID
