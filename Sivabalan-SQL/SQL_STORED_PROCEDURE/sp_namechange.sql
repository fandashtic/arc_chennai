CREATE procedure sp_namechange (@Oldid nvarchar(15), @newname nvarchar(50),
@Changedate datetime, @username nvarchar(30))
as 
declare @oldname nvarchar(30)
select @oldname = Company_Name from Customer where CustomerId = @Oldid

update Customer set Company_name = @newname where CustomerId = @Oldid

insert into namechange (ID_Value,Old_Name,New_Name,Change_Date,UserName,Type)
values(@Oldid,@oldname,@newname,@changedate,@username,0)

