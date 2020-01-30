CREATE procedure sp_acc_cashdepositinfo(@depositid int)
as
select DepositDate,Account_Name,Account_Number,BankName,BranchName,
'',Denominations,dbo.getaccountname(isnull(StaffID,0)),Value
from Deposits,Bank,BankMaster,BranchMaster
where DepositID =@depositid and isnull(TransactionType,0) =1 
and Deposits.AccountID = Bank.AccountID
and Bank.BankCode = BankMaster.BankCode and Bank.BranchCode =BranchMaster.BranchCode 




