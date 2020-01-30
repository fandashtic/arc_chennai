CREATE PROCEDURE sp_list_SplCatDet(@SPLCATCODE INT,@WithCategoryName INT=0)     
AS    
BEGIN   
 IF  @WithCategoryName=0  
  SELECT CategoryID FROM Special_Cat_Product     
  WHERE Special_Cat_Code = @SPLCATCODE     
 ELSE  
  SELECT Distinct ItemCategories.CategoryID, ItemCategories.Category_Name  
  FROM Special_Cat_Product INNER JOIN ItemCategories   
  ON Special_Cat_Product.HierarchyID=ItemCategories.CategoryID    
  WHERE Special_Cat_Code = @SPLCATCODE    
END  


