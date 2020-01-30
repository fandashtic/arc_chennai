CREATE procedure [dbo].[spr_get_collectiondetails](@paymentmode integer,
					     @fromdate datetime,
					     @todate datetime
)
as
select DocumentID, "Collection ID" = FullDocID, "Date" = DocumentDate,
"Customer Name" = Customer.Company_Name, 
"Value" = Collections.Value, "Current Balance" = Collections.Balance,
"Cheque Number" = Collections.ChequeNumber, 
"Cheque Date" = Collections.ChequeDate,
"Bank" = BankMaster.BankName,
"Branch" = BranchMaster.BranchName
from Collections, Customer,  BankMaster, BranchMaster
where

Customer.CustomerID = Collections.CustomerID and
Collections.DocumentDate between @fromdate and @todate and
Collections.paymentmode=@paymentmode and
Collections.BankCode *= BankMaster.Bankcode and
Collections.BankCode *= BranchMaster.Branchcode and
Collections.Bankcode *= BranchMaster.Bankcode
order by collections.FullDocID
