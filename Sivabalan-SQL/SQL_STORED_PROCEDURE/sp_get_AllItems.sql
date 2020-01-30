
CREATE PROCEDURE sp_get_AllItems

AS

SELECT Product_Code, ProductName, Items.CategoryID, Category_Name
FROM Items, ItemCategories 
WHERE Items.CategoryID = ItemCategories.CategoryID
ORDER BY Category_Name

