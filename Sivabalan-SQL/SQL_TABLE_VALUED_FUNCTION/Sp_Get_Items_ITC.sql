Create Function Sp_Get_Items_ITC(@GroupID nVarchar(1000))
Returns @Items Table
(
 Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS
)
As
Begin
	Declare @TempItems Table
	(
	 Product_Code   NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
	 ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS
	)
	Declare @TempCategory Table(CategoryID Int, Status Int)
	Declare @Continue Int
	Declare @CategoryID Int

	Declare @OCGFlag as Int
	Set @OCGFlag = (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS')

	Set @Continue = 1

If isnull(@OCGFlag ,0) = 0
 Begin
	Insert Into @TempCategory
	Select 
		IC.CategoryID,0 
	From 
		ProductCategoryGroupAbstract PCGA,
		tblCGDivMapping CGDIV,
		ItemCategories IC
	Where 
		PCGA.GroupID In(Select * From dbo.sp_splitIn2Rows(@GroupID,','))
		And CGDIV.CategoryGroup = PCGA.GroupName
		And IC.Category_Name = CGDIV.Division

	While @Continue > 0    
	Begin    
		Declare Parent Cursor Keyset For Select CategoryID From @TempCategory Where Status = 0    
		Open Parent
		Fetch From Parent Into @CategoryID    
		While @@Fetch_Status = 0    
		Begin    
			Insert Into @TempCategory     
			Select CategoryID, 0 From ItemCategories Where ParentID = @CategoryID    
			If @@RowCount > 0
				Update @TempCategory Set Status = 1 Where CategoryID = @CategoryID
			Else
				Update @TempCategory Set Status = 2 Where CategoryID = @CategoryID
			Fetch Next From Parent Into @CategoryID
		End
		Close Parent
		DeAllocate Parent
		Select @Continue = Count(*) From @TempCategory Where Status = 0
	End
	Delete @TempCategory Where Status Not In (0, 2)

	Insert Into @TempItems
	Select	Distinct Items.Product_Code,Items.ProductName
	From	@TempCategory TC,Items
	Where TC.CategoryID = Items.CategoryID
	And Items.Active = 1

	Insert Into @Items Select Product_Code,ProductName From @TempItems
  End
Else
	/* Active not considered perviously, it is handled now*/
	Insert Into @Items Select FN.Product_Code,FN.ProductName From Fn_GetOCGSKU(@GroupID) FN,Items I where 
	FN.Product_code=I.Product_code And
	isnull(I.active,0)=1

	Return

End
