CREATE procedure [dbo].[sp_print_RecRetInvItems](@INVNO INT)
AS
SELECT 
"Item Code" = 
case
when Items.Product_Code is null then
InvoiceDetailReceived.Product_Code
else
Items.Product_Code
end, "Item Name" = Items.ProductName, "Quantity" = Quantity, 
"Sale Price" = SalePrice, "Tax" = TaxCode, 
"Discount%" = DiscountPercentage, "Discount Value" = DiscountValue, 
"Amount" = Amount 
FROM InvoiceDetailReceived, Items
WHERE InvoiceID = @INVNO
AND InvoiceDetailReceived.Product_Code *= Items.Alias
