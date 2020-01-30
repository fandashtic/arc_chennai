Create Procedure sp_acc_UpdateCancelServiceInward(@InvoiceID int,@AdjustedAmount decimal(18,6))
as

Update ServiceAbstract Set Balance = Balance + @AdjustedAmount  Where InvoiceID = @InvoiceID

