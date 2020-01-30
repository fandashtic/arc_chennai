CREATE Function fn_CanSaveSegment(@ID int)            
Returns nvarchar(1)            
As            
Begin            
	Declare @SegCode nvarchar(256)            
	Declare @CanSaveSeg nvarchar(1)            
	Declare @CountSeg int            
    Set @CanSaveSeg=N'E'            
    Select @SegCode=SegmentCode From ReceivedSegments Where SegmentId=@ID            
    Select @CountSeg=Count(*) from CustomerSegment Where SegmentCode=@SegCode          
	IF (@CountSeg =0)            
 		Set @CanSaveSeg=N'Y'            
    Return (Select @CanSaveSeg)            
End  

