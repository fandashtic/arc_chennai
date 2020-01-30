Create Procedure sp_CheckValidSegment(@SegName nVarchar(255))  
As  
Begin  
Declare @SegmentID Int  
Select @SegmentID=SegmentID From CustomerSegment Where SegmentName=@SegName  
if @SegmentID <> 0  
Begin  
	if (Select count(*) from CustomerSegment where ParentID=@SegmentID) > 0   
		Select -1
    else  
  		Select @SegmentID  
End  
Else  
	Select 0  
End  

