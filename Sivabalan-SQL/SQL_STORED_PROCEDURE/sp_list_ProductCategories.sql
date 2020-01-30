CREATE PROCEDURE sp_list_ProductCategories ( @Product_Level int=0 )    
AS      
BEGIN    
 IF @Product_Level = 0     
  SELECT ItemCategories.CategoryID, Category_Name FROM ItemCategories      
  WHERE ItemCategories.CategoryID IN (SELECT DISTINCT CategoryID       
  FROM Items WHERE Active = 1) AND Active = 1      
 ELSE  
  SELECT CategoryID, Category_Name   
  FROM ItemCategories IC 
  WHERE Level = @Product_Level AND Active = 1      
  AND dbo.fn_get_LeafNodescount(IC.CategoryID)>0     
END 

