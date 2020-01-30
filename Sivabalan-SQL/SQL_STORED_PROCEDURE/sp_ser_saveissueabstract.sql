CREATE Procedure  sp_ser_saveissueabstract (@Type int, @IssueDate datetime, 
	@JobCardID int, @UserName nvarchar(255), @DocRef nvarchar(255),@DocSerialType nvarchar(100))
as
Declare @DocumentID Int
begin tran
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 102
	select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 102
commit tran

Insert into 
[IssueAbstract] ([IssueType], [IssueDate], [DocumentID], [JobCardID], [UserName], [DocRef],[DocSerialType]) 
Values (@Type, @IssueDate, @DocumentID, @JobCardID, @UserName, @DocRef, @DocSerialType)

Select @@Identity, @DocumentID

