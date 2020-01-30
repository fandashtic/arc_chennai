CREATE PROCEDURE sp_viewonly_RetailDetail(@INVOICEID INT)  
AS  
SELECT InvoiceDetail.Product_Code, Items.ProductName,   
InvoiceDetail.Batch_Number, ISNULL(SUM(InvoiceDetail.Quantity), 0),   
InvoiceDetail.SalePrice,   
ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0),  
Max(InvoiceDetail.DiscountPercentage), SUM(InvoiceDetail.DiscountValue),  
SUM(InvoiceDetail.Amount), 0, InvoiceDetail.SaleID,  
ISNULL(Max(InvoiceDetail.TaxSuffered), 0),  
InvoiceDetail.FlagWord, InvoiceDetail.freeSerial, InvoiceDetail.SPLCATSerial, InvoiceDetail.SpecialCategoryScheme, InvoiceDetail.SCHEMEID, InvoiceDetail.SPLCATSCHEMEID,   
InvoiceDetail.SCHEMEDISCPERCENT, InvoiceDetail.SCHEMEDISCAMOUNT, InvoiceDetail.SPLCATDISCPERCENT, InvoiceDetail.SPLCATDISCAMOUNT,  
isnull((Select SchemeType From Schemes Where SchemeID = InvoiceDetail.SchemeID),0) SCHEME_INDICATOR,  
isnull((Select SchemeType From Schemes Where SchemeID = InvoiceDetail.SPLCATSchemeID),0) SPLCATSCHEME_INDICATOR, InvoiceDetail.SalesStaffID,
SUM(InvoiceDetail.TaxAmount) as TaxAmount,
SUM(InvoiceDetail.TaxSuffAmount) as TaxSuffAmount,
SUM(InvoiceDetail.STCredit) as STCredit
FROM InvoiceDetail, Items  
WHERE InvoiceDetail.InvoiceID = @INVOICEID  
AND InvoiceDetail.Product_Code = Items.Product_Code  
GROUP BY InvoiceDetail.Serial,InvoiceDetail.Product_Code, Items.ProductName,   
InvoiceDetail.Batch_Number, InvoiceDetail.SalePrice, InvoiceDetail.SaleID,  
InvoiceDetail.FlagWord, InvoiceDetail.freeSerial, InvoiceDetail.SPLCATSerial, InvoiceDetail.SpecialCategoryScheme,   
InvoiceDetail.SCHEMEID, InvoiceDetail.SPLCATSCHEMEID, InvoiceDetail.SCHEMEDISCPERCENT,  
InvoiceDetail.SCHEMEDISCAMOUNT, InvoiceDetail.SPLCATDISCPERCENT, InvoiceDetail.SPLCATDISCAMOUNT,  
InvoiceDetail.SalesStaffID  
  


