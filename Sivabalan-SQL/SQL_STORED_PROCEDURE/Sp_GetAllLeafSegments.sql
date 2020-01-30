
Create Procedure Sp_GetAllLeafSegments  
As  
Begin  
Select SegmentID,SegmentName From customerSegment where SegmentID   
Not In(Select Distinct ParentID From CustomerSegment)  
End

