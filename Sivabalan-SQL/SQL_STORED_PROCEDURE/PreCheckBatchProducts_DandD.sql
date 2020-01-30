Create Procedure PreCheckBatchProducts_DandD @ID int
AS
BEGIN
	Declare @ReturnValue int
	set @ReturnValue=1
	Declare @Batch_code int,@TotalQty decimal(18,6)
	Declare CheckStock Cursor For Select Batch_code,RFAQuantity From DandDDetail where ID=@ID order by Batch_code
	Open CheckStock
	Fetch from CheckStock into @Batch_code,@TotalQty
	While @@fetch_status=0
	BEGIN
		if isnull(@TotalQty,0) <> 0
		BEGIN
			If isnull(@TotalQty,0) <> (select isnull(ClaimedAlready,0) From batch_products where batch_code = @Batch_code)
			BEGIN
				Set @ReturnValue = 0
				Goto ExitCursor
			END
		END
		ELSE
		BEGIN
			Set @ReturnValue = 1
		END
		Fetch Next from CheckStock into @Batch_code,@TotalQty
	END
ExitCursor:
	Close CheckStock
	Deallocate CheckStock
Select @ReturnValue
END
