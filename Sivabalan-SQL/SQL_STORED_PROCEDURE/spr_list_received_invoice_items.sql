CREATE PROCEDURE [dbo].[spr_list_received_invoice_items](@INVOICE_ID int)      
AS      
SELECT  Items.Product_Code, "Item Code" = Items.Product_Code, Quantity,       
"Sale Price" = SalePrice, "Tax %" = TaxCode, "Discount %" = DiscountPercentage,    
"Excise %" = InvoiceDetailReceived.ExcisePercentage,  
"Excise Duty " = InvoiceDetailReceived.ExciseDuty,
"Amount" = Amount      
FROM    InvoiceDetailReceived Left Join Items On InvoiceDetailReceived.ForumCode = Items.Alias
WHERE InvoiceID = @INVOICE_ID 

