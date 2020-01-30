



create function getstaffname(@staffid integer)
returns nvarchar(50)
as 
begin
declare @staffname nvarchar(50)
select @staffname = AccountName from AccountsMaster 
where AccountID = @staffid
return @staffname
end




