Create Function mERP_fn_GetLeafCategories(@ProductHierarchy nvarchar(255), @Category nVarchar(1000))
returns @tempCategory Table(CategoryID Int, Status Int)
AS
Begin
--	Declare @tempCategory Table(CategoryID Int, Status Int)
	Declare @tmpCat Table(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
	Declare @Continue int  
	Declare @CategoryID int
	Set @Continue = 1

	if @Category='%'     
	   Insert into @tmpCat Select Category_Name from ItemCategories
	Else    
	   Insert into @tmpCat Select @Category

	If @ProductHierarchy = '%'
	Begin
		Insert into @tempCategory 
		Select CategoryID, 0   
		From ItemCategories
		Where ItemCategories.Category_Name In (Select Category from @tmpCat)
	End
	Else
	Begin
		Insert Into @tempCategory 
		Select CategoryID, 0
		From ItemCategories, ItemHierarchy  
		Where ItemCategories.Category_Name In (Select Category from @tmpCat) And 
		ItemCategories.Level =  ItemHierarchy.HierarchyID And  
		ItemHierarchy.HierarchyName like @ProductHierarchy  
	End

	While @Continue > 0  
	Begin  
		Declare Parent Cursor Keyset For  
		Select CategoryID From @tempCategory Where Status = 0  
		Open Parent  
		Fetch From Parent Into @CategoryID  
		While @@Fetch_Status = 0  
		Begin  
			Insert into @tempCategory   
			Select CategoryID, 0 From ItemCategories   
			Where ParentID = @CategoryID  
			If @@RowCount > 0   
				Update @tempCategory Set Status = 1 Where CategoryID = @CategoryID  
			Else  
				Update @tempCategory Set Status = 2 Where CategoryID = @CategoryID  
			Fetch Next From Parent Into @CategoryID  
		End  
		Close Parent  
		DeAllocate Parent  
		Select @Continue = Count(*) From @tempCategory Where Status = 0  
	End  
	Delete @tempcategory Where Status not in  (0, 2)
	Return
End
