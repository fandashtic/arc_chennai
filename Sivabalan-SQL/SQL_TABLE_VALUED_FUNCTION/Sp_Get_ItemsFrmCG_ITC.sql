Create Function  [dbo].[Sp_Get_ItemsFrmCG_ITC](@GroupID Int)
Returns @Items Table
(
Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS
)
As
Begin
Declare @TempItems Table
(
Product_Code
   NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS
)
Declare @TempCategory Table(CategoryID Int, Status Int)


Declare @Continue Int
Declare @CategoryID Int

Set @Continue = 1

Declare @TempCGDivMapping Table (GroupID Int, CategoryID Int)

Insert Into @TempCGDivMapping Select GroupID, CategoryID From
(Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup,
"CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division
From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat
Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name)
CatMapping



Insert Into @TempCategory
Select CategoryID,0 From @TempCGDivMapping PCD Where PCD.GroupID = @GroupID

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
Close 
Parent
DeAllocate Parent
Select @Continue = Count(*) From @TempCategory Where Status = 0
End
Delete @TempCategory Where Status Not In (0, 2)

Insert Into @TempItems
Select
Distinct Items.Product_Code,Items.ProductName
From
@TempCategory TC,Items
Where
TC.
CategoryID = Items.CategoryID
--And Items.Active = 1

Insert Into @Items Select Product_Code,ProductName From @TempItems
Return
End
