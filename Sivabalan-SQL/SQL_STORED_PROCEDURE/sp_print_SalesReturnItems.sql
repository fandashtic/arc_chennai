CREATE procedure [dbo].[sp_print_SalesReturnItems](@INVOICEID INT)

AS

SELECT "Item Code" = InvoiceDetail.Product_Code, 
"Item Name" = Items.ProductName, "Quantity" = Quantity, "Sale Price" = SalePrice,
"Tax" = TaxCode, "Amount" = Amount, "UOM" = UOM.Description 
FROM InvoiceDetail, Items, UOM
WHERE InvoiceID = @INVOICEID 
AND InvoiceDetail.Product_Code = Items.Product_Code
AND Items.UOM *= UOM.UOM
