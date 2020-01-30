CREATE procedure [dbo].[spr_list_salesitems](@Manufacturer nvarchar(2550), @Product_Code nvarchar(2550), @fromdate datetime, @todate datetime ) 
as

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Create table #tmpMfr(Manufacturer_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

if @Manufacturer='%'   
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer  
Else  
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufacturer,@Delimeter)

if @Product_Code='%'
   insert into #tmpProd select product_code from items
else
   insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@Product_Code,@Delimeter)


create table #temp(Product_Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,Price Decimal(18,6),Quantity Decimal(18,6),CountInvoice int, SaleID int) 
insert into #temp(product_code,price,quantity,countinvoice, SaleID)
select a.product_code, sum(Amount), sum(isnull(a.quantity,0)), 1, a.SaleID from 
invoicedetail a,invoiceabstract b, items, manufacturer
where a.invoiceid = b.invoiceid 
and a.product_code = items.product_code 
and items.manufacturerid = manufacturer.manufacturerid
and b.invoicedate between @fromdate and @todate
and b.invoicetype not in(4,5,6)  and (status & 128 ) = 0 and a.product_code in(select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and Manufacturer.Manufacturer_Name in (select Manufacturer_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr)
group by a.product_code,a.invoiceid, a.SaleID

drop table #tmpMfr
drop table #tmpProd

Select  "Items" = #temp.product_code + ':' + Cast('1' As Nvarchar) , "Item Code" = #temp.product_code, "Item Name" = productname , 
"First Sale (%c)" = sum(Price), 
"Second Sale (%c)" = NULL, "Other Sales (%c)" = NULL, 
"Total Quantity" = CAST(sum(quantity) AS nvarchar)
+ ' ' + CAST(UOM.Description AS nvarchar), 
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS DECIMAL(18,6)) AS nvarchar)
+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
"Reporting UOM" = Cast((dbo.sp_Get_ReportingQty(Sum(ISNULL(#temp.Quantity, 0)), Items.ReportingUnit)) As nvarchar) 
  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
"NO of Invoices" = count(#temp.product_code) 
from #temp, items, UOM, ConversionTable
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code 
and #temp.SaleID = 1 
AND Items.UOM *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
group by #temp.product_code,productname, #temp.SaleID, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description, Items.ReportingUnit

UNION ALL

select  "Items" = #temp.product_code + ':' + Cast('2' As Nvarchar), "Item Code" = #temp.product_code, "Item Name" = productname , 
"First Sale (%c)" = NULL, 
"Second Sale (%c)" = sum(Price), 
"Other Sales (%c)" = NULL, 
"Total Quantity" = CAST(sum(quantity) AS nvarchar)
+ ' ' + CAST(UOM.Description AS nvarchar), 
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS DECIMAL(18,6)) AS nvarchar)
+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
"Reporting UOM" = Cast((dbo.sp_Get_ReportingQty(Sum(ISNULL(#temp.Quantity, 0)), Items.ReportingUnit)) As nvarchar) 
  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
"NO of Invoices" = count(#temp.product_code) 
from #temp, items, UOM, ConversionTable
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code 
and #temp.SaleID = 2 
AND Items.UOM *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
group by #temp.product_code,productname, #temp.SaleID, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description, Items.ReportingUnit

UNION ALL

select  "Items" = #temp.product_code + ':' + Cast('0' As Nvarchar), "Item Code" = #temp.product_code, 
"Item Name" = productname , 
"First Sale (%c)" = NULL, 
"Second Sale (%c)" = NULL, 
"Other Sales (%c)" = sum(Price), 
"Total Quantity" = CAST(sum(quantity) AS nvarchar)
+ ' ' + CAST(UOM.Description AS nvarchar), 
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS DECIMAL(18,6)) AS nvarchar)
+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
"Reporting UOM" = Cast((dbo.sp_Get_ReportingQty(Sum(ISNULL(#temp.Quantity, 0)), Items.ReportingUnit)) As nvarchar) 
  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
"NO of Invoices" = count(#temp.product_code) 
from #temp, items, UOM, ConversionTable
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code 
and ISNULL(#temp.SaleID, 0) = 0 
AND Items.UOM *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
group by #temp.product_code,productname, #temp.SaleID, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description, Items.ReportingUnit
drop table #temp
