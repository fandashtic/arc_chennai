CREATE procedure [dbo].[spc_collections] (@Start_Date datetime, @End_Date datetime)
as
select DocumentID, DocumentDate, ChequeDate, DepositDate, RealisationDate, Value, 
Balance, PaymentMode, ChequeNumber, ChequeDetails, Customer.AlternateCode, FullDocID, 
Status, Bank.BankID, Salesman.Salesman_Name, BankMaster.BankName, 
BranchMaster.BranchName, ClearingAmount, Realised, BankCharges, Beat.Description
From Collections, Bank, Salesman, Customer, BankMaster, BranchMaster, Beat
Where DocumentDate Between @Start_Date And @End_Date And
Deposit_To *= Bank.BankID And
Collections.SalesmanID *= Salesman.SalesmanID And
Collections.CustomerID = Customer.CustomerID And
Collections.BankCode *= BankMaster.BankCode And
Collections.BranchCode *= BranchMaster.BranchCode And
Collections.BeatID *= Beat.BeatID
