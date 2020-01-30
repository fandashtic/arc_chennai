CREATE procedure sp_acc_cancelfapayments(@paymentid integer,@denominations nvarchar(2000))
as
update Payments set [Status]= 192,
[Denominations]= @denominations
where [DocumentID]= @paymentid
