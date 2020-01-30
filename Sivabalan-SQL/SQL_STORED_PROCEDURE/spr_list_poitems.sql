CREATE procedure [dbo].[spr_list_poitems](@PONUMBER int)
AS
SELECT PODetail.Product_Code, "Item Code" = PODetail.Product_Code, 
"Item Name" = Items.ProductName, 
"PO Quantity" = Quantity, 
"Pending Quantity" = Pending,"Purchase Price" = PurchasePrice
FROM PODetail, Items
WHERE PONumber = @PONUMBER AND PODetail.Product_Code *= Items.Product_Code
