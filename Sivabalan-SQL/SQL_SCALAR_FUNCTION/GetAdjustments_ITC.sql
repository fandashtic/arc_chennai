CREATE Function GetAdjustments_ITC (@CollectionID int, @InvNo int)
Returns nvarchar(4000)
As
Begin
Declare @AdjDocs nvarchar(4000), @TmpAdjDocs nvarchar(4000)  
Declare @DocID nvarchar(50)

Declare Adjustments Cursor Keyset For
Select OriginalID from CollectionDetail Where CollectionID = @CollectionID And
DocumentID <> @InvNo
Open Adjustments
Fetch From Adjustments into @DocID
While @@Fetch_Status = 0
Begin
	Set @AdjDocs = IsNull(@AdjDocs, N'') + N', ' +@DocID
	Fetch Next From Adjustments into @DocID
End
Set @AdjDocs = SubString(@AdjDocs, 3, Len(@AdjDocs) - 2)
Close Adjustments
Deallocate Adjustments

Select @TmpAdjDocs = IsNull(ar.Description,N'') From AdjustmentReference aref, AdjustmentReason ar Where aref.InvoiceID=@InvNo and aref.AdjustmentReasonID=ar.AdjReasonID

If @AdjDocs <> N'' And IsNull(@TmpAdjDocs,N'') <> N''
	Set @AdjDocs = @AdjDocs + ', ' + IsNull(@TmpAdjDocs,N'')	
Else If IsNull(@TmpAdjDocs,N'') <> N''
	Set @AdjDocs = IsNull(@TmpAdjDocs,N'')

Return @AdjDocs
End
