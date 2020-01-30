
CREATE PROCEDURE sp_list_SplCatItemDet(@SPLCATCODE INT)

AS

SELECT Special_Cat_Product.Product_Code, ProductName, 
Special_Cat_Product.CategoryID, Category_Name 
FROM Special_Cat_Product, Items, ItemCategories
WHERE Special_Cat_Code = @SPLCATCODE 
AND Special_Cat_Product.Product_Code = Items.Product_Code 
AND Special_Cat_Product.CategoryID = ItemCategories.CategoryID

