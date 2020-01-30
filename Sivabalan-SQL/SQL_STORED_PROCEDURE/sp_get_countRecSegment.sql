
CREATE PROCEDURE sp_get_countRecSegment  
As  
SELECT count(Distinct SegmentID) FROM ReceivedSegments WHERE Isnull(Status,0)=0    
  
