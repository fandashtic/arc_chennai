CREATE procedure spr_list_cheque_deposited(@FromDate datetime,
					   @ToDate datetime)
as
select Collections.DocumentID, "Drawee Bank" = BankMaster.BankName,
"Drawee Branch" = BranchMaster.BranchName,
"Collection ID" = Collections.FullDocID,
"Collection Date" = Collections.DocumentDate,  
"Cheque Number" = Collections.ChequeNumber,
"Cheque Date" = Collections.ChequeDate,
"CustomerID" = Collections.CustomerID,
"Customer" = Customer.Company_Name, 
"Bank" = (Select BM.BankName From BankMaster BM, Bank B
Where BM.BankCode = B.BankCode And
B.BankID = Collections.Deposit_To), "Amount" = Collections.Value
from Collections, Customer, BankMaster, BranchMaster
where Collections.CustomerID = Customer.CustomerID and
Collections.BankCode = BankMaster.BankCode And
Collections.BranchCode = BranchMaster.BranchCode And
Collections.BankCode = BranchMaster.BankCode And
Collections.DepositDate between @FromDate and @ToDate
