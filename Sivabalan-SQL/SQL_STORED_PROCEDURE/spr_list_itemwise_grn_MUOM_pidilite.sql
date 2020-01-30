CREATE procedure [dbo].[spr_list_itemwise_grn_MUOM_pidilite](@PRODUCT_CODE nvarchar(15), @VENDOR nvarchar(255),    
           @FROMDATE datetime,    
           @TODATE datetime, @UOM nvarchar(50))    
AS    
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)
If @UOM = N'' or @UOM = N'%'
Set @UOM = N'Sales UOM'
--Multiple selection handled for vendor
Create table #tmpVen(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @VENDOR=N'%'
   insert into #tmpVen select Vendor_Name from Vendors
else
   insert into #tmpVen select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)
  
If @UOM = N'Sales UOM'
Begin
SELECT  GRNAbstract.GRNID, "GRN ID" = VoucherPrefix.Prefix + CAST(GRNAbstract.DocumentID AS nvarchar),     
 "GRN Date" = GRNAbstract.GRNDate, "Vendor Code" = Vendors.VendorID,     
"Vendor Name" = Vendors.Vendor_Name, "Rate " = Batch_Products.PurchasePrice,    
 "Recd. Qty" = CAST(SUM(Batch_Products.Quantity) AS nvarchar)    
 + N' ' + CAST(UOM.Description AS nvarchar),    
"UOM1" = (SELECT Description FROM UOM WHERE UOM = Items.UOM1),      
"UOM2" = (SELECT Description FROM UOM WHERE UOM = Items.UOM2),     
 "Conversion Factor" = CAST(CAST(SUM(Batch_Products.QuantityReceived) * Items.ConversionFactor  AS Decimal(18,6)) AS nvarchar)    
 + N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),    

 "Reporting UOM" = Cast(SUM(Batch_Products.QuantityReceived / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End) As nvarchar) + N'' + 
		CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
--   SubString(
--    CAST(CAST(SUM((Batch_Products.QuantityReceived) / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar), 1, 
--    CharIndex('.', CAST(CAST(SUM((Batch_Products.QuantityReceived) / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)) -1)
--   + '.' + 
--  CAST(Sum(Cast(ISNULL((Batch_Products.QuantityReceived), 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)
--   + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),

--  "Reporting UOM" = CAST(CAST((SUM(Batch_Products.QuantityReceived) / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)    
--  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),    
"Batch" = Batch_Products.Batch_Number, "PKD" = Cast(Datepart(mm, Batch_Products.PKD) As nvarchar) + N'/' +  
Cast(Datepart(yyyy, Batch_Products.PKD) As nvarchar),    
"Expiry" = Cast(Datepart(mm, Batch_Products.Expiry) As nvarchar) + N'/' +  
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
 VoucherPrefix.TranID = N'GOODS RECEIVED NOTE'    
  AND Items.UOM *= UOM.UOM    
 AND Items.ConversionUnit *= ConversionTable.ConversionID    
 AND ( GRNAbstract.GRNStatus & 64) = 0    
 AND ( GRNAbstract.GRNStatus & 32) = 0     
 And GRNAbstract.VendorID = Vendors.VendorID 
And Vendors.Vendor_Name in (select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen)
And GRNAbstract.GRNID = Batch_Products.GRN_ID  
And Batch_products.product_code = items.product_code         
And Batch_Products.Product_Code = @PRODUCT_CODE
And Batch_Products.QuantityReceived <> 0   
GROUP BY GRNAbstract.GRNID, GRNAbstract.DocumentID, GRNAbstract.GRNDate,     
 VoucherPrefix.Prefix, ConversionTable.ConversionUnit,     
 UOM.Description, Items.ReportingUOM, Items.UOM1, Items.UOM2, Vendors.VendorID,     
    Vendors.Vendor_Name, Batch_Products.PurchasePrice, Batch_Products.Batch_Number,    
    Batch_Products.PKD,Batch_Products.Expiry, Batch_Products.TaxSuffered, 
	Items.ConversionFactor,Items.ReportingUnit    
End
Else
Begin
	SELECT  GRNAbstract.GRNID, "GRN ID" = VoucherPrefix.Prefix + CAST(GRNAbstract.DocumentID AS nvarchar),     
	"GRN Date" = GRNAbstract.GRNDate, "Vendor Code" = Vendors.VendorID,     
	"Vendor Name" = Vendors.Vendor_Name, "Rate " = (Batch_Products.PurchasePrice * Case When @UOM = N'UOM1' Then IsNull(Items.UOM1_Conversion,1) Else IsNull(Items.UOM2_Conversion,1) End),    
	"Recd. Qty" = CAST(dbo.sp_Get_ReportingQty(SUM(Batch_Products.Quantity), 
	Case When @UOM = N'UOM1' Then IsNull(Items.UOM1_Conversion,1) Else IsNull(Items.UOM2_Conversion,1) End ) AS nvarchar)    
	+ N' ' + CAST(Case When @UOM = N'UOM1' Then (SELECT IsNull(Description,N'') FROM UOM WHERE UOM = Items.UOM1) Else (SELECT IsNull(Description,N'') FROM UOM WHERE UOM = Items.UOM2) End  AS nvarchar),    
-- 	"UOM1" = (SELECT Description FROM UOM WHERE UOM = Items.UOM1),      
-- 	"UOM2" = (SELECT Description FROM UOM WHERE UOM = Items.UOM2),     
-- 	"Conversion Factor" = CAST(CAST(SUM(Batch_Products.QuantityReceived) * Items.ConversionFactor  AS Decimal(18,6)) AS nvarchar)    
-- 	+ ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),    
-- 	
-- 	"Reporting UOM" = 
-- 	SubString(
-- 	CAST(CAST(SUM((Batch_Products.QuantityReceived) / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar), 1, 
-- 	CharIndex('.', CAST(CAST(SUM((Batch_Products.QuantityReceived) / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)) -1)
-- 	+ '.' + 
-- 	CAST(Sum(Cast(ISNULL((Batch_Products.QuantityReceived), 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)
-- 	+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),
-- 	
	--  "Reporting UOM" = CAST(CAST((SUM(Batch_Products.QuantityReceived) / (CASE ISNULL(Items.ReportingUnit, 0) WHEN 0 THEN 1 ELSE ISNULL(Items.ReportingUnit, 0) END)) AS Decimal(18,6)) AS nvarchar)    
	--  + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),    
	"Batch" = Batch_Products.Batch_Number, "PKD" = Cast(Datepart(mm, Batch_Products.PKD) As nvarchar) + N'/' +  
	Cast(Datepart(yyyy, Batch_Products.PKD) As nvarchar),    
	"Expiry" = Cast(Datepart(mm, Batch_Products.Expiry) As nvarchar) + N'/' +  
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
	VoucherPrefix.TranID = N'GOODS RECEIVED NOTE'    
	AND Items.UOM *= UOM.UOM    
	AND Items.ConversionUnit *= ConversionTable.ConversionID    
	AND ( GRNAbstract.GRNStatus & 64) = 0    
	AND ( GRNAbstract.GRNStatus & 32) = 0     
	And GRNAbstract.VendorID = Vendors.VendorID 
	And Vendors.Vendor_Name in (select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen)
	And GRNAbstract.GRNID = Batch_Products.GRN_ID  
	And Batch_products.product_code = items.product_code         
	And Batch_Products.Product_Code = @PRODUCT_CODE
	And Batch_Products.QuantityReceived <> 0   
	GROUP BY GRNAbstract.GRNID, GRNAbstract.DocumentID, GRNAbstract.GRNDate,     
	VoucherPrefix.Prefix, ConversionTable.ConversionUnit,     
	UOM.Description, Items.ReportingUOM, Items.UOM1, Items.UOM2, Vendors.VendorID,     
	Vendors.Vendor_Name, Batch_Products.PurchasePrice, Batch_Products.Batch_Number,    
	Batch_Products.PKD,Batch_Products.Expiry, Batch_Products.TaxSuffered, 
	Items.ConversionFactor,Items.ReportingUnit,Items.UOM1_Conversion,Items.UOM2_Conversion    
End

Drop table #tmpVen
