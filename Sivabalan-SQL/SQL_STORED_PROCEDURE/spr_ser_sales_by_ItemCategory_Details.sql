CREATE procedure [dbo].[spr_ser_sales_by_ItemCategory_Details]
                (@CATID INT,
                 @FROMDATE DATETIME,
                 @TODATE DATETIME)
As

CREATE Table #ItemCategoryTemp(Code nvarchar(15)collate SQL_Latin1_General_Cp1_CI_AS,Itemcode nvarchar(15) collate SQL_Latin1_General_Cp1_CI_AS,
ItemName nvarchar(255) collate SQL_Latin1_General_Cp1_CI_AS,Property1 varchar(255) collate SQL_Latin1_General_Cp1_CI_AS,Property2 nvarchar(255)collate SQL_Latin1_General_Cp1_CI_AS,
Property3 nvarchar(255)collate SQL_Latin1_General_Cp1_CI_AS, TotalQuantity decimal(18,6),
ConversionQty decimal(18,6),ReportingQty decimal(18,6),TotalValue decimal(18,6))

Insert into #ItemCategoryTemp

Select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,
"Item Name" = Items.ProductName,
"Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),
"Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),
"Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),
"Total Quantity" = ISNULL(sum(Quantity), 0),
"Conversion Factor" = ISNULL(sum(Quantity), 0),

"Reporting UOM" = Isnull(sum(Quantity),0),

"Total Value (%c)" = sum(Amount) 
from invoicedetail,Items,InvoiceAbstract 
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)
And Items.Categoryid=@CatID 
and items.product_Code=invoiceDetail.product_Code
Group by InvoiceDetail.Product_Code,Items.ProductName


Insert into #ItemCategoryTemp

Select ServiceInvoiceDetail.SpareCode, "Item Code" = ServiceInvoiceDetail.SpareCode,
"Item Name" = Items.ProductName,
"Property1" = dbo.GetProperty(ServiceinvoiceDetail.spareCode, 1),
"Property2" = dbo.GetProperty(ServiceinvoiceDetail.spareCode, 2),
"Property3" = dbo.GetProperty(ServiceinvoiceDetail.spareCode, 3),
"Total Quantity" = ISNULL(sum(Quantity), 0),

"Conversion Factor" =ISNULL(sum(Quantity), 0), 

"Reporting UOM" = SUM(IsNull(Quantity, 0)),

"Total Value (%c)" = sum(isnull(Serviceinvoicedetail.netvalue,0)) 

from serviceinvoicedetail,Items,serviceInvoiceAbstract
where serviceinvoiceAbstract.serviceInvoiceID=serviceInvoiceDetail.serviceInvoiceID 
And serviceinvoicedate between @FROMDATE and @TODATE
And Isnull(serviceInvoiceAbstract.Status,0)&192 =0
And ServiceInvoiceAbstract.serviceInvoiceType in (1)
And Items.Categoryid=@CatID 
And items.product_Code=serviceinvoiceDetail.spareCode
And isnull(serviceinvoicedetail.sparecode,'') <> ''
Group by serviceInvoiceDetail.spareCode,Items.ProductName 


SELECT  "Code" = code,"Item Code" = ItemCode, "Item Name" = ItemName,
"Property1" = dbo.GetProperty(Code, 1),
"Property2" = dbo.GetProperty(Code, 2),
"Property3" = dbo.GetProperty(Code, 3),

"Total Quantity" =  SUM(TotalQuantity),

"Conversion Factor" = CAST(CAST(SUM(ISNULL(ConversionQty, 0) * Items.ConversionFactor) AS Decimal(18,6)) AS VARCHAR)

+ ' ' + CAST(ConversionTable.ConversionUnit AS VARCHAR),

"Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(Code, SUM(IsNull(ReportingQty, 0))) As VarChar)   
+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS VARCHAR),  


"Total Value (%c)" = sum(ISNULL(TotalValue,0))

FROM #ItemCategoryTemp ,Items,UOM ,ConversionTable 
WHERE Items.UOM *= UOM.UOM
and items.product_code in(select code SQL_Latin1_General_Cp1_CI_AS from #ItemCategoryTemp)
AND Items.ConversionUnit *= ConversionTable.ConversionID
And Items.Categoryid=@CatID 
GROUP BY #ItemCategoryTemp.Code,#ItemCategoryTemp.itemCode,ItemName ,UOM.Description ,
ConversionTable.ConversionUnit, Items.ReportingUOM

Drop Table #ItemCategoryTemp
