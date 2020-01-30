Create Procedure Sp_List_Segments(@FromDate DateTime,@ToDate DateTime)      
As      
Begin      
Declare @Cur_Seg Cursor      
Declare @SegmentId As Int      
Create Table #tmpSegment(SegmentID Int,SegmentName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
      
      
Set @Cur_Seg = Cursor For Select SegmentID From CustomerSegment  Where Active=1 And (CreationDate Between @FromDate And @ToDate      
		         Or ModifiedDate Between @FromDate And @ToDate)      
Open @Cur_Seg          
Fetch Next From @Cur_Seg Into @SegmentID      
While @@Fetch_status=0          
Begin          
	Insert Into #tmpSegment Select * From dbo.Fn_GetLeafLevelSegment(@SegmentID)          
	Fetch Next From @Cur_Seg Into @SegmentID      
End          
close @Cur_Seg            
      
      
Select  
"SegmentID"=SegmentID,   
"SegmentCode"=SegmentCode,      
"SegmentName"=SegmentName,      
"Description"=Isnull(Description,N''),  
"ParentCode"=(Select isnull(SegmentCode,N'') From CustomerSegment Where SegmentID=CS.ParentID)  
from CustomerSegment CS Where      
SegmentId In(Select Distinct SegmentID From #tmpSegment)      
      
Drop Table #tmpSegment      
End      

