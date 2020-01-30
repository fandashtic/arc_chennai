CREATE PROCEDURE sp_get_InvoiceDetailReceived_only_MUOM (@INVOICENO INT)            
AS      
SELECT           
Items.Product_Code, Items.ProductName, NULL, Batch_Number,
Case When Isnull(InvoiceDetailReceived.UOM,0) = 0 Then InvoiceDetailReceived.Quantity
     Else InvoiceDetailReceived.UOMQty END,       
-- Case When Isnull(InvoiceDetailReceived.UOM,0) = 0 Then InvoiceDetailReceived.SalePrice      
--      Else InvoiceDetailReceived.UOMPrice END,
InvoiceDetailReceived.SalePrice,          
InvoiceDetailReceived.TaxCode, InvoiceDetailReceived.DiscountPercentage,          
InvoiceDetailReceived.DiscountValue, InvoiceDetailReceived.Amount, Null, Null, --tax suffered           
Case When Isnull(InvoiceDetailReceived.UOM,0) = 0 Then Items.UOM      
     Else InvoiceDetailReceived.UOM END, Null SCHEMEID, Null SPLCATSCHEMEID,      
Null FREESERIAL, Null SPLCATSERIAL,      
NULL SCHEMEDISCPERCENT, NULL SCHEMEDISCAMOUNT,      
NULL SPLCATDISCPERCENT, NULL SPLCATDISCAMOUNT,  
NULL SPECIALCATEGORYSCHEME, NULL SCHEME_INDICATOR, NULL SPLCATSCHEME_INDICATOR,
"SPBED" = Isnull(InvoiceDetailReceived.SalePriceBeforeExciseAmount,0),
"ExciseDuty" = Isnull(InvoiceDetailReceived.ExciseDuty,0),
"Serial" = ItemOrder, "MRP" = IsNull(InvoiceDetailReceived.MRP,0)
FROM InvoiceDetailReceived, Items          
WHERE InvoiceDetailReceived.InvoiceID = @INVOICENO          
AND InvoiceDetailReceived.Product_Code = Items.Product_Code         
Order by ItemOrder
