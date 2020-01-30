


CREATE procedure sp_acc_cancelpettycashpayment(@paymentid integer)
as
update Payments 
set [Status]= 192
where [DocumentID]= @paymentid



