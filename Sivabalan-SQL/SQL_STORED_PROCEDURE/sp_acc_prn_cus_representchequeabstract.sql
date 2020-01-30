CREATE procedure sp_acc_prn_cus_representchequeabstract (@depositid int)  
as  
  
select   
"Deposit Date" = Deposits.DepositDate,  
"Account Name" = Bank.Account_Name,  
"Account Number" = Bank.Account_number,  
"Bank Name" = Bankmaster.BankName,  
"Branch Name" = BranchMaster.BranchName,  
"Value" = Deposits.value,  
"Depositor Name" = dbo.getaccountname(deposits.staffid)  
from deposits , Bank, Bankmaster, BranchMaster  
where deposits.Depositid  = @depositid  
and Deposits.accountid = Bank.BankID
and Bank.BankCode = BankMaster.BankCode  
and Bank.BranchCode = BranchMaster.BranchCode  
and Bankmaster.BankCode = BranchMaster.BankCode 
  
-- -- select * from branchmaster  
-- -- select * from bankmaster  
-- -- select * from deposits where Depositid  = 44  
-- -- select * from collections where Depositid = 44  
  
  
  



