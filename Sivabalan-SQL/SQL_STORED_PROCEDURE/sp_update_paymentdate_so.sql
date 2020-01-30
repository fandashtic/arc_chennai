
create proc sp_update_paymentdate_so( @PAYMENTDATE  datetime , @SONUMBER int)
as
update soabstract set PaymentDate = @paymentdate where sonumber = @sonumber



