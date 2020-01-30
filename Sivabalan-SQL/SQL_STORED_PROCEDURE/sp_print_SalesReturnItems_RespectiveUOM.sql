CREATE procedure [dbo].[sp_print_SalesReturnItems_RespectiveUOM](@INVOICEID INT)  
  
AS  
  
SELECT "Item Code" = InvoiceDetail.Product_Code,   
"Item Name" = Items.ProductName, "Quantity" = InvoiceDetail.UOMQty, 
"UOM" = UOM.Description, "Sale Price" = UOMPrice,  
"Tax" = TaxCode, "Amount" = Amount   
FROM InvoiceDetail, Items, UOM  
WHERE InvoiceID = @INVOICEID   
AND InvoiceDetail.Product_Code = Items.Product_Code  
AND InvoiceDetail.UOM *= UOM.UOM
