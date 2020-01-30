Create Function fn_GetCatIDUnderHierarchyLvl_ITC(@Hierarchy NVARCHAR(50))    
Returns @CatID Table (CatID Int)    
As    
Begin   
	If @Hierarchy = '%' Or @Hierarchy = '%%'
		Insert @CatID   
		select distinct CategoryID from  ItemCategories Where Level = 1 
	Else
		Insert @CatID   
		Select CategoryID From ItemCategories Where Level = 
			(Select HierarchyID From ItemHierarchy Where HierarchyName = @Hierarchy)
	Return 
End
