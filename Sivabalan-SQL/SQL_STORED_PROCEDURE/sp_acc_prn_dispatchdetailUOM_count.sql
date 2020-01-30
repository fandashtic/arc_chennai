CREATE PROCEDURE [dbo].[sp_acc_prn_dispatchdetailUOM_count](@DISPATCHID int)
AS

SELECT  count(1)
FROM DispatchDetail
Join Items on DispatchDetail.Product_Code = Items.Product_Code
Join Batch_Products on DispatchDetail.Batch_Code = Batch_Products.Batch_Code
Left Join UOM on DispatchDetail.UOM = UOM.UOM
--DispatchDetail, Items, Batch_Products,UOM
WHERE   DispatchDetail.DispatchID = @DISPATCHID 
--AND 
	--DispatchDetail.Product_Code = Items.Product_Code AND
	--DispatchDetail.Batch_Code *= Batch_Products.Batch_Code And
	--DispatchDetail.UOM *= UOM.UOM

