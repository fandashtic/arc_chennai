CREATE procedure [dbo].[spr_lists_purchase_by_ItemCategory_Details_pidilite]   
                (@CATID INT,    
                 @FROMDATE DATETIME,    
                 @TODATE DATETIME)    
As    
Select BillDetail.Product_Code, "Item Code" = BillDetail.Product_Code,    
"Item Name" = Items.ProductName,    
"Item Description" = Items.Description,  
"Total Quantity" = ISNULL(sum(Quantity), 0),    
"Conversion Factor" = CAST(CAST(ISNULL(sum(Quantity), 0) * Items.ConversionFactor  AS DECIMAL(18, 6)) AS nvarchar)    
+ N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
"Reporting UOM" = Cast(Cast(ISNULL(sum(Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End), 0)As Decimal(18, 6)) As nvarchar) 
+ N'' + CAST((SELECT Isnull(Description, N'') FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),    
-- "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS DECIMAL(18, 2)) AS nvarchar)    
-- + ' ' + CAST((SELECT Isnull(Description, '') FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),    
"PTS" = BillDetail.PTS,  
"PTR" = BillDetail.PTR,  
"ECP" = BillDetail.ECP,  
"Total Value (Rs)" = sum(Amount + BillDetail.TaxAmount)     
from BillDetail,Items,BillAbstract, UOM, ConversionTable    
where BillAbstract.BillID=BillDetail.BillID     
and Billdate between @FROMDATE and @TODATE    
And BillAbstract.Status&128=0   
And Items.Categoryid=@CatID     
and items.product_Code=BillDetail.product_Code    
AND Items.UOM *= UOM.UOM    
AND Items.ConversionUnit *= ConversionTable.ConversionID    
Group by BillDetail.Product_Code,Items.ProductName, Items.Description, Items.ConversionFactor,    
Items.ReportingUnit, Items.ReportingUOM,    
UOM.Description, BillDetail.PTS, BillDetail.PTR, BillDetail.ECP , ConversionTable.ConversionUnit,
Items.ReportingUnit
