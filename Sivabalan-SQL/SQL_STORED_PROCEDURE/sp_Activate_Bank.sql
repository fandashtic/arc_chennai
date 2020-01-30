
create procedure sp_Activate_Bank (@BankCode nvarchar(10), @Active int)
as
Update BankMaster Set Active = @Active Where BankCode = @BankCode

