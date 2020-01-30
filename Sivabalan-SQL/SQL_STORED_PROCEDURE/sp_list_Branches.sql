
create procedure sp_list_Branches (@BankCode nvarchar(25))
as
Select BranchCode, BranchName From BranchMaster Where BankCode = @BankCode

