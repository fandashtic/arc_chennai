CREATE PROCEDURE sp_get_CategoryItems(@CATEGORYID INT)    
AS    
SELECT Product_Code, ProductName,Items.CategoryID,Category_Name 
FROM Items INNER JOIN ItemCategories ON Items.CategoryID=ItemCategories.CategoryID   
WHERE Items.Active = 1 AND Items.CategoryID   
  IN (SELECT CategoryID FROM dbo.sp_get_LeafNodes(@CATEGORYID))  
   

