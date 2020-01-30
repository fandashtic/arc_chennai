CREATE Procedure sp_acc_rpt_UnDeposited_Cheques (@FromDate Datetime,  
       @ToDate Datetime)  
As  
Select Collections.DocumentID,   
"CollectionID" = Collections.FullDocID,  
"Date" = Collections.DocumentDate,   
"Type"= case when Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,  
"Collection Type" = case when CustomerID is null then case when (IsNull(Others,0) <> 0) and (IsNull(ExpenseAccount,0) <> 0) then  
dbo.LookupDictionaryItem('Collection from Party for Expense',Default) else case when (IsNull(Others,0) = 0)  and (IsNull(ExpenseAccount,0) <> 0)  
then dbo.LookupDictionaryItem('Collection for Expense',Default) else dbo.LookupDictionaryItem('Collection from Party',Default) end end else ' ' end,  
"Party" = Case when IsNull(Collections.others,0) = 0 then (Select Company_Name From Customer where CustomerID=Collections.CustomerID)   
else (Select AccountName from AccountsMaster where AccountID= IsNull(Collections.Others,0)) end,  
"Expense Account" = (Select AccountName from AccountsMaster where AccountID = Isnull(Collections.ExpenseAccount,0)),  
--"CustomerID" = Collections.CustomerID,  
--"Customer" = Customer.Company_Name,   
"Cheque No" = Collections.ChequeNumber,  
"Cheque Date" = Collections.ChequeDate,  
"Drawee Bank" = BankMaster.BankName,  
"Drawee Branch" = BranchMaster.BranchName,  
"Amount" = Collections.Value  
From Collections, BankMaster, BranchMaster  
--Where Collections.CustomerID = Customer.CustomerID And  
Where dbo.stripdatefromtime(Collections.ChequeDate) Between @FromDate And @ToDate And  
IsNull(Collections.PaymentMode, 0) in (1,2) And  
IsNull(Collections.Status, 0) & 128 = 0 And  
(ISNULL(Deposit_To, 0) = 0 Or (IsNULL(Deposit_To,0) <> 0 And IsNULL(Collections.Status,0)=2)) And  
--IsNull(Deposit_To, '') = '' And  
Collections.BankCode = BankMaster.BankCode And  
Collections.BranchCode = BranchMaster.BranchCode And  
Collections.BankCode = BranchMaster.BankCode  
Order By Collections.ChequeDate  


