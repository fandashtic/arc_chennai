CREATE Function GetSalesReturnReference (@InvoiceID Int)
Returns nvarchar(255)
As
Begin
Declare @Reference As nvarchar(255)
Declare @CollectionID As Int
Declare @TempRef As nvarchar(255)

Declare AdjCollection Cursor Keyset For
Select CollectionID From Collections, CollectionDetail 
Where Collections.DocumentID = CollectionDetail.CollectionID And
IsNull(Collections.Status, 0) & 128 = 0 And
CollectionDetail.DocumentType = 1 And
CollectionDetail.DocumentID = @InvoiceID

Open AdjCollection

Fetch From AdjCollection Into @CollectionID

Set @Reference  = N''
While @@Fetch_Status = 0
Begin
	Declare InvoiceRef Cursor KeySet For
	Select OriginalID From CollectionDetail 
	Where CollectionID = @CollectionID And
	DocumentType = 4

	Open InvoiceRef

	Fetch From InvoiceRef Into @TempRef
	While @@Fetch_Status = 0
	Begin
		Set @Reference = @Reference + N', ' + @TempRef
		Fetch Next From InvoiceRef Into @TempRef
	End
	Close InvoiceRef
	DeAllocate InvoiceRef
	Fetch Next From AdjCollection Into @CollectionID
End
If Len(@Reference) > 0 
	Set @Reference  = SubString(@Reference, 3, Len(@Reference) - 2)
Close AdjCollection
DeAllocate AdjCollection
Return @Reference
End
