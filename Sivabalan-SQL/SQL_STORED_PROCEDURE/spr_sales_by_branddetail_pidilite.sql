CREATE procedure [dbo].[spr_sales_by_branddetail_pidilite]
                (@BRANDID INT,
		 @VENDOR nvarchar(2550),
		 @BrandName nVarchar(255),
                 @FROMDATE DATETIME,
                 @TODATE DATETIME)
As

Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)    

Create table #tmpVendor(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @VENDOR='%'     
 Insert into #tmpVendor select VendorID from Vendors Union Select ''  
Else    
 Insert into #tmpVendor Select VendorID From Vendors Where Vendor_Name In 
 (select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter))

Select InvoiceDetail.Product_Code,"Item Name" = Items.ProductName,
"Total Quantity" =  CAST(ISNULL(SUM(Quantity), 0) AS nVARCHAR)
+ ' ' + CAST(UOM.Description AS nVARCHAR),
"Conversion Factor" = CAST(CAST(SUM(ISNULL(Quantity, 0) * Items.ConversionFactor) AS Decimal(18,6)) AS nVARCHAR)
+ ' ' + CAST(ConversionTable.ConversionUnit AS nVARCHAR),
"Reporting UOM" = 
-- Cast(dbo.sp_Get_ReportingUOMQty(InvoiceDetail.Product_Code, SUM(ISNULL(Quantity, 0))) As nVarChar) 
CAST(CAST(SUM(ISNULL(Quantity, 0) / (case Items.ReportingUnit when 0 then 1 else Items.ReportingUnit end)) AS Decimal(18,6)) AS nVARCHAR)
 + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nVARCHAR),
"Total Value (%c)" = sum(Amount) 
from invoicedetail,Items,InvoiceAbstract, UOM, ConversionTable 
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)
And Items.BrandID=@BRANDID
and items.product_Code=invoiceDetail.product_Code
AND Items.UOM *= UOM.UOM
AND Items.ConversionUnit *= ConversionTable.ConversionID
And Items.Preferred_vendor In (Select Vendor_Name From #tmpVendor)
Group by InvoiceDetail.Product_Code,Items.ProductName,
ConversionTable.ConversionUnit, Items.ReportingUOM, UOM.Description
