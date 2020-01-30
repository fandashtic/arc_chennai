Create Function sp_han_GetCategoryGroup(@ItemCatID Int)
Returns Int
As
Begin
Declare @GroupID int
Declare @TempCategory Table(CategoryID Int, ParentID Int, Status Int)
Declare @ParentID int
Declare @OCGFlag as Int
Set @OCGFlag = (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS')

Declare @TempCGDivMapping Table (GroupID Int, CategoryID Int)

If isnull(@OCGFlag ,0) = 0
 Begin
	Insert Into @TempCGDivMapping
	Select GroupID, CategoryID From 
	(Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup, 
	"CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division
	From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat
	Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name)
	CatMapping
 End
Else
 Begin
	Insert Into @TempCGDivMapping
	select Distinct GroupID, CategoryID from Fn_GetOCGSKU('%') Where CategoryID in (@ItemCatID)
 End

Select @GroupID = GroupID from @TempCGDivMapping Where CategoryId = @ItemCatID
If Isnull(@GroupID, 0) = 0 
Begin 
	Insert Into @TempCategory Select @ItemCatID, ParentID, 0 from ItemCategories Where CategoryID = @ItemCatID
	Declare Parent Cursor DYNAMIC For Select ParentID From @TempCategory Where Status = 0    
	Open Parent
	Fetch From Parent Into @ParentID
	While @@Fetch_Status = 0
	Begin
		Select @GroupID = GroupID from @TempCGDivMapping Where CategoryId = @ParentID
		If Isnull(@GroupID, 0) > 0 
		begin
	 		Update @TempCategory Set Status = 1
		end
		else
		begin
			Insert Into @TempCategory
			Select CategoryID, ParentID, 0 From ItemCategories Where CategoryID = @ParentID
			Update @TempCategory Set Status = 1 Where ParentID = @ParentID
		end
		Fetch Next From Parent Into @ParentID
	End
	Close Parent
	DeAllocate Parent
End 
Return @GroupID
End 
