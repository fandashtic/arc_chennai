CREATE PROCEDURE [dbo].[sp_view_RetailDetail](@INVOICEID INT)    
AS    
SELECT InvoiceDetail.Product_Code, Items.ProductName,     
InvoiceDetail.Batch_Number, SUM(InvoiceDetail.Quantity),     
InvoiceDetail.SalePrice,     
ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0),    
Max(InvoiceDetail.DiscountPercentage), SUM(InvoiceDetail.DiscountValue),    
SUM(InvoiceDetail.Amount), MIN(InvoiceDetail.Batch_Code), InvoiceDetail.SaleID,    
ISNULL(Max(InvoiceDetail.TaxSuffered), 0),    
InvoiceDetail.FlagWord, InvoiceDetail.freeSerial, InvoiceDetail.SPLCATSerial,     
InvoiceDetail.SpecialCategoryScheme, InvoiceDetail.SCHEMEID, InvoiceDetail.SPLCATSCHEMEID,     
InvoiceDetail.SCHEMEDISCPERCENT, InvoiceDetail.SCHEMEDISCAMOUNT,     
InvoiceDetail.SPLCATDISCPERCENT, InvoiceDetail.SPLCATDISCAMOUNT,    
isnull((Select SchemeType From Schemes Where SchemeID = InvoiceDetail.SchemeID),0) SCHEME_INDICATOR,    
isnull((Select SchemeType From Schemes Where SchemeID = InvoiceDetail.SPLCATSchemeID),0) SPLCATSCHEME_INDICATOR, InvoiceDetail.SalesStaffID,InvoiceDetail.SalesStaffID,  
Max(InvoiceDetail.TaxSuffApplicableOn) 'TaxSuffApplicableOn', Max(InvoiceDetail.TaxSuffPartOff) 'TaxSuffPartOff',
Isnull(Batch_Products.Free,0) 'Free',
Max(InvoiceDetail. TaxApplicableOn) 'TaxApplicableOn', Max(InvoiceDetail.TaxPartOff) 'TaxPartOff',
max(InvoiceDetail.stcredit) as StCredit,max(InvoiceDetail.taxamount) as TaxAmount,Max(InvoiceDetail.taxsuffamount) as TaxSuffAmount
FROM InvoiceDetail
Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code    
Left Outer Join  Batch_Products On Batch_Products.Batch_Code = InvoiceDetail.Batch_Code    
WHERE InvoiceDetail.InvoiceID = @INVOICEID    
GROUP BY InvoiceDetail.Serial,    
InvoiceDetail.Product_Code, Items.ProductName,     
InvoiceDetail.SalePrice, InvoiceDetail.Batch_Number, InvoiceDetail.SaleID,InvoiceDetail.SalesStaffID,    
InvoiceDetail.FlagWord, InvoiceDetail.freeSerial, InvoiceDetail.SPLCATSerial,     
InvoiceDetail.SpecialCategoryScheme, InvoiceDetail.SCHEMEID, InvoiceDetail.SPLCATSCHEMEID, InvoiceDetail.SCHEMEDISCPERCENT, InvoiceDetail.SCHEMEDISCAMOUNT,    
InvoiceDetail.SPLCATDISCPERCENT, InvoiceDetail.SPLCATDISCAMOUNT,InvoiceDetail.SalesStaffID,
Isnull(Batch_Products.Free,0)   
