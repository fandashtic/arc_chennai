


create procedure sp_acc_getpaymentdenomination(@paymentid integer)
as
select Denominations from Payments
where DocumentID =@paymentid





