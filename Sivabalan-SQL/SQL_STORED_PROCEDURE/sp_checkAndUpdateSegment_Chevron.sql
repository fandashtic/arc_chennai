  
CREATE procedure sp_checkAndUpdateSegment_Chevron(@Segid int)                  
As                 
Begin                
Declare @RecParentID Int                  
Declare @origParentID Int                  
Declare @RecLevel Int                  
Declare @OrigLevel Int                
Declare @recDesc nvarchar(2000)                  
Declare @OrigDesc nvarchar(2000)          
Declare @recSegName nVarchar(400)    
Declare @OrigSegName nVarchar(400)    
Declare @Parent nVarchar(400)      
Declare @SegCode nVarchar(400)      
      
Create Table #tmpSegCode(SegCode nVarchar(255))              
    
Insert Into #tmpSegCode Select SegmentCode From ReceivedSegments Where SegmentID = @Segid   
                  
Select @recSegName=SegmentName,@RecLevel=Level,@recDesc=Description from                  
ReceivedSegments Where SegmentId=@Segid                  
                  
Select @OrigSegName=SegmentName,@OrigLevel=Level,@OrigDesc=Description from                  
CustomerSegment Where SegmentCode=                  
(Select SegmentCode From ReceivedSegments Where SegmentID = @Segid)                  
    
    
Select @RecParentID = Isnull(SegmentID,0) From CustomerSegment              
Where SegmentCode = (Select IsNull(ParentCode, N'') From ReceivedSegments                
Where SegmentID = @Segid)                  
                  
Select @OrigParentID = Parentid From CustomerSegment                   
Where SegmentCode = (Select SegmentCode From ReceivedSegments Where SegmentID = @Segid)                  
                  
IF (@recparentid <> @origparentid) or (@RecLevel <> @OrigLevel) or (@recDesc <>@OrigDesc)                  
Begin              
 Update CustomerSegment set SegmentName=@recSegName,Description=@recDesc,Level=@RecLevel,ParentID=@RecParentID,              
 ModifiedDate=GETDATE() Where SegmentCode=(Select SegmentCode From ReceivedSegments Where SegmentID = @Segid)                  
    Select 1               
End                
Else              
 Select 0             
       
Update ReceivedSegments Set Status=(Status |128)                                
Where SegmentID=@Segid         
--To Update The Status Of All the Parent Segments In The ReceivedSegments Table Corresponding to the Segment Updated above      
Select @Parent =ParentCode from ReceivedSegments Where SegmentID=@Segid  
While @Parent<>''--Inserts All The Parent Segments      
Begin      
	Select @SegCode=SegmentCode,@Parent=ParentCode From ReceivedSegments Where SegmentCode=@Parent    
	Insert Into #tmpSegCode(SegCode) Values(@SegCode)      
End      
    
UPdate ReceivedSegments Set Status=(Status|128) where SegmentCode In(Select SegCode From #tmpSegCode)           
     
End              
              
