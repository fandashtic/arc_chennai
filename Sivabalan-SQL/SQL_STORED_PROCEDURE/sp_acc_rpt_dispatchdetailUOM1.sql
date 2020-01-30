Create PROCEDURE [dbo].[sp_acc_rpt_dispatchdetailUOM1](@DISPATCHID int)
AS
DECLARE @SPECIALCASE2 INT
SET @SPECIALCASE2=5

SELECT  "Item Code" = DispatchDetail.Product_Code,
	"Item Name" = Items.ProductName,
	"UOM"=UOM.Description,
	"Quantity" = SUM(DispatchDetail.UOMQTY),
	"Batch" = Batch_Products.Batch_Number,
	"Sale Price" = DispatchDetail.UOMPrice,@SPECIALCASE2
FROM DispatchDetail
Inner Join Items on DispatchDetail.Product_Code = Items.Product_Code
Left Join Batch_Products on DispatchDetail.Batch_Code = Batch_Products.Batch_Code
Left Join UOM on DispatchDetail.UOM = UOM.UOM
WHERE   DispatchDetail.DispatchID = @DISPATCHID 
--AND 
--	DispatchDetail.Product_Code = Items.Product_Code AND
--	DispatchDetail.Batch_Code *= Batch_Products.Batch_Code And
--	DispatchDetail.UOM *= UOM.UOM
GROUP BY DispatchDetail.Product_Code, Items.ProductName, Batch_Products.Batch_Number,UOM.Description, DispatchDetail.UOMPrice

