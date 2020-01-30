


create procedure sp_acc_updatecancelpayments(@transactionid int,@adjustedamount decimal(18,6) )
as
update Payments
set Balance = Balance  + @adjustedamount
where DocumentID = @transactionid



