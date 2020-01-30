CREATE procedure [dbo].[spr_list_invoices_MUOM_Bottom](@INVOICEID int)  
AS  
DECLARE @ADDNDIS AS Decimal(18,6)  
DECLARE @TRADEDIS AS Decimal(18,6)  
SELECT @ADDNDIS = isnull(AdditionalDiscount,0), @TRADEDIS = isnull(DiscountPercentage,0) FROM InvoiceAbstract  

WHERE InvoiceID = @INVOICEID  
SELECT  InvoiceDetail.Product_Code,  
"Item Code" = InvoiceDetail.Product_Code,  
"Item Name" = Items.ProductName,  
"Family" = Items.Description,  
"Category" = Brand.BrandName,  
"UOM" = UOM.Description,  
--"Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0),  
"Sale Price" = InvoiceDetail.SalePrice * Items.ReportingUnit,  
--"Quantity" = SUM(InvoiceDetail.Quantity),  
"Base Qty" =  SUM(InvoiceDetail.Quantity),  
"RPT Qty" =  SUM(InvoiceDetail.Quantity / Items.ReportingUnit),  
"Gross Value"=(SUM(InvoiceDetail.SalePrice * Items.ReportingUnit))*(InvoiceDetail.Quantity / Items.ReportingUnit),  
--"Discount %" = CAST(SUM(DiscountPercentage) AS nvarchar) + '%',  
"Discount Value" = SUM(DiscountValue),  
--"Sale Tax" = CAST(Round(MAX(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2), 2) AS nVARCHAR) + '%',  
"Sales Tax Value" = Isnull(Sum(STPayable + CSTPayable), 0),  
"STCredit" =  
Round((SUM(InvoiceDetail.TaxCode) / 100.00) *  
((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) - ((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *  
(@ADDNDIS / 100.00)) + (((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -  
((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *  (@TRADEDIS / 100.00))), 2),"Total" = Round(SUM(Amount),2)  
FROM InvoiceDetail, Items ,Brand , UOM  
WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND  
InvoiceDetail.Product_Code = Items.Product_Code  
AND Items.BrandID = Brand.BrandID  AND  
Items.ReportingUOM = UOM.UOM  
GROUP BY InvoiceDetail.Product_Code, Items.ProductName,Items.Description, Brand.BrandName,  
InvoiceDetail.SalePrice, InvoiceDetail.Quantity,Items.ReportingUnit , UOM.Description
