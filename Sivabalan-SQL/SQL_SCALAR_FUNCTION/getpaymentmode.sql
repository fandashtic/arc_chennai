CREATE function getpaymentmode(@accountid int)
returns int
as 
begin
declare @paymentmode int
select @paymentmode = isnull([RetailPaymentMode],0) from AccountsMaster
where [AccountID]= @accountid
return @paymentmode
end


