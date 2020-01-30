CREATE procedure sp_get_DefaultDocType(@Username nvarchar(100),@TranNumber int)
As
Select Top 1 DocumentType from TransactionDocNumber,DocumentUsers
Where DocumentUsers.UserName=@UserName
And TransactionDocNumber.SerialNo=DocumentUsers.SerialNo
And TransactionDocNumber.TransactionType=@TranNumber
And TransactionDocNumber.Active=1

