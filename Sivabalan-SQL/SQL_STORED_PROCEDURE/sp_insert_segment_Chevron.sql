CREATE Procedure sp_insert_segment_Chevron         
(@segCode  nvarchar(255))      
as                
Begin                
set dateformat dmy     
Declare @SegName nVarchar(255)  
Declare @Description  nvarchar(255)      
Declare @parentSegCode  nvarchar(255)      
Declare @createDt DateTime      
Declare @modifiedDt DateTime      
Declare @level Int       
Declare @ParentId As Int          
Declare @cnt as Int      
      
Select @SegName=SegmentName ,@Description=Isnull(Description,N''),@parentSegCode=ParentCode,@Level=Level,@CreateDt=CreationDate,@ModifiedDt=ModifiedDate      
From ReceivedSegments where SegmentCode=@SegCode      
      
set @ParentId = 0               
Select @cnt=Count(*) FROM CustomerSegment Where SegmentCode=@SegCode      
if @cnt=0       
Begin      
 --If SegmentName Exist Then Skip Insertion  
    if (Select Count(*) From CustomerSegment Where SegmentName=@segName) > 0 GoTo Skip1  
    if @parentSegCode <> ''     
    Begin       
     Select @ParentId=SegmentId From CustomerSegment where SegmentCode=@parentSegCode          
  --When ParentID DoesNot Exist For A Particular Segment Skip Insertion Of That segment  
     if @ParentId = 0   GoTo Skip1        
 End  
   Insert Into CustomerSegment(SegmentCode,SegmentName,Description,ParentID,Level,CreationDate,ModifiedDate)                
   Values                
   (@segCode,@segName,@Description,@ParentId,@level,@createDt,@modifiedDt)                
   Update ReceivedSegments Set Status=(Status|128) Where SegmentCode=@segCode      
End      
skip1:  
 Select @@Identity               
End               
    
