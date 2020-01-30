Create Procedure UpdateBatchProducts_DandD @ID int
AS
BEGIN
	Declare @Batch_code int,@RFAQty decimal(18,6)
	Declare UpdateStock Cursor For Select Batch_code,RFAQuantity From DandDDetail where ID=@ID order by Batch_code
	Open UpdateStock
	Fetch from UpdateStock into @Batch_code,@RFAQty
	While @@fetch_status=0
	BEGIN
		If (select sum(isnull(Quantity,0)-isnull(ClaimedAlready,0)+isnull(@RFAQty,0)) from batch_products where batch_code=@Batch_code)>=0
		BEGIN
			Update batch_products set ClaimedAlready=isnull(ClaimedAlready,0)+isnull(@RFAQty,0) where batch_code=@Batch_code
		END
		Fetch Next from UpdateStock into @Batch_code,@RFAQty
	END
	Close UpdateStock
	Deallocate UpdateStock
END
