CREATE procedure [dbo].[sp_print_POItems_RespectiveUOM_Ascending](@PONo INT)    
    
AS    
    
SELECT "Item Code" = PODetail.Product_Code, "Item Name" = Items.ProductName, "Quantity" = PODetail.UOMQty,     
"UOM" = UOM.Description, "Price" = UOMPrice, "Pending" = Pending,    
"Amount" = Quantity * PurchasePrice,    
"Property1" = dbo.GetProperty(PODetail.Product_Code, 1),    
"Property2" = dbo.GetProperty(PODetail.Product_Code, 2),    
"Property3" = dbo.GetProperty(PODetail.Product_Code, 3),    
"Property4" = dbo.GetProperty(PODetail.Product_Code, 4),    
"Category" = ItemCategories.Category_Name    
FROM PODetail, Items, UOM, ItemCategories    
WHERE PODetail.PONumber = @PONo     
AND PODetail.Product_Code = Items.Product_Code    
AND PODetail.UOM *= UOM.UOM    
And Items.CategoryID = ItemCategories.CategoryID    
Order by   PODetail.Product_Code
