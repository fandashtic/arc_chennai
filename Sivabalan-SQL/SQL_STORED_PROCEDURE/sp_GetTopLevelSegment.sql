
CREATE Procedure sp_GetTopLevelSegment(@SegmentID int)
As
	Declare @SegName nvarchar(255)
	
	Select @SegName = dbo.fn_GetTopLevelSegment(@SegmentID)

	Select SegmentID, SegmentName  
		From CustomerSegment Where SegmentName = @SegName
	



