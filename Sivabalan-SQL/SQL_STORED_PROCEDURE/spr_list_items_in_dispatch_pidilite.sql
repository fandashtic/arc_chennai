CREATE procedure [dbo].[spr_list_items_in_dispatch_pidilite](@DISPATCHID int)  
AS  
SELECT  Max(DispatchDetail.Product_Code), "Item Code" = Max(DispatchDetail.Product_Code),  
 "Item Name" = Max(Items.ProductName), "Quantity" = SUM(DispatchDetail.Quantity), 
 "Reporting UOM" = SUM(DispatchDetail.Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),  
 "Conversion Factor" = SUM(DispatchDetail.Quantity * IsNull(ConversionFactor, 0)),  
 "Batch" = Max(Batch_Products.Batch_Number),  
 "Sale Price" = Max(DispatchDetail.SalePrice)  
FROM DispatchDetail, Items, Batch_Products  
WHERE   DispatchDetail.DispatchID = @DISPATCHID AND   
 DispatchDetail.Product_Code = Items.Product_Code AND  
 DispatchDetail.Batch_Code *= Batch_Products.Batch_Code  
GROUP BY isnull(DispatchDetail.Serial,0)
order by isnull(DispatchDetail.Serial,0)
