Create Procedure mERP_sp_CatHandler_GetSubCategoryMapping  
as   
Begin  
 Select Cat.Category_Name as Category, SubCat.Category_Name SubCategory  
 From ItemCategories Cat, ItemCategories SubCat, CategoryLevelInfo CLI    
 Where SubCat.[Level] = CLI.LevelNo    
 And Cat.Active = 1    
 And SubCat.Active = 1    
 And SubCat.ParentID = Cat.CategoryID  
 And Cat.[Level] = 2   
 Order by Cat.Category_Name, SubCat.Category_Name
End
