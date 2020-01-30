Create Procedure sp_GetSendCustSegment(@SegmentID nvarchar(4000))                                            
As                          
Begin                      
Set DateFormat DMY                      
Declare @SegID as int                      
Declare @ParentID as int                  
Declare @SegCnt as int                    
Declare @counter as int                  
Declare @cid as nvarchar(255)                  
Create Table #tmp(segID INT)                  
Create table #tmpSegmentID(SegmentID NVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)                        
Declare @Delimeter as Char(1)                                                                    
Set @Delimeter=','                     
Insert Into #tmpSegmentID Select * from dbo.sp_SplitIn2Rows(@segmentID,@Delimeter)                  
Select [ID] = Identity(Int, 1, 1), SegmentID InTo #tmpSegmentID1 From #tmpSegmentID                   
Select @SegCnt=count(*) from #tmpSegmentID1                   
Set @Counter =1                  
While @SegCnt >= @Counter                  
Begin                  
  Select @SegID=SegmentID From #tmpSegmentID1 Where Id=@Counter                
  Select @ParentID=ParentID From CustomerSegment where SegmentID=@SegID                    
  Insert Into #tmp(segID)values(@SegID)                    
  IF @ParentID <> 0                     
  Begin                    
	  While @ParentID <> 0                    
	  Begin        
    	  --Inserts All The ParentSegments                
	     Insert Into #tmp(segID)values(@ParentID)                    
	     Select @ParentID=ParentID From CustomerSegment where SegmentID=@ParentID                    
	  End                    
  End                    
 Set @Counter=@counter+1                  
End            
 Select       
 "SegmentCode" = SegmentCode,      
 "SegmentName"=SegmentName,                      
 "Description"=Isnull(Description,N''),                      
 "ParentCode"=Isnull((Select SegmentCode From CustomerSegment Where SegmentID=CS.ParentID),N''),      
 "Level"=Level            
 From CustomerSegment CS                      
 Where SegmentID in(Select distinct SegID From #tmp)                     
Drop Table #tmp                   
Drop table #tmpSegmentID                  
drop table #tmpSegmentID1                 
End                      

