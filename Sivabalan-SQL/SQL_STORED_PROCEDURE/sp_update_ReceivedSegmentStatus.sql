CREATE procedure sp_update_ReceivedSegmentStatus(@SegCode nVarchar(255))  
As  
Begin  
Declare @ParentCode as Nvarchar(255)  
  
Update ReceivedSegments Set Status=(status|128) where SegmentCode=@segCode  
Select @ParentCode=ParentCode From ReceivedSegments Where SegmentCode=@segCode  
  
While @ParentCode <> ''  
Begin  
	--Updates the status of all the parent segments
  Update ReceivedSegments Set Status=(status|128) where SegmentCode=@ParentCode  
  Select @ParentCode=ParentCode From ReceivedSegments Where SegmentCode=@ParentCode  
End  
End 

