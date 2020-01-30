CREATE procedure [dbo].[sp_print_RecPOItems](@PONo INT)
AS
SELECT 
"Item Code" = 
case
when Items.Product_Code is null then
PODetailReceived.Product_Code
else
Items.Product_Code
end, "Item Name" = Items.ProductName, "Quantity" = Quantity, 
NULL, "Purchase Price" = PurchasePrice FROM PODetailReceived, Items
WHERE PODetailReceived.PONumber = @PONo 
AND PODetailReceived.Product_Code *= Items.Alias
