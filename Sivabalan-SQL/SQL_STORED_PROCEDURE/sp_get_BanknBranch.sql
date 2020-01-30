CREATE procedure sp_get_BanknBranch (@Customer nvarchar(15))
as
Select Top 1 Collections.BankCode, BankMaster.BankName, Collections.BranchCode, 
BranchMaster.BranchName From Collections, BranchMaster, BankMaster
Where Collections.CustomerID = @Customer And
Collections.BankCode = BankMaster.BankCode And
Collections.BranchCode = BranchMaster.BranchCode And
Collections.BankCode = BranchMaster.BankCode
Order By Collections.DocumentDate Desc
