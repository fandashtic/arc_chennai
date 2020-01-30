


Create procedure sp_acc_get_BanknBranch (@Party Int)
as
Select Top 1 Collections.BankCode, BankMaster.BankName, Collections.BranchCode, 
BranchMaster.BranchName From Collections, BranchMaster, BankMaster
Where Collections.Others = @Party And
Collections.BankCode = BankMaster.BankCode And
Collections.BranchCode = BranchMaster.BranchCode And
Collections.BankCode = BranchMaster.BankCode
Order By Collections.DocumentDate Desc





