Create Procedure mERP_sp_CategoryHandlerList
As
Select SNo, ParentID, CategoryID, Category_Name, [Level] 
From ItemCategories IC, CategoryLevelInfo CLI
Where IC.[Level] = CLI.LevelNo
And IC.Active = 1
Order by IC.[Level], IC.CategoryID, IC.ParentID
