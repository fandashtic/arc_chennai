CREATE Function sp_ser_GetAdjustments (@CollectionID int, @InvNo int)
Returns varchar(255)
As
Begin
Declare @AdjDocs varchar(255)
Declare @DocID varchar(50)

Declare Adjustments Cursor Keyset For
Select OriginalID from CollectionDetail Where CollectionID = @CollectionID And
DocumentID <> @InvNo
Open Adjustments
Fetch From Adjustments into @DocID
While @@Fetch_Status = 0
Begin
	Set @AdjDocs = IsNull(@AdjDocs, '') + ', ' +@DocID
	Fetch Next From Adjustments into @DocID
End
Set @AdjDocs = SubString(@AdjDocs, 3, Len(@AdjDocs) - 2)
Close Adjustments
Deallocate Adjustments
Return @AdjDocs
End

