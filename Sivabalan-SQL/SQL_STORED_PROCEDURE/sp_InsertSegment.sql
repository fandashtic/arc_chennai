CREATE Procedure sp_InsertSegment(@SegmentID nvarchar(4000))        
As      
Begin      
Declare @SegCode nVarchar(255)      
Declare @Level Int      
Declare @ParentCode nVarchar(255)      
Declare @cur_seg  cursor      
Declare @Sname  nVarchar(255)      
Create Table #tmpSegName(SegCode nVarchar(255),Level Int)      
  
  
Select @SegCode=SegmentCode,@Level=Level From ReceivedSegments Where SegmentID=@SegmentID      
Insert Into #tmpSegName(SegCode,Level) Values(@SegCode,@Level)      
Select @ParentCode=ParentCode From ReceivedSegments Where SegmentID=@SegmentID      
  
    
--Fetches All The ParentSegment For The Given Particular Segment    
While @ParentCode<>''      
Begin      
  Select @SegCode=SegmentCode,@Level=Level,@ParentCode=ParentCode From ReceivedSegments Where SegmentCode=@ParentCode   
  Insert Into #tmpSegName(SegCode,Level) Values(@SegCode,@Level)      
End     
  
--Inserts All the Segments from lower level to higher level     
Set @cur_seg=cursor for Select SegCode From #tmpSegName order by level      
open @cur_seg      
Fetch Next From @cur_seg into @SegCode      
While @@fetch_status=0      
Begin      
	exec sp_insert_segment_Chevron @SegCode     
	Update Receivedsegments Set Status=(Status|128) Where SegmentCode=@SegCode     
	Fetch Next From @cur_seg into @SegCode    
End      
close @cur_seg      
Deallocate @Cur_Seg      
Drop Table #tmpSegName    

End      
    
