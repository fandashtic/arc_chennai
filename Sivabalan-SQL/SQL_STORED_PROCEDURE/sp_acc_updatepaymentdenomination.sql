


create procedure sp_acc_updatepaymentdenomination(@paymentid integer,@denominations nvarchar(2000))
as
update Payments
set Denominations = @denominations
where DocumentID = @paymentid





