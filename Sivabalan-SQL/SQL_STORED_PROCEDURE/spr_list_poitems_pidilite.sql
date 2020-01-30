CREATE procedure [dbo].[spr_list_poitems_pidilite](@PONUMBER int)  
AS  
SELECT PODetail.Product_Code, "Item Code" = PODetail.Product_Code,   
"Item Name" = Items.ProductName,   
"PO Quantity" = Quantity,   
"Reporting UOM" = Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End,    
"Conversion Factor" = Quantity * IsNull(ConversionFactor, 0),    
"Pending Quantity" = Pending,   
"Reporting UOM" = Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End,    
"Conversion Factor" = Quantity * IsNull(ConversionFactor, 0),  
"Purchase Price" = PurchasePrice  
FROM PODetail, Items  
WHERE PONumber = @PONUMBER AND PODetail.Product_Code *= Items.Product_Code
