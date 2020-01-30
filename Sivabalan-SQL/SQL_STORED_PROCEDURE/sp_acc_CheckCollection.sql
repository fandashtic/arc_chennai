CREATE Procedure sp_acc_CheckCollection(@DocID as Int,@ViewCancelMode as Int = 0)
As
Declare @Count as Int
If @ViewCancelMode = 0 
Begin
	Select @Count=Count(CollectionID)
	from CollectionDetail, Collections 
	where 	CollectionDetail.DocumentID=@DocID and DocumentType = 3 and 
	Collections.DocumentID = CollectionDetail.CollectionID and
	IsNull(Collections.Status,0) & 64 = 0

	If IsNull(@Count,0)=0
	Begin
		Select Count(DocumentID) from collections Where DocumentID=@DocID and IsNull(ExpenseAccount,0)=0 and 
		Value <> Balance and 
		(Select Count(CollectionID) From CollectionDetail Where CollectionID = Collections.DocumentID) = 0
	End
	Else
	Begin
		Select @Count
	End
End
Else
Begin
	Select DocumentId,Isnull(status,0) as 'Status',isnull(Remarks,N'') as 'CancellationsRemarks',
	Value,Balance
	From Collections 
	where DocumentID=@DocID
End




