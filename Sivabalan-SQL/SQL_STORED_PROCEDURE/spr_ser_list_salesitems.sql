CREATE procedure [dbo].[spr_ser_list_salesitems](@Manufacturer varchar(2550), @Product_Code varchar(2550), @fromdate datetime, @todate datetime ) 
as

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Create table #tmpMfr(Manufacturer_Name varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
create table #tmpProd(product_code varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


if @Manufacturer='%'   
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer  
Else  
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufacturer,@Delimeter)

if @Product_Code='%'
   insert into #tmpProd select product_code from items
else
   insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@Product_Code,@Delimeter)

create table #temp(Product_Code varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,Price Decimal(18,6),
Quantity Decimal(18,6),CountInvoice int, SaleID int) 
insert into #temp (product_code,price,quantity,countinvoice, SaleID)
select a.product_code, 
sum(Amount), 
sum(isnull(a.quantity,0)), 1, a.SaleID from 
invoicedetail a,invoiceabstract b, items, manufacturer
where a.invoiceid = b.invoiceid 
and a.product_code = items.product_code 
and items.manufacturerid = manufacturer.manufacturerid
and b.invoicedate between @Fromdate and @Todate
and b.invoicetype not in(4,5,6)  and (status & 128 ) = 0 
and a.product_code in(select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and Manufacturer.Manufacturer_Name in (select Manufacturer_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr)
group by a.product_code,a.invoiceid, a.SaleID

insert into #temp(product_code,price,quantity,countinvoice, SaleID)
select a.sparecode, 
sum(a.Netvalue), 
sum(isnull(a.quantity,0)), 1, a.SaleID from 
Serviceinvoicedetail a,Serviceinvoiceabstract b, items, manufacturer
where a.Serviceinvoiceid = b.Serviceinvoiceid 
and a.Sparecode = items.product_code
and items.manufacturerid = manufacturer.manufacturerid
and b.Serviceinvoicedate between @Fromdate and @Todate
and b.Serviceinvoicetype in(1)
and Isnull(status,0) & 192  = 0 
and isnull(a.sparecode,'') <> '' 
and a.sparecode in(select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and Manufacturer.Manufacturer_Name in (select Manufacturer_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr)
group by a.sparecode,a.serviceinvoiceid, a.SaleID

drop table #tmpMfr
drop table #tmpProd

select  "Items" = #temp.product_code , 
"Item Code" = #temp.product_code, 
"Item Name" = productname , 
"First Sale (%c)" = sum(Price), 
"Second Sale (%c)" = NULL, 
"Other Sales (%c)" = NULL, 
"Total Quantity" = CAST(sum(quantity) AS VARCHAR)
+ ' ' + CAST(UOM.Description AS VARCHAR), 
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS DECIMAL(18,6)) AS VARCHAR)
+ ' ' + CAST(ConversionTable.ConversionUnit AS VARCHAR),
"Reporting UOM" = Cast(dbo.sp_ser_Get_ReportingQty(SUM(ISNULL(#temp.Quantity, 0)), Items.ReportingUnit) As VarChar) 
  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS VARCHAR),
"NO of Invoices" = count(#temp.product_code) 
from #temp, items, UOM, ConversionTable
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code 
and #temp.SaleID = 1 
AND Items.UOM *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
group by #temp.product_code,productname, #temp.SaleID, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description, Items.ReportingUnit

UNION ALL

select  "Items" = #temp.product_code , "Item Code" = #temp.product_code, "Item Name" = productname , 
"First Sale (%c)" = NULL, 
"Second Sale (%c)" = sum(Price), 
"Other Sales (%c)" = NULL, 
"Total Quantity" = CAST(sum(quantity) AS VARCHAR)
+ ' ' + CAST(UOM.Description AS VARCHAR), 
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS DECIMAL(18,6)) AS VARCHAR)
+ ' ' + CAST(ConversionTable.ConversionUnit AS VARCHAR),
"Reporting UOM" = Cast((dbo.sp_ser_Get_ReportingQty(Sum(ISNULL(#temp.Quantity, 0)), Items.ReportingUnit)) As VarChar) 
  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS VARCHAR),
"NO of Invoices" = count(#temp.product_code) 
from #temp, items, UOM, ConversionTable
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code 
and #temp.SaleID = 2 
AND Items.UOM *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
group by #temp.product_code,productname, #temp.SaleID, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description, Items.ReportingUnit

UNION ALL

select  "Items" = #temp.product_code , "Item Code" = #temp.product_code, 
"Item Name" = productname , 
"First Sale (%c)" = NULL, 
"Second Sale (%c)" = NULL, 
"Other Sales (%c)" = sum(Price), 
"Total Quantity" = CAST(sum(quantity) AS VARCHAR)
+ ' ' + CAST(UOM.Description AS VARCHAR), 
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS DECIMAL(18,6)) AS VARCHAR)
+ ' ' + CAST(ConversionTable.ConversionUnit AS VARCHAR),
"Reporting UOM" = Cast((dbo.sp_ser_Get_ReportingQty(Sum(ISNULL(#temp.Quantity, 0)), Items.ReportingUnit)) As VarChar) 
  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS VARCHAR),
"NO of Invoices" = count(#temp.product_code) 
from #temp, items, UOM, ConversionTable
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code 
and ISNULL(#temp.SaleID, 0) = 0 
AND Items.UOM *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
group by #temp.product_code,productname, #temp.SaleID, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description, Items.ReportingUnit
drop table #temp
