CREATE PROCEDURE sp_get_InvoiceDetailReceived_MUOM(@INVOICENO INT)      
AS      
SELECT
Case When Items.Product_Code is NULL Then InvoiceDetailReceived.ForumCode Else Items.Product_Code End,
Items.ProductName, NULL, Batch_Number,         
Case When InvoiceDetailReceived.UOM = 0 Then InvoiceDetailReceived.Quantity    
     Else InvoiceDetailReceived.UOMQty END,     
InvoiceDetailReceived.SalePrice,
-- Case When InvoiceDetailReceived.UOM = 0 Then InvoiceDetailReceived.SalePrice    
--      Else InvoiceDetailReceived.UOMPrice END,          
InvoiceDetailReceived.TaxCode, InvoiceDetailReceived.DiscountPercentage,      
InvoiceDetailReceived.DiscountValue, InvoiceDetailReceived.Amount,      
Null, Null,    
Case When InvoiceDetailReceived.UOM = 0 Then Items.UOM    
     Else InvoiceDetailReceived.UOM END, Null SCHEMEID, Null SPLCATSCHEMEID,          
Null FREESERIAL, Null SPLCATSERIAL,          
NULL SCHEMEDISCPERCENT, NULL SCHEMEDISCAMOUNT,          
NULL SPLCATDISCPERCENT, NULL SPLCATDISCAMOUNT,      
NULL SPECIALCATEGORYSCHEME, NULL SCHEME_INDICATOR, NULL SPLCATSCHEME_INDICATOR,   
"SPBED" = Isnull(InvoiceDetailReceived.SalePriceBeforeExciseAmount,0),    
"ExciseDuty" = Isnull(InvoiceDetailReceived.ExciseDuty,0),    
"Serial" = ItemOrder, "MRP" = IsNull(InvoiceDetailReceived.MRP,0)
FROM InvoiceDetailReceived left outer join Items    on  InvoiceDetailReceived.Product_Code = Items.Product_Code     
WHERE InvoiceDetailReceived.InvoiceID = @INVOICENO         
Order by ItemOrder
