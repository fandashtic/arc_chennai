CREATE PROCEDURE [dbo].[sp_acc_prn_StkAdjRetdetailUOM_Count](@ADJUSTMENTID INT)
AS

SELECT count(1)
FROM 
AdjustmentReturnDetail
Left Join Items on AdjustmentReturnDetail.Product_Code = Items.Product_Code
Left Join StockAdjustmentReason on AdjustmentReturnDetail.ReasonID = StockAdjustmentReason.MessageID
Left Join UOM on AdjustmentReturnDetail.UOM = UOM.UOM 
--AdjustmentReturnDetail, Items, StockAdjustmentReason,UOM
WHERE 	AdjustmentID = @ADJUSTMENTID 
	--AND 
	--AdjustmentReturnDetail.Product_Code *= Items.Product_Code AND 
	--AdjustmentReturnDetail.ReasonID *= StockAdjustmentReason.MessageID
	--And AdjustmentReturnDetail.UOM *= UOM.UOM  
-- -- -- Execute sp_acc_rpt_StkAdjRetdetailuom @ADJUSTMENTID

