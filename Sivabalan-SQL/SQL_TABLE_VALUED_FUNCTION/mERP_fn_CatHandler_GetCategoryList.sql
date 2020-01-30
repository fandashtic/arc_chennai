Create Function mERP_fn_CatHandler_GetCategoryList(@Level Int, @ParentID Int = 0)
Returns @CategoryHandler Table (CategoryID Int, Category_Name nVarchar(510))
As
  Begin
    Insert into @CategoryHandler
    Select CategoryID, Category_Name From
    (Select 0 as 'Level',0 as 'ParentID', 999999 'CategoryID', 'ALL' as 'Category_Name'
	Union
    Select IC.[Level],ParentID, IC.CategoryID, IC.Category_Name 
    From ItemCategories IC, CategoryLevelInfo CLI  
    Where IC.[Level] = CLI.LevelNo  
    And IC.Active = 1  
    And CLI.LevelNo  = @Level
    And ParentID = Case @ParentID When 0 Then ParentID Else @ParentID End
    ) A
    Order by [Level], ParentID, Category_Name
    Return 
  End
