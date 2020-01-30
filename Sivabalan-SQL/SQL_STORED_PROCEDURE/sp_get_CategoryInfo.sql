
CREATE PROCEDURE sp_get_CategoryInfo(@ITEMCODE NVARCHAR(15))

AS

SELECT ItemCategories.CategoryID, ItemCategories.Category_Name, 
Items.ProductName FROM Items, ItemCategories 
WHERE Items.CategoryID = ItemCategories.CategoryID 
AND Items.Product_Code = @ITEMCODE

