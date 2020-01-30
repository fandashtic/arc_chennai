CREATE procedure sp_acc_prn_cus_representchequedetail (@depositid int)  
as  
  
select Distinct
"Party Name" = 
case 
	when Collections.CustomerID is Not NULL then 
		(Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
	else             
    (
		case when ISNULL(Others,0) <> 0 then dbo.getaccountname(Others) 
		else dbo.getaccountname(ExpenseAccount) 
		end
	) 
end,
"Bank Name" = Bankmaster.BankName,  
"Branch Name" = BranchMaster.BranchName,  
"Value" = collections.value,  
"Cheque Number" = collections.ChequeNumber  
from collections, Bank, Bankmaster, BranchMaster  
where collections.depositid = @depositid  
and BankMaster.BankCode = BranchMaster.BankCode
and Collections.BranchCode = BranchMaster.BranchCode  
and collections.Bankcode = Bankmaster.Bankcode    
  
  
-- -- select * from branchmaster  
-- -- select * from bankmaster  
-- -- select * from deposits where Depositid  = 44  
-- -- select * from collections where Depositid = 44  
  
  
  




