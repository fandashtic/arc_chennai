
CREATE Procedure sp_CanChangeParentSegment(@SegmentID int)
As
	If Exists(Select Top 1 SegmentID From CustomerSegment Where ParentID = @SegmentID)
		Begin
			Select 0
		End
	Else
		Begin
			Exec sp_IsParentSegment @SegmentID			
		End
