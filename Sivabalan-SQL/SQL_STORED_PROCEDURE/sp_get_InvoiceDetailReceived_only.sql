CREATE PROCEDURE sp_get_InvoiceDetailReceived_only (@INVOICENO INT)          
AS          
SELECT         
Items.Product_Code, Items.ProductName, NULL, Batch_Number,         
InvoiceDetailReceived.Quantity, InvoiceDetailReceived.SalePrice,        
InvoiceDetailReceived.TaxCode, InvoiceDetailReceived.DiscountPercentage,        
InvoiceDetailReceived.DiscountValue, InvoiceDetailReceived.Amount, Null, Null, Null SCHEMEID, Null SPLCATSCHEMEID,      
Null FREESERIAL, Null SPLCATSERIAL,      
NULL SCHEMEDISCPERCENT, NULL SCHEMEDISCAMOUNT,      
NULL SPLCATDISCPERCENT, NULL SPLCATDISCAMOUNT,  
NULL SPECIALCATEGORYSCHEME, NULL SCHEME_INDICATOR, NULL SPLCATSCHEME_INDICATOR , SPBED = IsNull(InvoiceDetailReceived.SalePriceBeforeExciseAmount,0) , ExciseDuty = IsNull(InvoiceDetailReceived.ExciseDuty,0)    
FROM InvoiceDetailReceived, Items        
WHERE InvoiceDetailReceived.InvoiceID = @INVOICENO        
AND InvoiceDetailReceived.Product_Code = Items.Product_Code and active = 1    
Order by ItemOrder
  
  
  


