CREATE PROCEDURE spr_list_items_in_invoice_MUOM_pidilite(@INVOICEID int,@UOMDesc nvarchar(30))          
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
"Volume" = (    
   Case When @UOMdesc = 'UOM1' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)        
      When @UOMdesc = 'UOM2' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)        
   Else SUM(InvoiceDetail.Quantity)      
     End),        
 "Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0),           
 "Sale Tax" = CAST(Round(MAX(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2), 2) AS nVARCHAR) + '%',          
 "Tax Suffered" = CAST(ISNULL(MAX(InvoiceDetail.TaxSuffered), 0) AS nVARCHAR) + '%',          
 "Discount" = CAST(SUM(DiscountPercentage) AS nvarchar) + '%',          
 "STCredit" =           
 Round((SUM(InvoiceDetail.TaxCode) / 100.00) *          
 ((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -           
 ((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *          
 (@ADDNDIS / 100.00)) +          
 (((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -           
 ((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *          
 (@TRADEDIS / 100.00))), 2),          
 "Total" = Round(SUM(Amount),2),          
 "Forum Code" = Items.Alias,         
 "Tax Suffered Value " = IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * IsNull(InvoiceDetail.TaxSuffered,0) /100),0),            
 "Sales Tax Value " = Isnull(Sum(STPayable + CSTPayable), 0)        
FROM InvoiceDetail, Items          
WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND          
 InvoiceDetail.Product_Code = Items.Product_Code          
GROUP BY InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number,           
 InvoiceDetail.SalePrice, Items.Alias, UOM1_Conversion,UOM2_Conversion        
  




