CREATE procedure [dbo].[spr_sales_by_ItemCategory_Details_Van]      
                (@CATID nVarChar(250),      
--                 @VANS nVARCHAR(100),    --dummy parameter
                 @FROMDATE DATETIME,      
                 @TODATE DATETIME)      
As      
--Declare @Pos Int
--Declare @Cat nVarChar(100)
--Declare @Van  nVarChar(100)
--set @Pos = CharIndex(char(15), @CATID)
--Set @Cat = Convert(Int, SubString(@CATID, 1, @Pos - 1))
--set @Van = Substring(@CATID, @Pos + 1, 251)
Select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,      
"Item Name" = Items.ProductName,      
"Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),      
"Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),      
"Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),      
"Total Quantity" = ISNULL(sum(Quantity), 0),      
"Conversion Factor" = CAST(CAST(ISNULL(sum(Quantity), 0) * Items.ConversionFactor  AS Decimal(18,6)) AS nVARCHAR)      
+ ' ' + CAST(ConversionTable.ConversionUnit AS nVARCHAR),      
"Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nVARCHAR)      
 + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nVARCHAR),      
--Cast(dbo.sp_Get_ReportingUOMQty(InvoiceDetail.Product_Code, SUM(IsNull(Quantity, 0))) As nVarChar)       
--+ ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nVARCHAR),      
-- "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nVARCHAR)      
-- + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS nVARCHAR),      
"Total Value (Rs)" = sum(Amount)       
  
from invoicedetail,Items,InvoiceAbstract, UOM, ConversionTable --,Van      
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID       
--and InvoiceAbstract.VanNumber=Van.Van    
--and van.van_number = @Van    
--and InvoiceAbstract.VanNumber=@Van    
and invoicedate between @FROMDATE and @TODATE      
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)      
And Items.Categoryid=@CATID --@Cat       
and items.product_Code=invoiceDetail.product_Code      
AND Items.UOM *= UOM.UOM      
AND Items.ConversionUnit *= ConversionTable.ConversionID      
Group by InvoiceDetail.Product_Code,Items.ProductName, --Van.Van, 
Items.ConversionFactor, Items.ReportingUnit, Items.ReportingUOM, 
ConversionTable.ConversionUnit,      
UOM.Description
