CREATE procedure [dbo].[spr_sales_by_manufacturerdetail_pidilite]
                (@MANUFACTURERID INT,
                 @FROMDATE DATETIME,
                 @TODATE DATETIME,
                 @ItemCode nVarChar(2550),
                 @ItemName nVarChar(255))
As
Select InvoiceDetail.Product_Code,"Item Name" = Items.ProductName,
"Total Quantity" =  CAST(ISNULL(SUM(Quantity), 0) AS nVARCHAR)
+ ' ' + CAST(UOM.Description AS nVARCHAR),
"Conversion Factor" = Sum(Quantity * IsNull(ConversionFactor, 0)),  
-- CAST(CAST(SUM(ISNULL(Quantity, 0) * Items.ConversionFactor) AS Decimal(18,6)) AS nVARCHAR)
-- + ' ' + CAST(ConversionTable.ConversionUnit AS nVARCHAR),
"Reporting UOM" = Sum(Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),  
-- Cast(dbo.sp_Get_ReportingUOMQty(InvoiceDetail.Product_Code, SUM(ISNULL(Quantity, 0))) As nVarChar) 
-- --CAST(CAST(SUM(ISNULL(Quantity, 0) / (case Items.ReportingUnit when 0 then 1 else Items.ReportingUnit end)) AS Decimal(18,6)) AS VARCHAR)
-- + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nVARCHAR),
"Total Value (%c)" = sum(Amount) 
from invoicedetail,Items,InvoiceAbstract, UOM, ConversionTable
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)
And Items.ManufacturerID=@MANUFACTURERID
and items.product_Code=invoiceDetail.product_Code
And items.product_Code Like  @ItemCode
AND Items.UOM *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
Group by InvoiceDetail.Product_Code,Items.ProductName, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description
