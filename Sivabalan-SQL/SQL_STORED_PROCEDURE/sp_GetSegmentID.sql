
Create Procedure sp_GetSegmentID(	@SegmentCode as nvarchar(255))
As
	Select SegmentID From CustomerSegment Where SegmentCode = @SegmentCode

