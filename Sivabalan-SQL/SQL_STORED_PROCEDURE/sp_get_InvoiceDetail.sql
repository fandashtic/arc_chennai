CREATE PROCEDURE sp_get_InvoiceDetail(@INVOICENO INT)   
AS    
 SELECT InvoiceDetail.Product_Code, Items.ProductName,     
 NULL, InvoiceDetail.Batch_Number,     
 ISNULL(SUM(InvoiceDetail.Quantity), 0), InvoiceDetail.SalePrice,    
 ISNULL(MAX(InvoiceDetail.TaxCode), 0) + ISNULL(MAX(InvoiceDetail.TaxCode2), 0),     
 ISNULL(MAX(InvoiceDetail.DiscountPercentage), 0),    
 ISNULL(SUM(InvoiceDetail.DiscountValue), 0), ISNULL(SUM(InvoiceDetail.Amount), 0),    
 ISNULL(MAX(InvoiceDetail.TaxSuffered), 0),    
 ISNULL(MAX(InvoiceDetail.TaxSuffered), 0),  
 InvoiceDetail.MRP ,
 ISNULL(MAX(InvoiceDetail.SchemeID), 0) SCHEMEID,    
 ISNULL(MAX(InvoiceDetail.SPLCATSchemeID), 0) SPLCATSCHEMEID,    
 ISNULL(MAX(InvoiceDetail.FREESERIAL), 0) FREESERIAL,    
 ISNULL(MAX(InvoiceDetail.SPLCATSERIAL), N'') SPLCATSERIAL,    
 ISNULL(AVG(InvoiceDetail.SchemeDiscPercent), 0) SCHEMEDISCPERCENT,    
 ISNULL(SUM(InvoiceDetail.SchemeDiscAmount), 0) SCHEMEDISCAMOUNT,    
 ISNULL(AVG(InvoiceDetail.SPLCATDiscPercent), 0) SPLCATDISCPERCENT,    
 ISNULL(SUM(InvoiceDetail.SPLCATDiscAmount), 0) SPLCATDISCAMOUNT,
 ISNULL(MAX(InvoiceDetail.SpecialCategoryScheme), 0) SPECIALCATEGORYSCHEME,
 ISnull((Select SchemeType From Schemes Where Schemes.SchemeId = Min(InvoiceDetail.SchemeID)),N'') SCHEME_INDICATOR ,
 ISnull((Select SchemeType From Schemes Where Schemes.SchemeId = Min(InvoiceDetail.SPLCATSchemeID)),N'') SPLCATSCHEME_INDICATOR 
,"SPBED" = InvoiceDetail.SalePriceBeforeExciseAmount, "ExciseDuty" = InvoiceDetail.ExciseDuty,
Isnull(Max(TaxSuffAmount),0) TaxSuffAmount,Isnull(sum(STCredit),0) STCredit,Isnull(Max(TaxAmount),0) TaxAmount,
InvoiceDetail.Serial 
 FROM InvoiceDetail, Items 
 WHERE InvoiceDetail.InvoiceID = @INVOICENO    
 AND InvoiceDetail.Product_Code = Items.Product_Code    
 GROUP BY InvoiceDetail.Product_Code, Items.ProductName,     
 InvoiceDetail.Batch_Number, InvoiceDetail.SalePrice , InvoiceDetail.MRP,InvoiceDetail.Serial
,InvoiceDetail.SalePriceBeforeExciseAmount, InvoiceDetail.ExciseDuty  
 ORDER BY InvoiceDetail.Serial
