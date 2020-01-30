CREATE procedure [dbo].[sp_acc_view_CollectionAbstract](@DocumentID int)
as
select FullDocID, DocumentDate,PaymentMode, ChequeNumber, ChequeDate, Value,
BankMaster.BankCode,BranchMaster.BranchCode, BankMaster.BankName, BranchMaster.BranchName, 
Status,Others,AccountName,Denomination 
from Collections
Inner Join AccountsMaster on Collections.Others=AccountsMaster.AccountID 
Left Outer Join BankMaster on Collections.BankCode = BankMaster.BankCode
Left Outer Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode
where Collections.DocumentID = @DocumentID 
--and Collections.Others=AccountsMaster.AccountID 
--and Collections.BankCode *= BankMaster.BankCode 
--and Collections.BranchCode *= BranchMaster.BranchCode
