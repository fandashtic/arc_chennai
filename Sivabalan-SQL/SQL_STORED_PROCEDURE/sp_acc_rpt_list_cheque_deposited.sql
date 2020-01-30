CREATE procedure sp_acc_rpt_list_cheque_deposited(@FromDate datetime,    
        @ToDate datetime)    
as    
Select Deposits.DepositID,"Deposit ID"=Deposits.FullDocID,  
"Deposit Date"= Deposits.DepositDate,    
"Account Number"= Bank.Account_Number,  
"Bank"=BankMaster.BankName,  
"Branch"=BranchMaster.BranchName,    
"Amount"=Deposits.Value,  
"Staff"=accountsmaster.accountname   
From Deposits
Inner Join Bank On Deposits.AccountID = Bank.BankID
Inner Join BankMaster On BankMaster.BankCode=Bank.BankCode
Inner Join BranchMaster On BranchMaster.BranchCode=Bank.BranchCode
Left Outer Join Accountsmaster  On Deposits.staffID = accountsmaster.accountid      
Where (dbo.stripdatefromtime(Deposits.Depositdate) between @FromDate and @Todate) and TransactionType=5 And IsNULL(Status,0) & 192  =0   
Order by Deposits.DepositID,Deposits.DepositDate    
