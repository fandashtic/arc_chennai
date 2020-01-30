CREATE Procedure spr_UnDeposited_Cheques (@FromDate Datetime,
					  @ToDate Datetime)
As
Select Collections.DocumentID, 
"CollectionID" = Collections.FullDocID,
"Date" = Collections.DocumentDate, 
"CustomerID" = Collections.CustomerID,
"Customer" = Customer.Company_Name, 
"Cheque No" = Collections.ChequeNumber,
"Cheque Date" = Collections.ChequeDate,
"Drawee Bank" = BankMaster.BankName,
"Drawee Branch" = BranchMaster.BranchName,
"Amount" = Collections.Value
From Collections, Customer, BankMaster, BranchMaster
Where Collections.CustomerID = Customer.CustomerID And
Collections.ChequeDate Between @FromDate And @ToDate And
IsNull(Collections.PaymentMode, 0) in (1,2) And
IsNull(Collections.Status, 0) & 128 = 0 And
IsNull(Deposit_To, N'') = N'' And
Collections.BankCode = BankMaster.BankCode And
Collections.BranchCode = BranchMaster.BranchCode And
Collections.BankCode = BranchMaster.BankCode
Order By Collections.ChequeDate
