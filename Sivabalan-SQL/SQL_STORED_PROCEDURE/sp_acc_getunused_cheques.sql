CREATE procedure sp_acc_getunused_cheques (@CustomerID nvarchar(50))      
as      
/*       
status 1 = Active but Not Used      
status 0 = De-Active but Used      
*/      
select CC.ChequeNumber,BM.BankName,BRM.BranchName,CC.Active as Status       
from customercheques CC,BankMaster as BM,BranchMaster as BRM      
where --CC.active = 1   and    
Ltrim(rtrim(cast(CC.chequenumber as nvarchar(50)))) + N'€' +
Ltrim(rtrim(cast(CC.BankCode as nvarchar(50)))) + N'€' +
Ltrim(rtrim(cast(CC.BranchCode as nvarchar(50))))
not in        
(
select Ltrim(rtrim(cast(b.chequenumber as nvarchar(50)))) + N'€' +
Ltrim(rtrim(cast(b.BankCode as nvarchar(50)))) + N'€' +
Ltrim(rtrim(cast(b.BranchCode as nvarchar(50))))
from customercheques a, collections b      
where a.bankcode = b.bankcode and a.branchcode = b.branchcode and isnull(b.status,0) in (0,1,2))       
and CC.customerid = @CustomerID       
and CC.BankCode = BM.BankCode      
and cc.BranchCode = BRM.BranchCode      
and BM.BankCode = BRM.BankCode      
union      
select CC.ChequeNumber,BM.BankName,BRM.BranchName,'0' as Status       
from customercheques CC,BankMaster as BM,BranchMaster as BRM      
where CC.active = 0      
and Ltrim(rtrim(cast(CC.chequenumber as nvarchar(50)))) + N'€' +
Ltrim(rtrim(cast(CC.BankCode as nvarchar(50)))) + N'€' +
Ltrim(rtrim(cast(CC.BranchCode as nvarchar(50))))
in        
(
select Ltrim(rtrim(cast(b.chequenumber as nvarchar(50)))) + N'€' +
Ltrim(rtrim(cast(b.BankCode as nvarchar(50)))) + N'€' +
Ltrim(rtrim(cast(b.BranchCode as nvarchar(50))))
from customercheques a, collections b      
where a.bankcode = b.bankcode and a.branchcode = b.branchcode and isnull(b.status,0) in (0,1,2))       
and CC.customerid = @CustomerID       
and CC.BankCode = BM.BankCode      
and cc.BranchCode = BRM.BranchCode      
and BM.BankCode = BRM.BankCode      
Order by BM.BankName,BRM.BranchName,CC.ChequeNumber      
      
    
  





