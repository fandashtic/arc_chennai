CREATE procedure [dbo].[sp_acc_list_cheque_collections](@FromDate datetime,  
          @ToDate datetime)  
as  
select DocumentID, "Collection ID" =  Collections.FullDocID,  
"Date" = Collections.DocumentDate,
"Type"= case when Others is not null then 'Others' else 'Customer' end,  	 
"Account Name" = Case when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,     
"Payment Mode" = case Collections.PaymentMode   
When 1 then  
'Cheque'  
When 2 then  
'DD'  
End,  
"Cheque Number" = Collections.ChequeNumber, "Cheque Date" = Collections.ChequeDate,
"Bank" = BankMaster.BankName, 
'Deposit ID'= Deposits.FullDocID, 
"Deposited Date" = Collections.DepositDate,  
"Account Number" = Bank.Account_Number,
"Bank"= BankMaster.BankName,
"Branch"= BranchMaster.BranchName,
"Amount" = Collections.Value  
from 
Collections
Left Join Bank on Collections.Deposit_To = Bank.BankID
Left Join Deposits on Collections.DepositID = Deposits.DepositID
Inner Join BankMaster on Bank.BankCode = BankMaster.BankCode
Inner Join BranchMaster on Bank.BranchCode = BankMaster.BankCode

--Collections,BankMaster,Bank,Deposits,BranchMaster  
where dbo.stripdatefromtime(Collections.DocumentDate) between @FromDate and @ToDate and   
Collections.PaymentMode in (1, 2) and (IsNull(Collections.Status, 0) & 64) = 0 
--and Collections.Deposit_To *= Bank.BankID  and
--Collections.DepositID *= Deposits.DepositID and
--Bank.BankCode = BankMaster.BankCode  and
--Bank.BranchCode = BankMaster.BankCode
