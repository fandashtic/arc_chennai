
Create Procedure sp_IsParentSegment(@SegmentID int)
As
	If Exists(Select Top 1 SegmentID From Customer Where SegmentID = @SegmentID)
		Begin
			Select 0
		End  
	Else
		Begin
			Select -1
		End


