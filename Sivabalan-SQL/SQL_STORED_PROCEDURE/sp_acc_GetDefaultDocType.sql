CREATE procedure sp_acc_GetDefaultDocType(@Username nVarchar(100),@TranNumber int)  
As  
Select Top 1 DocumentType from TransactionDocNumber,DocumentUsers  
Where DocumentUsers.UserName = @UserName  
And TransactionDocNumber.SerialNo = DocumentUsers.SerialNo  
And TransactionDocNumber.TransactionType = @TranNumber  
And TransactionDocNumber.Active = 1 
