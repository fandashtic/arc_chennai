CREATE PROCEDURE [dbo].[sp_acc_rpt_dispatchdetail1](@DISPATCHID int)
AS
DECLARE @SPECIALCASE2 INT
SET @SPECIALCASE2=5

Declare @Version Int
Set @Version=dbo.sp_acc_getversion()
If @Version = 5 or @Version = 8 or @Version= 18 or @Version=19  or @Version=11-- Multiple UOM versions
Begin
	Exec sp_acc_rpt_dispatchdetailUOM1 @DISPATCHID
End
Else If @Version = 9 or @Version = 10
Begin
	Exec sp_acc_rpt_dispatchdetailSerial1 @DISPATCHID
End
Else
Begin
	SELECT  "Item Code" = DispatchDetail.Product_Code,
		"Item Name" = Items.ProductName,
		 "Quantity" = SUM(DispatchDetail.Quantity),
		 "Batch" = Batch_Products.Batch_Number,
		"Sale Price" = DispatchDetail.SalePrice,@SPECIALCASE2
	FROM DispatchDetail
	Join Items on DispatchDetail.Product_Code = Items.Product_Code
	Left Join Batch_Products on DispatchDetail.Batch_Code = Batch_Products.Batch_Code
	WHERE   DispatchDetail.DispatchID = @DISPATCHID 
	--AND DispatchDetail.Product_Code = Items.Product_Code 
	--AND DispatchDetail.Batch_Code *= Batch_Products.Batch_Code
	GROUP BY DispatchDetail.Product_Code, Items.ProductName, Batch_Products.Batch_Number, DispatchDetail.SalePrice
End
