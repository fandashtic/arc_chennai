CREATE Procedure Sp_Get_RecSegmentDetails(@ForumCode nvarchar(6))                      
As                      
                
Select "SegStatus"=Case dbo.fn_CanSaveSegment(SegmentID) When N'Y' then 1                       
       When N'E' then 0                      
       end,                     
"SegmentID"=SegmentID,"SegmentCode"=SegmentCode,"SegmentName"=SegmentName,    
"ParentCode"=Isnull(ParentCode,N''),"Level"=Level           
From ReceivedSegments RC Where BranchForumCode=@ForumCode                      
And isnull(Status,0)=0 Order by LEVEL,SegStatus  

