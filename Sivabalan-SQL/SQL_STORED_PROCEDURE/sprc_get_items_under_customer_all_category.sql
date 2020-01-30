
Create PROC sprc_get_items_under_customer_all_category
		( @CustomerID nvarchar(15) ,
		  @BeatId int,	
		  @FromDate Datetime,
  		  @ToDate Datetime
		)
AS
DECLARE @InvoiceId int
	create table #sales ( Product_Code nvarchar(15) , ProductName nvarchar(225) , SalesValue decimal(18,2),
				SalesQtyUOM decimal(18,2) , SalesQtyCF decimal(18,2) , SalesQtyRU decimal(18,2) ) 
insert into #sales
select  "Product_code" = Items.Product_Code , 
	"ProductName" = Items.ProductName,
	"SalesValue" = 	isnull(sum(InvoiceDetail.Amount),0) ,
	"SalesQty (UOM)" = cast(isnull(sum(InvoiceDetail.Quantity),0) as decimal (18,2)),
	"StockQty (CF)" = cast (ISNULL(SUM(InvoiceDetail.Quantity * Items.ConversionFactor),0) as decimal (18,2)) ,
	"StockQty (RU)" = cast ( SUM(InvoiceDetail.Quantity / (case ISNULL(Items.ReportingUnit, 0) 	
			when 0 then 1 else ISNULL(Items.ReportingUnit, 0) end)) as decimal(18,2) ) 
from 	InvoiceDetail, Items , InvoiceAbstract
where 	InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceID and
	InvoiceAbstract.CustomerID = @CustomerID and
	InvoiceAbstract.BeatID = @BeatID and
	InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and
	Items.Product_Code = InvoiceDetail.Product_Code	 and
	InvoiceAbstract.InvoiceType  in (1,3) and
	(InvoiceAbstract.Status & 128) = 0
group by 
	Items.Product_Code, 	
	Items.ProductName 
insert into #sales 
select  
	"Product_code" = Items.Product_Code , 
	"ProductName" = Items.ProductName,
	"SalesValue" = 	0 - isnull(sum(InvoiceDetail.Amount),0) ,
	"SalesQty (UOM)" = cast( 0 - isnull(sum(InvoiceDetail.Quantity),0) as decimal (18,2)),
	"StockQty (CF)" = cast (0 - ISNULL(SUM(InvoiceDetail.Quantity * Items.ConversionFactor),0) as decimal (18,2)) ,
	"StockQty (RU)" = cast ( 0 - (SUM(InvoiceDetail.Quantity / (case ISNULL(Items.ReportingUnit, 0) 	
		when 0 then 1 else ISNULL(Items.ReportingUnit, 0) end)) ) as decimal(18,2)  )
from 	InvoiceDetail, Items , InvoiceAbstract
where 	InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceID and
	InvoiceAbstract.CustomerID = @CustomerID and
	InvoiceAbstract.BeatID = @BeatID and
	InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and
	Items.Product_Code = InvoiceDetail.Product_Code	 and
	InvoiceAbstract.InvoiceType  = 4 and
	(InvoiceAbstract.Status & 128) = 0
group by Items.Product_Code, Items.ProductName 

select  "Product_code" = #Sales.Product_Code , 
	"ProductName" = #Sales.ProductName,
	"SalesValue" = isnull(sum(#Sales.SalesValue),0),
	"SalesQtyUOM" = cast(isnull(sum(#Sales.SalesQtyUOM),0) as nvarchar) + ' ' + (SELECT Description From UOM WHERE UOM = Items.UOM) ,
	"SalesQtyCF" = cast(isnull(sum(#Sales.SalesQtyCF),0 ) as nvarchar)  + ' ' + (SELECT ConversionUnit From ConversionTable WHERE ConversionID = Items.ConversionUnit) ,
	"SalesQtyRU" = cast(isnull(sum(#Sales.SalesQtyRU),0) as nvarchar) + ' ' + (SELECT Description From UOM WHERE UOM = Items.ReportingUOM)
from 	#sales ,  items
where 	#sales.product_code  collate SQL_Latin1_General_Cp1_CI_AS =  items.product_code
group by 
	#sales.Product_Code, 
	#sales.ProductName ,
	Items.UOM, 
	Items.ReportingUOM,  
	Items.ConversionUnit 
drop table #sales

