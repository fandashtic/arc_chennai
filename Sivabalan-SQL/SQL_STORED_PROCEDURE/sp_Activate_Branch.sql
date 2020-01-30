
CREATE procedure sp_Activate_Branch (@BranchCode nvarchar(10), @Active int, @BankCode nvarchar(10))
as
Update BranchMaster Set Active = @Active Where BranchCode = @BranchCode and BankCode = @BankCode

