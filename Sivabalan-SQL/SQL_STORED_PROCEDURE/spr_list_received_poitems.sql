CREATE procedure [dbo].[spr_list_received_poitems](@PONUMBER int)
AS
SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName, Quantity, "Purchase Price" = PurchasePrice
FROM PODetailReceived, Items
WHERE PONumber = @PONUMBER AND PODetailReceived.Product_Code *= Items.Alias
