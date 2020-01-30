CREATE procedure [dbo].[sp_get_InvoiceDetailReceived](@INVOICENO INT)  
AS  
SELECT   
case  
when Items.Product_Code is null then  
InvoiceDetailReceived.ForumCode  
else  
Items.Product_Code  
end, Items.ProductName, NULL, Batch_Number,   
InvoiceDetailReceived.Quantity, InvoiceDetailReceived.SalePrice,  
InvoiceDetailReceived.TaxCode, InvoiceDetailReceived.DiscountPercentage,  
InvoiceDetailReceived.DiscountValue, InvoiceDetailReceived.Amount,  
Null, Null, Null SCHEMEID, Null SPLCATSCHEMEID,    
Null FREESERIAL, Null SPLCATSERIAL,    
NULL SCHEMEDISCPERCENT, NULL SCHEMEDISCAMOUNT,    
NULL SPLCATDISCPERCENT, NULL SPLCATDISCAMOUNT,
NULL SPECIALCATEGORYSCHEME, NULL SCHEME_INDICATOR, NULL SPLCATSCHEME_INDICATOR
, SPBED = IsNull(InvoiceDetailReceived.SalePriceBeforeExciseAmount,0) , ExciseDuty = IsNull(InvoiceDetailReceived.ExciseDuty,0)    
FROM InvoiceDetailReceived, Items  
WHERE InvoiceDetailReceived.InvoiceID = @INVOICENO  
AND InvoiceDetailReceived.Product_Code *= Items.Product_Code  
Order By ItemOrder
