CREATE function getaccountname(@accountid integer)
returns nvarchar(255)
as 
begin
 declare @account nvarchar(255)
 select @account = [AccountName] from AccountsMaster where [AccountID]= @accountid
 return @account
end
