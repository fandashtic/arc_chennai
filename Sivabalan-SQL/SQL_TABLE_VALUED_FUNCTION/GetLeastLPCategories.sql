create Function GetLeastLPCategories(@Category nvarchar(2550),@level int)  
Returns @CatID Table (CatID Int)  
As  
Begin  
  
	Declare @Continue int    
	Declare @CategoryID int    
	Declare @Delimeter as Char(1)      
	Declare @tmp1 Table (CategoryID Int, Status Int)  

	Set @Continue = 1    
	Set @Delimeter = Char(44)      
  
	if (Select isnull([Level],0) From ItemCategories where Category_Name = @Category)=@level
	BEGIN
		Insert into @tmp1 select CategoryID, 0     
		From ItemCategories   
		Where ItemCategories.Category_Name = @Category
	    
		While @Continue > 0    
			Begin    
				Declare Parent Cursor Keyset For    
				Select CategoryID From @tmp1 Where Status = 0    
				Open Parent    
				Fetch From Parent Into @CategoryID    
				While @@Fetch_Status = 0    
				Begin    
					Insert into @tmp1     
					Select CategoryID, 0 From ItemCategories     
					Where ParentID = @CategoryID    
					If @@RowCount > 0     
						Update @tmp1 Set Status = 1 Where CategoryID = @CategoryID    
					Else    
						Update @tmp1 Set Status = 2 Where CategoryID = @CategoryID    
					Fetch Next From Parent Into @CategoryID    
				End    
				Close Parent    
				DeAllocate Parent    
				Select @Continue = Count(*) From @tmp1 Where Status = 0    
			End    
			Delete @tmp1 Where Status not in  (0, 2)    
			Insert @CatID Select Distinct CategoryID From @tmp1
	END  
	Return  
End  
