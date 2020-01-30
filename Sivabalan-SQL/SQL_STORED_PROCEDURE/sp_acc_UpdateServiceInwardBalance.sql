Create Procedure sp_acc_UpdateServiceInwardBalance(@Invoiceid int,@Adjusted Decimal(18,2))
as
Update ServiceAbstract  Set Balance = Balance - @Adjusted Where InvoiceID = @Invoiceid
