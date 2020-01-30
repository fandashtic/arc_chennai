CREATE procedure sp_acc_prn_cus_contraentryabstract(@depositid int)
as
select 
"Date" = DepositDate,
"Account Name" = Account_Name,
"Account Number" = Account_Number,
"Bank" = BankName,
"Branch" = BranchName,
"Amount Deposited" = Value,
"Depositor Name" = dbo.getaccountname(isnull(StaffID,0)),
"Narration" = Narration
from Deposits,Bank,BankMaster,BranchMaster
where DepositID =@depositid and isnull(TransactionType,0) =1 
and Deposits.AccountID = Bank.AccountID
and Bank.BankCode = BankMaster.BankCode and Bank.BranchCode =BranchMaster.BranchCode 

-- -- select DepositDate,Account_Name,Account_Number,BankName,BranchName,
-- -- '',Denominations,dbo.getaccountname(isnull(StaffID,0)),Value
-- -- from Deposits,Bank,BankMaster,BranchMaster
-- -- where DepositID =@depositid and isnull(TransactionType,0) =1 
-- -- and Deposits.AccountID = Bank.AccountID
-- -- and Bank.BankCode = BankMaster.BankCode and Bank.BranchCode =BranchMaster.BranchCode 






