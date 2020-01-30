CREATE procedure [dbo].[sp_acc_view_FACollectionAbstract](@CollectionID int)      
as      
select FullDocID, DocumentDate,PaymentMode, ChequeNumber, ChequeDate, Value, Balance,       
BankMaster.BankCode, BranchMaster.BranchCode, BankMaster.BankName, BranchMaster.BranchName,       
Others,ExpenseAccount,Denomination,Remarks, Status, DocReference, RefDocID,DocSerialType,Narration      
from Collections
Left Outer Join BankMaster on Collections.BankCode = BankMaster.BankCode
Left Outer Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode
where Collections.DocumentID = @CollectionID 
--and Collections.BankCode *= BankMaster.BankCode 
--and Collections.BranchCode *= BranchMaster.BranchCode 
