CREATE Procedure sp_save_TransactionDocNumber
(@TransactionType int,@DocumentType nvarchar(100),@DocumentNumber nvarchar(100),@Active int)
As

Insert Into TransactionDocNumber(TransactionType,DocumentType,DocumentNumber,Active,Creationdate)
Values(@TransactionType,@DocumentType,@DocumentNumber,@Active,getdate())

Select @@IDENTITY

