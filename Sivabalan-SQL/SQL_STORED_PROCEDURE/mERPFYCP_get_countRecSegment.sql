CREATE PROCEDURE mERPFYCP_get_countRecSegment   ( @yearenddate datetime )
As  
SELECT count(Distinct SegmentID) FROM ReceivedSegments WHERE Isnull(Status,0)=0 and CreationDate <= @yearenddate  
