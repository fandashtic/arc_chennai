CREATE PROCEDURE spr_list_stockageing_report_pidilite (@Manufactname nvarchar(2550), 
@Divisionname nvarchar(2550), @ItemCode nvarchar(2550))
AS

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create table #tmpDiv(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

if @Manufactname = N'%'           
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer          
Else          
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufactname,@Delimeter)          
          
if @Divisionname = N'%'
   Insert into #tmpDiv select BrandName from Brand          
Else          
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@Divisionname,@Delimeter)          

If @ItemCode = N'%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

SELECT * INTO #TempOpen FROM OpeningDetails

SELECT 	Items.Product_Code, 
"Manufacturer" = Manufacturer.Manufacturer_Name, "Division" = Brand.BrandName, 
"Item Code" = Items.Product_Code, 
"Item Name" = Items.ProductName,
"Opening Quantity" = (SELECT TOP 1 IsNull(Opening_Quantity,0) FROM #TempOpen WHERE #TempOpen.Product_Code = Items.Product_Code ORDER BY Opening_Date),
"Total On Hand Qty" = SUM(Batch_Products.Quantity)
FROM Manufacturer, Brand, Items, Batch_Products
WHERE Items.Product_Code = Batch_Products.Product_Code And
Items.ManufacturerID = Manufacturer.ManufacturerID And 
Items.BrandID = Brand.BrandID And
Manufacturer.Manufacturer_Name IN (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And
Brand.BrandName IN (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And 
Items.Product_Code IN (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
GROUP BY Items.Product_Code, Items.ProductName, 
Manufacturer.Manufacturer_Name, Brand.BrandName
Having SUM(Batch_Products.Quantity) > 0

DROP Table #TempOpen
DROP Table #tmpMfr
DROP Table #tmpDiv
Drop Table #tmpProd

