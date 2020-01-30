
CREATE Procedure sp_Check_UpdateSegment(
	@SegmentCode nvarchar(255),
	@SegmentName nvarchar(255),
	@Description nvarchar(255),
	@ParentID int)
As
	Declare @Count int


	--If both SegmentCode and SegmentName already exists
	If ((Select  Count(*) From CustomerSegment Where SegmentCode = @SegmentCode And SegmentName = @SegmentName) > 0 )
	Begin
		Update CustomerSegment Set  Description = @Description, ParentId = @ParentID 
			Where SegmentCode = @SegmentCode And SegmentName = @SegmentName
		Select 0
	End
	--If SegmentCode already exists 
	Else If ((Select  Count(*) From CustomerSegment Where SegmentCode = @SegmentCode) > 0 )
	Begin
		Update CustomerSegment Set SegmentName = @SegmentName, Description = @Description, ParentId = @ParentID 
			Where SegmentCode = @SegmentCode 
		Select 0
	End
	--If SegmentName already exists then returns error msg
	Else
		Select 1




