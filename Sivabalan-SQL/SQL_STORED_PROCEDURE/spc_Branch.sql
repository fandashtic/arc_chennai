
CREATE procedure spc_Branch
as
select BranchCode, BranchName, BranchMaster.Active, 
BankName
from BranchMaster, BankMaster
Where BranchMaster.BankCode = BankMaster.BankCode

