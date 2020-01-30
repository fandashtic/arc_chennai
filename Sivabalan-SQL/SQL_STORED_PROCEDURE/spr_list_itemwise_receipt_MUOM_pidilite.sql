CREATE procedure [dbo].[spr_list_itemwise_receipt_MUOM_pidilite](@ITEMCODE nvarchar(2550), @VENDOR nvarchar(2550),     
@FROMDATE datetime,  @TODATE datetime, @UOM as nvarchar(50))
AS
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)
If @UOM = N'' or @UOM = N'%'
Set @UOM = N'Sales UOM'
Create table #tmpProd(Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @ITEMCODE=N'%'
   insert into #tmpProd select product_code from items
else
   insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ITEMCODE,@Delimeter)

Create table #tmpVen(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @VENDOR=N'%'
   insert into #tmpVen select Vendor_Name from Vendors
else
   insert into #tmpVen select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)

If @UOM = N'Sales UOM'
Begin 
SELECT  GRNDetail.Product_Code, "Item Code" = GRNDetail.Product_Code, 
	"Item Name" = Items.ProductName,
	"Total Qty Received" = CAST(SUM(GRNDetail.QuantityReceived + IsNull(GRNDetail.FreeQty, 0) - GRNDetail.QuantityRejected ) AS nvarchar)
	+ N' ' + CAST(UOM.Description AS nvarchar),
--"UOM1" = (SELECT Description FROM UOM WHERE UOM = Items.UOM1),    
--"UOM2" = (SELECT Description FROM UOM WHERE UOM = Items.UOM2),    
"Conversion Factor" = CAST(CAST(SUM((GRNDetail.QuantityReceived + IsNull(GRNDetail.FreeQty, 0)- GRNDetail.QuantityRejected) * Items.ConversionFactor) AS Decimal(18,6)) AS nvarchar)
	+ N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
"Reporting UOM" = Cast(SUM((GRNDetail.QuantityReceived + IsNull(GRNDetail.FreeQty, 0)- GRNDetail.QuantityRejected) / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End) As nvarchar) + N' ' + 
    CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar)
FROM GRNAbstract, GRNDetail, Items, UOM, ConversionTable, Vendors
WHERE   GRNAbstract.GRNID = GRNDetail.GRNID AND 
	GRNDetail.Product_Code = Items.Product_Code AND 
	GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE
	AND Items.UOM *= UOM.UOM
	AND Items.ConversionUnit *= ConversionTable.ConversionID
	AND (GRNAbstract.GRNStatus & 64) = 0
	AND (GRNAbstract.GRNStatus & 32) = 0 AND Items.product_code in(select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) and
GRNAbstract.VendorID = Vendors.VendorID 
And Vendors.Vendor_Name in (select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen)
GROUP BY GRNDetail.Product_Code, Items.ProductName, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description, Items.UOM1, Items.UOM2,
Items.ReportingUnit
ORDER BY GRNDetail.Product_Code
End
Else 
Begin
SELECT  GRNDetail.Product_Code, "Item Code" = GRNDetail.Product_Code, 
	"Item Name" = Items.ProductName,
	"Total Qty Received" = CAST( 
	dbo.sp_Get_ReportingQty((SUM(GRNDetail.QuantityReceived + IsNull(GRNDetail.FreeQty, 0) - GRNDetail.QuantityRejected)), 
	Case When @UOM = N'UOM1' Then IsNull(Items.Uom1_Conversion,1) Else IsNull(Items.UOM2_Conversion,1) End) AS nvarchar)
	+ N' ' + CAST((Case When @UOM = N'UOM1' Then (SELECT IsNull(Description,N'') FROM UOM WHERE UOM = Items.UOM1) Else (SELECT IsNull(Description,N'') FROM UOM WHERE UOM = Items.UOM2) End) AS nvarchar)
-- "UOM1" = (SELECT Description FROM UOM WHERE UOM = Items.UOM1),    
-- "UOM2" = (SELECT Description FROM UOM WHERE UOM = Items.UOM2)
-- ,	"CONVERSION FACTOR" = CAST(CAST(SUM((GRNDETAIL.QUANTITYRECEIVED + ISNULL(GRNDETAIL.FREEQTY, 0)- GRNDETAIL.QUANTITYREJECTED) * ITEMS.CONVERSIONFACTOR) AS DECIMAL(18,6)) AS nvarchar)
-- 	+ ' ' + CAST(CONVERSIONTABLE.CONVERSIONUNIT AS nvarchar),
--  "REPORTING UOM" = 
--   SUBSTRING(
--    CAST(CAST(SUM((GRNDETAIL.QUANTITYRECEIVED + ISNULL(GRNDETAIL.FREEQTY, 0)- GRNDETAIL.QUANTITYREJECTED) / (CASE ISNULL(ITEMS.REPORTINGUNIT, 0) WHEN 0 THEN 1 ELSE ISNULL(ITEMS.REPORTINGUNIT, 0) END)) AS DECIMAL(18,6)) AS nvarchar), 1, 
--    CHARINDEX('.', CAST(CAST(SUM((GRNDETAIL.QUANTITYRECEIVED + ISNULL(GRNDETAIL.FREEQTY, 0)- GRNDETAIL.QUANTITYREJECTED) / (CASE ISNULL(ITEMS.REPORTINGUNIT, 0) WHEN 0 THEN 1 ELSE ISNULL(ITEMS.REPORTINGUNIT, 0) END)) AS DECIMAL(18,6)) AS nvarchar)) -1)
--   + '.' + 
--  CAST(SUM(CAST(ISNULL((GRNDETAIL.QUANTITYRECEIVED + ISNULL(GRNDETAIL.FREEQTY, 0)- GRNDETAIL.QUANTITYREJECTED), 0) AS INT)) % AVG(CAST((CASE ITEMS.REPORTINGUNIT WHEN 0 THEN 1 ELSE ITEMS.REPORTINGUNIT END) AS INT)) AS nvarchar)
--   + ' ' + CAST((SELECT DESCRIPTION FROM UOM WHERE UOM = ITEMS.REPORTINGUOM) AS nvarchar)

-- 	"Reporting UOM" = CAST(CAST(SUM((GRNDetail.QuantityReceived + IsNull(GRNDetail.FreeQty, 0)- GRNDetail.QuantityRejected) / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)
-- 	+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar)
FROM GRNAbstract, GRNDetail, Items, UOM, ConversionTable, Vendors
WHERE   GRNAbstract.GRNID = GRNDetail.GRNID AND 
	GRNDetail.Product_Code = Items.Product_Code AND 
	GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE
	AND Items.UOM *= UOM.UOM
	AND Items.ConversionUnit *= ConversionTable.ConversionID
	AND (GRNAbstract.GRNStatus & 64) = 0
	AND (GRNAbstract.GRNStatus & 32) = 0 AND Items.product_code in(select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) and
GRNAbstract.VendorID = Vendors.VendorID 
And Vendors.Vendor_Name in (select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen)
GROUP BY GRNDetail.Product_Code, Items.ProductName, 
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description, Items.UOM1, Items.UOM2,Items.UOM1_Conversion,Items.UOM2_Conversion
ORDER BY GRNDetail.Product_Code
End

Drop table #tmpProd
Drop table #tmpVen
