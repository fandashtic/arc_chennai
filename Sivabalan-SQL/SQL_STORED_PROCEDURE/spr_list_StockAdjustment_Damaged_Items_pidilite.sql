CREATE procedure [dbo].[spr_list_StockAdjustment_Damaged_Items_pidilite](@STOCKADJID INT)

AS

SELECT StockAdjustment.Product_Code, 
"Item Code" = StockAdjustment.Product_Code, 
"Item Name" = Items.ProductName, "Batch" = StockAdjustment.Batch_Number,
"Damaged Qty" = ISNULL(SUM(StockAdjustment.Quantity),0), 
"Reporting UOM" = ISNULL(SUM(StockAdjustment.Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),0),
"Conversion Factor" = ISNULL(SUM(StockAdjustment.Quantity * IsNull(ConversionFactor, 0)),0),
"Damaged Value" = ISNULL(SUM(Rate), 0),
"Reason" = StockAdjustmentReason.Message
FROM StockAdjustment, Items, StockAdjustmentReason
WHERE StockAdjustment.SerialNo = @STOCKADJID
AND StockAdjustment.Product_Code = Items.Product_Code
AND StockAdjustment.ReasonID *= StockadjustmentReason.MessageID
GROUP BY StockAdjustment.Product_Code, Items.ProductName, 
StockAdjustment.Batch_Number, StockAdjustmentReason.Message
