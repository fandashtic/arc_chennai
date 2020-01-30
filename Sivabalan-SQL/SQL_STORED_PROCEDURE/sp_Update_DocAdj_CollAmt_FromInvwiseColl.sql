
Create Procedure sp_Update_DocAdj_CollAmt_FromInvwiseColl(@InvCollID int)
As
Begin
	Declare @DocID Int

	Declare TmpInvCursor Cursor For
	Select DocumentID From InvoicewiseCollectionDetail Where CollectionID = @InvCollID

	Open TmpInvCursor

	Fetch Next From TmpInvCursor Into @DocID

	While @@Fetch_Status = 0 
	Begin
		Exec sp_Update_DocAdj_CollAmt @DocID
		Fetch Next From TmpInvCursor Into @DocID
	End
	Close TmpInvCursor
	Deallocate TmpInvCursor
End
