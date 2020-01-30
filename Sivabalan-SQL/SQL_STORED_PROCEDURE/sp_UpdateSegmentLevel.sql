
CREATE Procedure sp_UpdateSegmentLevel(@SegmentID int)    
As    
	 Declare @Parent int    
	 Declare @Level int    
	 Declare @OriginalID int    
    
	 Set @Level = 1    
	 Set @OriginalID = @SegmentID    
	 OneLevelUp:    
	 Select @Parent = IsNull(ParentID,0) From CustomerSegment Where SegmentID = @SegmentID    
	  If @Parent <> 0    
		  Begin    
		   	Set @Level = @Level + 1    
	      	Set @SegmentID = @Parent    
			Goto OneLevelUp    
		  End    
 Update CustomerSegment Set Level = @Level Where SegmentID = @OriginalID
