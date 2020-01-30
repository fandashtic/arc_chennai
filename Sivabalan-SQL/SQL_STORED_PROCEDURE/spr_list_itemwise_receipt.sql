CREATE procedure [dbo].[spr_list_itemwise_receipt](@ITEMCODE nvarchar(2550), @VENDOR nvarchar(2550),     
@FROMDATE datetime,  @TODATE datetime)
AS
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)

Create table #tmpProd(Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @ITEMCODE='%'
   insert into #tmpProd select product_code from items
else
   insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ITEMCODE,@Delimeter)

Create table #tmpVen(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @VENDOR='%'
   insert into #tmpVen select Vendor_Name from Vendors
else
   insert into #tmpVen select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)

SELECT  GRNDetail.Product_Code, "Item Code" = GRNDetail.Product_Code, 
	"Item Name" = Items.ProductName,
	"Total Qty Received" = CAST(SUM(GRNDetail.QuantityReceived + IsNull(GRNDetail.FreeQty, 0) - GRNDetail.QuantityRejected ) AS nvarchar)
	+ ' ' + CAST(UOM.Description AS nvarchar),
	"Conversion Factor" = CAST(CAST(SUM((GRNDetail.QuantityReceived + IsNull(GRNDetail.FreeQty, 0)- GRNDetail.QuantityRejected) * Items.ConversionFactor) AS Decimal(18,6)) AS nvarchar)
	+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
 "Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(GRNDetail.Product_Code, SUM((GRNDetail.QuantityReceived + IsNull(GRNDetail.FreeQty, 0)- GRNDetail.QuantityRejected))) As nvarchar) 
--   SubString(
--    CAST(CAST(SUM((GRNDetail.QuantityReceived + IsNull(GRNDetail.FreeQty, 0)- GRNDetail.QuantityRejected) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1, 
--    CharIndex('.', CAST(CAST(SUM((GRNDetail.QuantityReceived + IsNull(GRNDetail.FreeQty, 0)- GRNDetail.QuantityRejected) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
--   + '.' + 
--   CAST(Sum(Cast((GRNDetail.QuantityReceived + IsNull(GRNDetail.FreeQty, 0)- GRNDetail.QuantityRejected) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)
  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar)
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
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description
ORDER BY GRNDetail.Product_Code

Drop table #tmpProd
Drop table #tmpVen
