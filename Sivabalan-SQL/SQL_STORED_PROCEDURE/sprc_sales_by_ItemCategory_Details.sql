
-------------------------------------------------------------------------------------------------

Create PROCedure sprc_sales_by_ItemCategory_Details
                (@CATID INT,
                 @FROMDATE DATETIME,
                 @TODATE DATETIME)
as
create table #temp ( Product_Code nvarchar(15) , ProductName nvarchar(225) , SalesValue decimal(18,2),
			SalesQtyUOM decimal(18,2) , SalesQtyCF decimal(18,2) , SalesQtyRU decimal(18,2) ) 
insert into #temp
Select 
	InvoiceDetail.Product_Code,
	"Item Name" = Items.ProductName,
	"SalesValue" = 	isnull(sum(InvoiceDetail.Amount),0) ,
	"SalesQty (UOM)" = cast(isnull(sum(InvoiceDetail.Quantity),0) as decimal (18,2)),
	"StockQty (CF)" = cast (ISNULL(SUM(InvoiceDetail.Quantity * Items.ConversionFactor),0) as decimal (18,2)) ,
	"StockQty (RU)" = cast ( SUM(InvoiceDetail.Quantity / (case ISNULL(Items.ReportingUnit, 0) 	
		when 0 then 1 else ISNULL(Items.ReportingUnit, 0) end)) as decimal(18,2) ) 
from 
	invoicedetail,Items,InvoiceAbstract 
where 
	invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and 	invoicedate between @FROMDATE and @TODATE
And 	InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,3)
And 	Items.Categoryid=@CatID 
and 	items.product_Code=invoiceDetail.product_Code
Group by 
	InvoiceDetail.Product_Code,
	Items.ProductName
insert into #temp
Select 
	InvoiceDetail.Product_Code,
	"Item Name" = Items.ProductName,

	"SalesValue" = 	0 - isnull(sum(InvoiceDetail.Amount),0) ,
	"SalesQty (UOM)" = cast( 0 - isnull(sum(InvoiceDetail.Quantity),0) as decimal (18,2)),
	"StockQty (CF)" = cast (0 - ISNULL(SUM(InvoiceDetail.Quantity * Items.ConversionFactor),0) as decimal (18,2)) ,
	"StockQty (RU)" = cast ( 0 - (SUM(InvoiceDetail.Quantity / (case ISNULL(Items.ReportingUnit, 0) 	
		when 0 then 1 else ISNULL(Items.ReportingUnit, 0) end)) ) as decimal(18,2)  )

from 
	invoicedetail,Items,InvoiceAbstract 
where 
	invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and 	invoicedate between @FROMDATE and @TODATE
And 	InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType = 4
And 	Items.Categoryid=@CatID 
and 	items.product_Code=invoiceDetail.product_Code

Group by 
	InvoiceDetail.Product_Code,
	Items.ProductName

select  "Product_Code" = #temp.Product_Code , 
	"ProductName" = #temp.ProductName,
	"SalesValue" = isnull(sum(#temp.SalesValue),0),
	"SalesQtyUOM" = cast(isnull(sum(#temp.SalesQtyUOM),0) as nvarchar) + ' ' + (SELECT Description From UOM WHERE UOM = Items.UOM) ,
	"SalesQtyCF" = cast(isnull(sum(#temp.SalesQtyCF),0 ) as nvarchar)  + ' ' + (SELECT ConversionUnit From ConversionTable WHERE ConversionID = Items.ConversionUnit) ,
	"SalesQtyRU" = cast(isnull(sum(#temp.SalesQtyRU),0) as nvarchar) + ' ' + (SELECT Description From UOM WHERE UOM = Items.ReportingUOM)
from 	#temp ,  items
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS  =  items.product_code
group by 
	#temp.Product_Code, 
	#temp.ProductName,
	Items.UOM, 
	Items.ReportingUOM,  
	Items.ConversionUnit 

drop table #temp

