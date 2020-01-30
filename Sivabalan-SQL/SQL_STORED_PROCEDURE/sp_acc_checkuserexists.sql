create procedure sp_acc_checkuserexists(@username nvarchar(50))
as
select UserName from Users
where UserName = @username


