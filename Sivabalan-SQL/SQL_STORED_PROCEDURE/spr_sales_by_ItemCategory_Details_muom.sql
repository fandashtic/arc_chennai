CREATE procedure [dbo].[spr_sales_by_ItemCategory_Details_muom]
                (@CATID INT,
				 @UOM nvarchar(100),
                 @FROMDATE DATETIME,
                 @TODATE DATETIME)
As
Select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,
"Item Name" = Items.ProductName,
"Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),
"Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),
"Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),
"Total Quantity" = ISNULL((Case @UOM When 'Sales UOM' Then Sum(Quantity)
                                        When 'UOM1' Then dbo.sp_get_ReportingQty(Sum(Quantity), UOM1_Conversion)
										When 'UOM2' Then dbo.sp_get_ReportingQty(Sum(Quantity), UOM2_Conversion) End), 0),
"Conversion Factor" = CAST(CAST(ISNULL(sum(Quantity), 0) * Items.ConversionFactor  AS Decimal(18,6)) AS nvarchar)
+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
"Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(InvoiceDetail.Product_Code, SUM(IsNull(Quantity, 0))) As nvarchar) 
+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
-- "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)
-- + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
"Total Value (Rs)" = sum(Amount) 
from invoicedetail,Items,InvoiceAbstract, UOM, ConversionTable
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)
And Items.Categoryid=@CatID 
and items.product_Code=invoiceDetail.product_Code
AND Items.UOM *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
Group by InvoiceDetail.Product_Code,Items.ProductName, Items.ConversionFactor,
Items.ReportingUnit, Items.ReportingUOM, ConversionTable.ConversionUnit,
UOM.Description, UOM1_Conversion, UOM2_Conversion
