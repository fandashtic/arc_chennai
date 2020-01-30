CREATE PROCEDURE spr_list_dbr_damagestock
AS

SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName, 
	"Total Damages" = Sum(Quantity), "Hierarchy First Level" = dbo.fn_FirstLevelCategory(items.categoryid),
	"Hierarchy Last Level" = (select c.description from itemcategories c
		     where c.categoryid = items.categoryid)	
FROM Items, Batch_Products
WHERE 	Items.Product_Code = Batch_Products.Product_Code And IsNull(Damage, 0) > 0 And Quantity > 0
Group By Items.Product_Code, Items.ProductName, items.categoryid
ORDER BY Items.Product_Code

