CREATE procedure spr_lists_purchase_by_ItemCategory_Details    
                (@CATID INT,    
                 @FROMDATE DATETIME,    
                 @TODATE DATETIME)    
As    
Select BillDetail.Product_Code, "Item Code" = BillDetail.Product_Code,    
"Item Name" = Items.ProductName,    
"Item Description" = Items.Description,  
"Total Quantity" = ISNULL(sum(Quantity), 0),    
"Conversion Factor" = CAST(CAST(ISNULL(sum(Quantity), 0) * Items.ConversionFactor  AS DECIMAL(18, 2)) AS nvarchar)    
+ N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),
"Reporting UOM" = Cast(dbo.sp_Get_ReportingQty(SUM(IsNull(Quantity, 0)), Items.ReportingUnit) As nvarchar) 
+ N'' + CAST((SELECT Isnull(Description, N'') FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),    
-- "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS DECIMAL(18, 2)) AS nvarchar)    
-- + ' ' + CAST((SELECT Isnull(Description, '') FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),    
"Net PTS" = BillDetail.PTS,
"Original PTS" = IsNull(BillDetail.OrgPTS,0),
"PTR" = BillDetail.PTR,  
"ECP" = BillDetail.ECP,  
"Total Value (Rs)" = sum(Amount + BillDetail.TaxAmount)     
from BillDetail
Inner Join Items On items.product_Code=BillDetail.product_Code  
Inner Join BillAbstract On BillAbstract.BillID=BillDetail.BillID
Left Outer Join UOM On Items.UOM = UOM.UOM 
Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID   
where Billdate between @FROMDATE and @TODATE    
And BillAbstract.Status&128=0   
And Items.Categoryid=@CatID     
Group by BillDetail.Product_Code,Items.ProductName, Items.Description, Items.ConversionFactor,    
Items.ReportingUnit, Items.ReportingUOM,    
UOM.Description, BillDetail.PTS,BillDetail.OrgPTS, BillDetail.PTR, BillDetail.ECP , ConversionTable.ConversionUnit,
Items.ReportingUnit
