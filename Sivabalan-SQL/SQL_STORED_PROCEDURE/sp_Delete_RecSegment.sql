CREATE Procedure sp_Delete_RecSegment(@ID int)      
As      
      
 Update ReceivedSegments Set Status=(Status |192)      
 Where SegmentID=@ID      

