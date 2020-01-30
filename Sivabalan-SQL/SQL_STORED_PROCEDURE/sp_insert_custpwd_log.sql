CREATE procedure sp_insert_custpwd_log (
@CustID nvarchar(20),
@OldPwd nvarchar(200),
@NewPwd nvarchar(200),
@UserName nvarchar(50),
@Type as char(2)
)
as
if @OldPwd <> @NewPwd 
begin
insert into passwordlog (customerid, oldpassword, newpassword, username, TransactionDate, Type) 
values 
(@CustID, @OldPwd, @NewPwd, @UserName, getdate(), @Type)
end



