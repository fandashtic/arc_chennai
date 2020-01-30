CREATE PROCEDURE spr_list_items_in_invoice_pidilite(@INVOICEID int)    
AS    
DECLARE @ADDNDIS AS Decimal(18,6)    
DECLARE @TRADEDIS AS Decimal(18,6)    
    
SELECT @ADDNDIS = isnull(AdditionalDiscount,0), @TRADEDIS = isnull(DiscountPercentage,0) FROM InvoiceAbstract    
WHERE InvoiceID = @INVOICEID    
    
SELECT  InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,     
 "Item Name" = Items.ProductName,     
 "Batch" = InvoiceDetail.Batch_Number,    
 "Quantity" = SUM(InvoiceDetail.Quantity),     
 "Reporting UOM" = SUM(InvoiceDetail.Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),    
 "Conversion Factor" = SUM(InvoiceDetail.Quantity * IsNull(ConversionFactor, 0)),    
 "Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0),     
 "Sale Tax" = CAST(Round(MAX(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2), 2) AS nvarchar) + '%',    
 "Tax Suffered" = CAST(ISNULL(MAX(InvoiceDetail.TaxSuffered), 0) AS nvarchar) + '%',    
 "Discount" = CAST(SUM(DiscountPercentage) AS nvarchar) + '%',    
 "STCredit" = Round(IsNull(Sum(InvoiceDetail.STCredit),0),2),    
 "Total" = SUM(Amount),    
 "Forum Code" = Items.Alias,   
 "Tax Suffered Value (%c)" = IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * IsNull(InvoiceDetail.TaxSuffered,0) /100),0),      
 "Sales Tax Value (%c)" = Isnull(Sum(STPayable + CSTPayable), 0)  
FROM InvoiceDetail, Items    
WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND    
 InvoiceDetail.Product_Code = Items.Product_Code    
GROUP BY Invoicedetail.Serial,InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number,     
 InvoiceDetail.SalePrice, Items.Alias    
  
  
  
  



