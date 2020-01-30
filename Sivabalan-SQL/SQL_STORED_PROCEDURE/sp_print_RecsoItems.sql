CREATE procedure [dbo].[sp_print_RecsoItems](@SONumber int)
AS
SELECT 
"Item Code" = 
case
when Items.Product_Code is null then
SODetailReceived.Product_Code
else
Items.Product_Code
end, "Item Name" = ProductName, "Quantity" = Quantity, 
"Sale Price" = SalePrice, "Tax" = SaleTax,
"Discount" = Discount FROM SODetailReceived, Items
WHERE SODetailReceived.SONumber = @SONUMBER
AND SODetailReceived.Product_Code *= Items.Alias
