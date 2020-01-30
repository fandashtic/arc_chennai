
create proc sp_update_paymentdate_invoice( @PAYMENTDATE  datetime , @INVOICEID int)
as
update invoiceabstract set PaymentDate = @paymentdate where invoiceid = @invoiceid


