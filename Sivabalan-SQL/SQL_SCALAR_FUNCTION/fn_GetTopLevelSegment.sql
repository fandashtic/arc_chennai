
Create Function fn_GetTopLevelSegment(@SegmentID int)
Returns nvarchar(100)
As
Begin
	Declare @ParentID int
	Declare @SegDesc nvarchar(100)
	
	Select @ParentID = ParentID, @SegDesc = SegmentName From CustomerSegment Where SegmentID = @SegmentID
	While @ParentID <> 0
	Begin
		Select @SegDesc = SegmentName, @ParentID = ParentID From CustomerSegment
			Where SegmentId = @ParentID		
	End
	Return @SegDesc
End


