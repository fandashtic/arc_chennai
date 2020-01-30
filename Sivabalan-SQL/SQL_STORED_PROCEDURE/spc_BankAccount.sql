CREATE procedure spc_BankAccount
as
select Bank.BankID, Bank.Active, Bank.Account_Name, Bank.Account_Number, 
BankMaster.BankName, BranchMaster.BranchName
From Bank, BankMaster, BranchMaster
Where Bank.BankCode = BankMaster.BankCode And
Bank.BranchCode = BranchMaster.BranchCode And
BankMaster.BankCode = BranchMaster.BankCode
