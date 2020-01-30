CREATE procedure sp_acc_rpt_FAlist_cheque_deposited(@FromDate datetime,
					   @ToDate datetime)
as
select Collections.DocumentID, "Drawee Bank" = BankMaster.BankName,
"Drawee Branch" = BranchMaster.BranchName,
"Collection ID" = Collections.FullDocID,
"Collection Date" = Collections.DocumentDate,  
"Cheque Number" = Collections.ChequeNumber,
"Cheque Date" = Collections.ChequeDate,
"Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,  	 
"Account Name" = Case when others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,     
"Bank" = (Select BM.BankName From BankMaster BM, Bank B
Where BM.BankCode = B.BankCode And
B.BankID = Collections.Deposit_To), "Amount" = Collections.Value
from Collections, BankMaster, BranchMaster
where Collections.BankCode = BankMaster.BankCode And
Collections.BranchCode = BranchMaster.BranchCode And
Collections.BankCode = BranchMaster.BankCode And
Collections.DepositDate between @FromDate and @ToDate And
(ISNULL(Deposit_To, 0) <> 0 And 
IsNULL(Collections.Status,0)=1)



