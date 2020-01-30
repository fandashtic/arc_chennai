CREATE procedure [dbo].[sp_print_poitems_Ascending](@PONo INT)

AS

SELECT "Item Code" = PODetail.Product_Code, "Item Name" = Items.ProductName,
"Quantity" = Quantity, "UOM" = UOM.Description, "Price" = PurchasePrice, "Pending" = Pending,
"Amount" = Quantity * PurchasePrice,
"Property1" = dbo.GetProperty(PODetail.Product_Code, 1),
"Property2" = dbo.GetProperty(PODetail.Product_Code, 2),
"Property3" = dbo.GetProperty(PODetail.Product_Code, 3),
"Property4" = dbo.GetProperty(PODetail.Product_Code, 4),
"Category" = ItemCategories.Category_Name
FROM PODetail, Items, UOM, ItemCategories
WHERE PODetail.PONumber = @PONo 
AND PODetail.Product_Code = Items.Product_Code
AND Items.UOM *= UOM.UOM
And Items.CategoryID = ItemCategories.CategoryID
Order by podetail.product_code
