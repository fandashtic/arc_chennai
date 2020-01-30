



create function getbank(@bankid nvarchar(15))
returns nvarchar(50)
as 
begin
declare @bankname nvarchar(50)
select @bankname = [BankName] from BankMaster 
where [BankCode]= @bankid
return @bankname
end




