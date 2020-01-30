
CREATE procedure sp_get_Rec_Segment  
As    
Select BranchForumCode,"From Branch"=BranchForumCode,    
"No.of.Segments Received"=Count(SegmentID)    
From ReceivedSegments Where IsNull(Status,0)=0  
Group by BranchForumCode    
  
