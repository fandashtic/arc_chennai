CREATE procedure sp_acc_getbankaccountdetails(@accountid int)
as
Select BankName,BranchName,Account_Name
from Bank,BankMaster,BranchMaster
Where AccountID = @accountid
and Bank.BankCode = BankMaster.BankCode
and Bank.BranchCode = BranchMaster.BranchCode


