



create function getpaidtoaccount(@paymentid integer)
returns nvarchar(50)
as 
begin
declare @accountname nvarchar(50)
select @accountname= AccountsMaster.AccountName from PaymentDetail,AccountsMaster 
where [PaymentID]= @paymentid
return @accountname
end





