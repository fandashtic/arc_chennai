CREATE procedure [dbo].[spr_list_itemwise_grn](@PRODUCT_CODE nvarchar(2550), @VENDOR nvarchar(2550),    
           @FROMDATE datetime,    
           @TODATE datetime)    
AS    

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)

Create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @Product_Code='%'
   insert into #tmpProd select product_code from items
else
   insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@Product_Code,@Delimeter)

Create table #tmpVen(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @VENDOR='%'
   insert into #tmpVen select Vendor_Name from Vendors
else
   insert into #tmpVen select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)

SELECT  GRNAbstract.GRNID, "GRN ID" = VoucherPrefix.Prefix + CAST(GRNAbstract.DocumentID AS nvarchar),     
 "GRN Date" = GRNAbstract.GRNDate, "Vendor Code" = Vendors.VendorID,     
"Vendor Name" = Vendors.Vendor_Name, "Rate " = Batch_Products.PurchasePrice,    
 "Recd. Qty" = CAST(SUM(Batch_Products.QuantityReceived) AS nvarchar)    
 + ' ' + CAST(UOM.Description AS nvarchar),    
 "Conversion Factor" = CAST(CAST(SUM(Batch_Products.QuantityReceived) * Items.ConversionFactor  AS Decimal(18,6)) AS nvarchar)    
 + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),    
"Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(@PRODUCT_CODE, SUM(ISNULL(Batch_Products.QuantityReceived, 0))) As nvarchar) 
--   SubString(
--    CAST(CAST(SUM(ISNULL(Batch_Products.QuantityReceived, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1, 
--    CharIndex('.', CAST(CAST(SUM(ISNULL(Batch_Products.QuantityReceived, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
--   + '.' + 
--   CAST(Sum(Cast(ISNULL(Batch_Products.QuantityReceived, 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)
  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),    

--  "Reporting UOM" = CAST(CAST((SUM(Batch_Products.QuantityReceived) / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)    
--  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),    
"Batch" = Batch_Products.Batch_Number, "PKD" = 
Cast(Datepart(mm, Batch_Products.PKD) As nvarchar) + '/' +
Cast(Datepart(yyyy, Batch_Products.PKD) As nvarchar),    
"Expiry" = Cast(Datepart(mm, Batch_Products.Expiry) As nvarchar) + '/' +
Cast(Datepart(yyyy, Batch_Products.Expiry) As nvarchar),     
"Gross Value" = (Sum(Batch_Products.QuantityReceived) * Batch_Products.PurchasePrice),    
"Tax Suffered" = ((Sum(Batch_Products.QuantityReceived) * Batch_Products.PurchasePrice) * Batch_Products.TaxSuffered)/100,    
"Net Value" = Case
		When (Sum(Batch_Products.QuantityReceived) * Batch_Products.PurchasePrice) <> 0 Then 
			(Sum(Batch_Products.QuantityReceived) * Batch_Products.PurchasePrice) + 
			((Sum(Batch_Products.QuantityReceived) * Batch_Products.PurchasePrice) * Batch_Products.TaxSuffered)/100
		Else
			0
		End
FROM GRNAbstract, VoucherPrefix, UOM, ConversionTable, Items, Vendors, Batch_Products    
WHERE GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE AND    
 VoucherPrefix.TranID = 'GOODS RECEIVED NOTE'       
 AND Items.UOM *= UOM.UOM    
 AND Items.ConversionUnit *= ConversionTable.ConversionID    
 AND ( GRNAbstract.GRNStatus & 64) = 0    
 AND ( GRNAbstract.GRNStatus & 32) = 0     
 And GRNAbstract.VendorID = Vendors.VendorID And Vendors.Vendor_Name in (select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen)
And GRNAbstract.GRNID = Batch_Products.GRN_ID  
And Batch_products.product_code = items.product_code         
And Batch_Products.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
And Batch_Products.QuantityReceived <> 0   
GROUP BY GRNAbstract.GRNID, GRNAbstract.DocumentID, GRNAbstract.GRNDate,     
 VoucherPrefix.Prefix, ConversionTable.ConversionUnit,     
 UOM.Description, Items.ReportingUOM, Vendors.VendorID,     
    Vendors.Vendor_Name, Batch_Products.PurchasePrice, Batch_Products.Batch_Number,    
    Batch_Products.PKD,Batch_Products.Expiry, Batch_Products.TaxSuffered, 
	Items.ConversionFactor, Items.ReportingUnit    

Drop table #tmpProd
Drop table #tmpVen
