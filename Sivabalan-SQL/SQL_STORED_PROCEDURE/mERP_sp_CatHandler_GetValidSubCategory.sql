CREATE Procedure mERP_sp_CatHandler_GetValidSubCategory(@CategoryID Int)  
as  
Begin  
  Select IC.CategoryID, IC.Category_Name, (select Count(CategoryID) From ItemCategories Where Active = 1 and ParentID = @CategoryID) as 'RecCount'  
  From ItemCategories IC, CategoryLevelInfo CLI  
  Where IC.[Level] = CLI.LevelNo    
  And IC.Active = 1    
  And CLI.LevelNo  = 3  
  And IC.ParentID = @CategoryID  
  Group By IC.CategoryID, IC.Category_Name  
End
