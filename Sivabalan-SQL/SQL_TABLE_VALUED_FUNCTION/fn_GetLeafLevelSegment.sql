

CREATE Function fn_GetLeafLevelSegment( @Node Int)           
Returns @LeafNodes Table(SegmentId int, SegmentName nvarchar(255))          
As          
Begin          
      
	Declare @LOOP int           
	Declare @Temp_Tbl Table(SegId int, SegName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
	Declare @SegmentName nvarchar(255)    

	Select @SegmentName =  SegmentName From CustomerSegment Where SegmentID = @Node    
	Set @Loop = 1         
	
	Insert Into @Temp_Tbl Values (@Node, @SegmentName)       

	If Exists(Select SegmentId From CustomerSegment Where ParentId= @Node and Active = 1)      
	Begin      
		While (@Loop = 1)          
		Begin           
			Insert Into @Temp_Tbl      
			Select SegmentId, SegmentName From CustomerSegment A           
			Where ParentId in (Select SegId From @Temp_Tbl) and           
			SegmentId not in (Select SegID From @Temp_Tbl) and  
			Active = 1           
			--and isnull((Select Count(*) From ItemCategories Where ParentId = A.CategoryId),0) > 0          
			
			If @@ROWCOUNT = 0 Set @Loop = 0          
		End          
		Insert Into @LeafNodes          
		Select SegmentID,SegmentName From CustomerSegment A Where ParentID in (Select SegId From @Temp_Tbl) and           
		IsNull((Select Count(*) From CustomerSegment Where ParentId = A.SegmentId And Active = 1),0) = 0 And Active = 1         
	End        
	Else      
		Insert Into @LeafNodes Select SegId,SegName From @Temp_Tbl       
	Return      
End          




