CREATE procedure [dbo].[spr_ser_sales_by_manufacturerdetail]
                (@MANUFACTURERID INT,
                 @FROMDATE DATETIME,
                 @TODATE DATETIME)
As

CREATE TABLE #ManufacturerDetailTemp
(code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
ItemName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,TotalQuantity decimal(18,6),
ConversionFactor Decimal(18,6),ReportingUOM Decimal(18,6),TotalValue decimal(18,6))

Insert into #ManufacturerDetailTemp 

	Select InvoiceDetail.Product_Code,"Item Name" = Items.ProductName,
	"Total Quantity" =  SUM(Isnull(Quantity,0)), 
	
	"Conversion Factor" = SUM(ISNULL(Quantity,0)), 
	
	"Reporting UOM" = SUM(ISNULL(Quantity, 0)),
	
	"Total Value (%c)" = sum(Amount) 
	from invoicedetail,Items,InvoiceAbstract
	where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
	and invoicedate between @FROMDATE and @TODATE
	And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)
	And Items.ManufacturerID=@MANUFACTURERID
	and items.product_Code=invoiceDetail.product_Code
	Group by InvoiceDetail.Product_Code,Items.ProductName 


Insert Into #ManufacturerDetailTemp 


	Select ServiceInvoiceDetail.SpareCode,"Item Name" = Items.ProductName,
	"Total Quantity" =  SUM(Isnull(Quantity,0)), 
	
	"Conversion Factor" = SUM(ISNULL(Quantity, 0)), 
	
	"Reporting UOM" = SUM(ISNULL(Quantity, 0)), 
	
	"Total Value (%c)" = Isnull(sum(ServiceInvoiceDetail.NetValue),0)

	from Serviceinvoicedetail,Items,ServiceInvoiceAbstract
	where ServiceinvoiceAbstract.ServiceInvoiceID=ServiceInvoiceDetail.ServiceInvoiceID 
	And Serviceinvoicedate between @FROMDATE and @TODATE
	And Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 
        And Isnull(serviceinvoicedetail.sparecode,'') <> ''
	And ServiceInvoiceAbstract.ServiceInvoiceType in (1)
	And Items.ManufacturerID=@MANUFACTURERID
	And items.product_Code=ServiceinvoiceDetail.SpareCode
	Group by ServiceInvoiceDetail.SpareCode,Items.ProductName 


SELECT  "Item Code" = code,"Item Name" = ItemName,
"Total Quantity" =  CAST(ISNULL(SUM(TotalQuantity), 0) AS VARCHAR)+ ' ' + CAST(UOM.Description AS VARCHAR),

"Conversion Factor" = CAST(CAST(SUM(ISNULL(TotalQuantity, 0) * Items.ConversionFactor) AS Decimal(18,6)) AS VARCHAR)
+ ' ' + CAST(ConversionTable.ConversionUnit AS VARCHAR),

"Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(Code, SUM(ISNULL(TotalQuantity, 0))) As VarChar), 

"Total Value (%c)" = sum(ISNULL(TotalValue,0))
FROM #ManufacturerDetailTemp ,Items,UOM ,ConversionTable 
WHERE Items.UOM *= UOM.UOM
and items.product_code = #ManufacturerDetailTemp.code
AND Items.ConversionUnit *= ConversionTable.ConversionID
GROUP BY Code,ItemName ,UOM.Description ,
ConversionTable.ConversionUnit, Items.ReportingUOM

Drop Table #ManufacturerDetailTemp
