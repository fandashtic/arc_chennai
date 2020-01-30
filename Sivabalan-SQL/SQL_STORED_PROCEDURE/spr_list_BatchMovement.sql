CREATE procedure [dbo].[spr_list_BatchMovement](@Manufacturer nvarchar(2550),         
        @Product_Code nvarchar(2550),         
        @BatchNo nVarchar(2550),        
        @fromdate datetime,         
        @todate datetime )         
as        

Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create table #tmpItem(ProductCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create table #tmpBatch(BatchNo nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    

if @Manufacturer='%'
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer    
Else    
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufacturer,@Delimeter)    
    
if @Product_Code='%'    
   Insert into #tmpItem select product_code from items    
Else    
   Insert into #tmpItem select * from dbo.sp_SplitIn2Rows(@Product_Code,@Delimeter)    
  
if @BatchNo='%'    
   Insert into #tmpBatch select Batch_Number from Batch_Products    
Else    
   Insert into #tmpBatch select * from dbo.sp_SplitIn2Rows(@BatchNo,@Delimeter)    
  
create table #temp(Product_Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,Price Decimal(18,6),Quantity Decimal(18,6),CountInvoice int, SaleID int)         
insert into #temp(product_code,price,quantity,countinvoice, SaleID)        
select a.product_code, sum(Amount), sum(isnull(a.quantity,0)), 1, a.SaleID from         
invoicedetail a,invoiceabstract b, items, manufacturer        
where a.invoiceid = b.invoiceid         
and a.product_code = items.product_code         
and items.manufacturerid = manufacturer.manufacturerid        
and b.invoicedate between @fromdate and @todate        
and b.invoicetype not in(4,5,6)  and (status & 128 ) = 0 and a.product_code In   
(Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem)        
and Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr)        
and a.Batch_Number In (Select BatchNo COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBatch)  
group by a.product_code,a.invoiceid, a.SaleID        
        
select  "Items" = #temp.product_code + ':' + Cast('1' AS nvarchar) , "Item Code" = #temp.product_code, "Item Name" = productname ,         
"First Sale (%c)" = sum(Price),         
"Second Sale (%c)" = NULL, "Other Sales (%c)" = NULL,         
"Total Quantity" = CAST(sum(quantity) AS nVARCHAR)        
+ ' ' + CAST(UOM.Description AS nVARCHAR),         
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS Decimal(18,6)) AS nVARCHAR)        
+ ' ' + CAST(ConversionTable.ConversionUnit AS nVARCHAR),        
"Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(#temp.product_code, SUM(IsNull(Quantity, 0))) As nVarChar)   
+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nVARCHAR),  
-- "Reporting UOM" = CAST(CAST(SUM(Quantity / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nVARCHAR)        
-- + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nVARCHAR),        
"NO of Invoices" = count(#temp.product_code)    
from #temp, items, UOM, ConversionTable        
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code         
and #temp.SaleID = 1         
AND Items.UOM *= UOM.UOM        
AND Items.ConversionUnit *= ConversionTable.ConversionID        
group by #temp.product_code,productname, #temp.SaleID,         
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description        
        
UNION ALL        
        
select  "Items" =  #temp.product_code + ':' + Cast('2' as nvarchar) , "Item Code" = #temp.product_code, "Item Name" = productname ,         
"First Sale (%c)" = NULL,         
"Second Sale (%c)" = sum(Price),         
"Other Sales (%c)" = NULL,         
"Total Quantity" = CAST(sum(quantity) AS nVARCHAR)        
+ ' ' + CAST(UOM.Description AS nVARCHAR),         
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS Decimal(18,6)) AS nVARCHAR)        
+ ' ' + CAST(ConversionTable.ConversionUnit AS nVARCHAR),        
"Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(#temp.product_code, SUM(IsNull(Quantity, 0))) As nVarChar)   
+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nVARCHAR),  
  
-- "Reporting UOM" = CAST(CAST(SUM(Quantity / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nVARCHAR)        
-- + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nVARCHAR),        
"NO of Invoices" = count(#temp.product_code)    
from #temp, items, UOM, ConversionTable        
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code         
and #temp.SaleID = 2         
AND Items.UOM *= UOM.UOM        
AND Items.ConversionUnit *= ConversionTable.ConversionID        
group by #temp.product_code,productname, #temp.SaleID,         
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description        
        
UNION ALL        
        
select "Items" = #temp.product_code + ':' + Cast('0' as nvarchar), "Item Code" = #temp.product_code,         
"Item Name" = productname ,         
"First Sale (%c)" = NULL,         
"Second Sale (%c)" = NULL,         
"Other Sales (%c)" = sum(Price),         
"Total Quantity" = CAST(sum(quantity) AS nVARCHAR)        
+ ' ' + CAST(UOM.Description AS nVARCHAR),         
"Conversion Factor" = CAST(CAST(SUM(Quantity * Items.ConversionFactor) AS Decimal(18,6)) AS nVARCHAR)        
+ ' ' + CAST(ConversionTable.ConversionUnit AS nVARCHAR),        
"Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(#temp.product_code, SUM(IsNull(Quantity, 0))) As nVarChar)   
+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nVARCHAR),  
  
-- "Reporting UOM" = CAST(CAST(SUM(Quantity / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nVARCHAR)        
-- + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nVARCHAR),        
"NO of Invoices" = count(#temp.product_code)    
from #temp, items, UOM, ConversionTable        
where #temp.product_code collate SQL_Latin1_General_Cp1_CI_AS = items.product_code         
and ISNULL(#temp.SaleID, 0) = 0         
AND Items.UOM *= UOM.UOM        
AND Items.ConversionUnit *= ConversionTable.ConversionID        
group by #temp.product_code,productname, #temp.SaleID,         
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description        
drop table #temp      
Drop table #tmpMfr  
Drop table #tmpItem    
Drop table #tmpBatch
