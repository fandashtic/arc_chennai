CREATE procedure [dbo].[spr_list_salesitems_muom_ARU_Chevron](@Manufacturer nvarchar(2550), 
                                     @Product_Code nvarchar(2550), 
									 @UOM nvarchar(100),
                                     @fromdate datetime, 
                                     @todate datetime ) 
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
and b.invoicetype <> 4 and (status & 128 ) = 0 and a.product_code in(select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and Manufacturer.Manufacturer_Name in (select Manufacturer_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr)
group by a.product_code,a.invoiceid, a.SaleID

drop table #tmpMfr
drop table #tmpProd

select  "Items" = #temp.product_code , "Item Code" = #temp.product_code, "Item Name" = productname , 
"First Sale (%c)" = sum(Price), 
"Second Sale (%c)" = NULL, "Other Sales (%c)" = NULL, 
"Total Quantity" = CAST((Case @UOM When 'Sales UOM' Then sum(quantity) 
                   When 'UOM1' Then dbo.sp_Get_ReportingQty(sum(quantity), UOM1_Conversion)
                   
			 	   When 'UOM2' Then dbo.sp_Get_ReportingQty(sum(quantity), UOM2_Conversion)
                   End) AS nvarchar)
+ ' ' + CAST(UOM.Description AS nvarchar), 
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS DECIMAL(18,6)) AS nvarchar)
+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
"Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(#temp.product_code, SUM(ISNULL(Quantity, 0))) As nvarchar) 
--   SubString(
--    CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1, 
--    CharIndex('.', CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
--   + '.' + 
--   CAST(Sum(Cast(ISNULL(QUANTITY, 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)
  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
-- "Reporting UOM" = CAST(CAST(SUM(Quantity / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS DECIMAL(18,6)) AS nvarchar)
-- + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
"NO of Invoices" = count(#temp.product_code) 
from #temp, items, UOM, ConversionTable
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code 
and #temp.SaleID = 1 
AND (Case @UOM When 'Sales UOM' Then Items.UOM When 'UOM1' Then Items.UOM1 
               When 'UOM2' Then Items.UOM2 End) *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
group by #temp.product_code,productname, #temp.SaleID, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description, 
UOM1_Conversion, UOM2_Conversion

UNION ALL

select  "Items" = #temp.product_code , "Item Code" = #temp.product_code, "Item Name" = productname , 
"First Sale (%c)" = NULL, 
"Second Sale (%c)" = sum(Price), 
"Other Sales (%c)" = NULL, 
"Total Quantity" = CAST((Case @UOM When 'Sales UOM' Then sum(quantity) 
                   When 'UOM1' Then dbo.sp_Get_ReportingQty(sum(quantity), UOM1_Conversion)
                   
			 	   When 'UOM2' Then dbo.sp_Get_ReportingQty(sum(quantity), UOM2_Conversion)
                   End) AS nvarchar)
+ ' ' + CAST(UOM.Description AS nvarchar), 
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS DECIMAL(18,6)) AS nvarchar)
+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
"Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(#temp.product_code, SUM(ISNULL(Quantity, 0))) As nvarchar) 
--   SubString(
--    CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1, 
--    CharIndex('.', CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
--   + '.' + 
--   CAST(Sum(Cast(ISNULL(QUANTITY, 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)
  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),

"NO of Invoices" = count(#temp.product_code) 
from #temp, items, UOM, ConversionTable
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code 
and #temp.SaleID = 2 
AND (Case @UOM When 'Sales UOM' Then Items.UOM When 'UOM1' Then Items.UOM1 
               When 'UOM2' Then Items.UOM2 End) *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
group by #temp.product_code,productname, #temp.SaleID, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description,
UOM1_Conversion, UOM2_Conversion

UNION ALL

select  "Items" = #temp.product_code , "Item Code" = #temp.product_code, 
"Item Name" = productname , 
"First Sale (%c)" = NULL, 
"Second Sale (%c)" = NULL, 
"Other Sales (%c)" = sum(Price), 
"Total Quantity" = CAST((Case @UOM When 'Sales UOM' Then sum(quantity) 
                   When 'UOM1' Then dbo.sp_Get_ReportingQty(sum(quantity), UOM1_Conversion)
                   
			 	   When 'UOM2' Then dbo.sp_Get_ReportingQty(sum(quantity), UOM2_Conversion)
                   End) AS nvarchar)
+ ' ' + CAST(UOM.Description AS nvarchar), 
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS DECIMAL(18,6)) AS nvarchar)
+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
"Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(#temp.product_code, SUM(ISNULL(Quantity, 0))) As nvarchar) 
--  "Reporting UOM" = 
--   SubString(
--    CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1, 
--    CharIndex('.', CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
--   + '.' + 
--   CAST(Sum(Cast(ISNULL(QUANTITY, 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)
  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),

"NO of Invoices" = count(#temp.product_code) 
from #temp, items, UOM, ConversionTable
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code 
and ISNULL(#temp.SaleID, 0) = 0 
AND (Case @UOM When 'Sales UOM' Then Items.UOM When 'UOM1' Then Items.UOM1 
               When 'UOM2' Then Items.UOM2 End) *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
group by #temp.product_code,productname, #temp.SaleID, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description,
UOM1_Conversion, UOM2_Conversion

drop table #temp
