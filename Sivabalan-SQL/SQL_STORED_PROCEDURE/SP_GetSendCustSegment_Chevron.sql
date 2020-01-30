CREATE Procedure SP_GetSendCustSegment_Chevron(@Cusid nvarchar(4000))                                      
As                    
Begin                
Set DateFormat DMY                
Declare @SegID as int                
Declare @ParentID as int            
Declare @CustCnt as int              
Declare @counter as int            
Declare @cid as nvarchar(255)            
Create Table #tmp(segID INT)            
Create table #tmpCustID(CustID NVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)                  
Declare @Delimeter as Char(1)                                                              
Set @Delimeter=','               
Insert Into #tmpCustID Select * from dbo.sp_SplitIn2Rows(@Cusid,@Delimeter)            
Select [ID] = Identity(Int, 1, 1), CustID InTo #tmpCustID1 From #tmpCustID             
Select @CustCnt=count(*) from #tmpCustID            
Set @Counter =1            
While @CustCnt >= @Counter            
Begin            
  Select @cid=CustID From #tmpCustID1 where id=@counter            
  Select @SegID=SegmentID From Customer Where CustomerID=@cid              
  Select @ParentID=ParentID From CustomerSegment where SegmentID=@SegID              
  Insert Into #tmp(segID)values(@SegID)       
  IF @ParentID <> 0               
  Begin              
	  While @ParentID <> 0          
	  Begin              
	      Insert Into #tmp(segID)values(@ParentID)              
	      Select @ParentID=Isnull(ParentID,0) From CustomerSegment where SegmentID=@ParentID              
	  End              
  End              
Set @Counter=@counter+1            
End            
 Select         
 "SegmentCode"=SegmentCode,        
 "SegmentName"=SegmentName,                
 "Description"=Isnull(Description,N''),                
 "ParentCode"=ISNULL((Select SegmentCode From CustomerSegment Where SegmentID=CS.ParentID),N''),                
 "Level"=Level                
 From CustomerSegment CS                
 Where SegmentID in(Select distinct SegID From #tmp)               
Drop Table #tmp             
Drop table #tmpcustid            
drop table #tmpcustid1             
End                
        
