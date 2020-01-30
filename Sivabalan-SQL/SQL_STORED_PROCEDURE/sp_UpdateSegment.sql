
CREATE Procedure sp_UpdateSegment(@SegmentID Int,
	@Description nVarchar(255),
	@ParentID Int,
	@Active Int)
As
	Declare @Status Int
	Declare @Prev Int

	Select @Prev = Active From CustomerSegment   Where SegmentID = @SegmentID  
	Update CustomerSegment  Set [Description] = @Description,      
			     ParentID = @ParentID,      
			     Active = @Active,  
			     ModifiedDate = GetDate()  
			     Where SegmentID = @SegmentID   
	If @Active = 0
		Begin 
			Exec Spr_GetsegmentID_ActiveDeactive @segmentID, @Status output  
			IF @Status = 0 Update CustomerSegmentation   Set Active = @Prev Where segmentID = @segmentID  
		End
