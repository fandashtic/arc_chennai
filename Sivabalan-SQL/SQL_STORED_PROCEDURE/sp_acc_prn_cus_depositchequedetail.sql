CREATE procedure sp_acc_prn_cus_depositchequedetail (@depositid int)  
as  
  
select   distinct
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
from collections, Bankmaster, BranchMaster  
where collections.depositid = @depositid
and BankMaster.BankCode = BranchMaster.BankCode
and Collections.BranchCode = BranchMaster.BranchCode  
and Collections.BankCode = BankMaster.BankCode 

