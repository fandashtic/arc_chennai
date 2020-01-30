Create Procedure Sp_IsLeafLevelCategory(@CategoryID Int)  
as  
Begin  



	If Not Exists(Select * From ItemCategories where ParentID = @CategoryID)
		Select 1
	else
		Select 0

End  
