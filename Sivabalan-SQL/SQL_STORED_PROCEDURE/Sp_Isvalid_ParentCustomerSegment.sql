CREATE PROCEDURE Sp_Isvalid_ParentCustomerSegment(@SegmentId int)  
AS  
IF EXISTS (SELECT TOP 1 SegmentId FROM Customer WHERE SegmentId = @SegmentId)  
BEGIN  
 SELECT 0  
END  
ELSE  
BEGIN  
 SELECT -1  
END
