CREATE Procedure sp_update_SegmentName(@SegmentCode Varchar(255),          
         @NewName Varchar(510))          
As          
Update CustomerSegment  Set SegmentName  = @NewName        
Where SegmentCode = @SegmentCode    
  

