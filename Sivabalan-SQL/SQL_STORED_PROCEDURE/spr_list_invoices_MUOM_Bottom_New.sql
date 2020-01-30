--Exec spr_list_invoices_MUOM_Bottom_New1 416224
CREATE procedure [dbo].[spr_list_invoices_MUOM_Bottom_New](@INVOICEID int)  
AS  
DECLARE @ADDNDIS AS Decimal(18,6)  
DECLARE @TRADEDIS AS Decimal(18,6)  

DECLARE @CGST AS INT = (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'CGST')
DECLARE @SGST AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'SGST')
DECLARE @IGST AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'IGST')
DECLARE @CESS AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'CESS')
DECLARE @ADDLCESS AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'ADDL CESS')

SELECT @ADDNDIS = isnull(AdditionalDiscount,0), @TRADEDIS = isnull(DiscountPercentage,0) FROM InvoiceAbstract  WHERE InvoiceID = @INVOICEID  

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
"RPT Qty"
 =  SUM(InvoiceDetail.Quantity / Items.ReportingUnit),  
"Gross Value"=(SUM(InvoiceDetail.SalePrice * Items.ReportingUnit))*(InvoiceDetail.Quantity / Items.ReportingUnit),  
--"Discount %" = CAST(SUM(DiscountPercentage) AS nvarchar) + '%',  
"Discount Value" = SUM(DiscountValue),  
--"Sale Tax" = CAST(Round(MAX(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2), 2) AS nVARCHAR) + '%',  
"Sales Tax Value" = Isnull(Sum(STPayable + CSTPayable), 0),  
"STCredit" =  Round((SUM(InvoiceDetail.TaxCode) / 100.00) *  
((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) - ((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *  
(@ADDNDIS / 100.00)) + (((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -  
((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *  (@TRADEDIS / 100.00))), 2),"Total" = Round(SUM(Amount),2)  
,"HSNNumber" = MAX(InvoiceDetail.HSNNumber)
,"CGST%"	= dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@CGST)
,"CGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@CGST) > 0 then dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@CGST)/100 else 0 end)  * ((SUM(InvoiceDetail.SalePrice * Items.ReportingUnit))*(InvoiceDetail.Quantity / Items
.ReportingUnit) - SUM(InvoiceDetail.DiscountValue))
,"SGST%"	= dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@SGST)
,"SGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@SGST) > 0 then dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@SGST)/100 else 0 end)  * ((SUM(InvoiceDetail.SalePrice * Items.ReportingUnit))*(InvoiceDetail.Quantity / Items
.ReportingUnit) - SUM(InvoiceDetail.DiscountValue))
,"IGST%"	= dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@IGST)
,"IGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@IGST) > 0 then dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@IGST)/100 else 0 end)  * ((SUM(InvoiceDetail.SalePrice * Items.ReportingUnit))*(InvoiceDetail.Quantity / Items
.ReportingUnit) - SUM(InvoiceDetail.DiscountValue))
,"CESS%"	= dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@CESS)
,"CESS"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@CESS) > 0 then dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@CESS)/100 else 0 end)  * ((SUM(InvoiceDetail.SalePrice * Items.ReportingUnit))*(InvoiceDetail.Quantity / Items
.ReportingUnit) - SUM(InvoiceDetail.DiscountValue))
,"ADDL CESS"= dbo.[fn_GetTaxValueByComponent](Max(InvoiceDetail.TaxID),@ADDLCESS)  * (InvoiceDetail.Quantity)
--,"ReportingUnit" = Items.ReportingUnit
FROM InvoiceDetail with (nolock), 
Items  with (nolock),
Brand  with (nolock), 
UOM with (nolock)  
WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND  
InvoiceDetail.Product_Code = Items.Product_Code  
AND Items.BrandID = Brand.BrandID  AND  
Items.ReportingUOM = UOM.UOM  
GROUP BY InvoiceDetail.Product_Code, Items.ProductName,Items.Description, 
Brand.BrandName,InvoiceDetail.SalePrice, InvoiceDetail.Quantity,Items.ReportingUnit,UOM.Description
