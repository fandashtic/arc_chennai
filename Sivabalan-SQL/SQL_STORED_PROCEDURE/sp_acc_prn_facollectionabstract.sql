CREATE procedure [dbo].[sp_acc_prn_facollectionabstract](@CollectionID int)
as
select FullDocID, DocumentDate,PaymentMode, ChequeNumber, ChequeDate, Value, Balance, 
BankMaster.BankCode, BranchMaster.BranchCode, BankMaster.BankName, BranchMaster.BranchName, 
Others,ExpenseAccount,Denomination,Remarks, Status
from Collections
Left Join BankMaster on Collections.BankCode = BankMaster.BankCode
Left Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode
--Collections, BankMaster, BranchMaster 
where Collections.DocumentID = @CollectionID 
--and Collections.BankCode *= BankMaster.BankCode and
--Collections.BranchCode *= BranchMaster.BranchCode
