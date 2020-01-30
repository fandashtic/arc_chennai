
create procedure sp_get_PaymentID
as
select DocumentID from DocumentNumbers where DocType = 13

