Create PROCEDURE sp_Update_PendingQty_HHSR(@HHSRNo nvarchar(100), @ItemCode nvarchar(15), @Qty Decimal(18,6), @Flag int)  
AS
	Declare @Result int
	Declare @HHQty Decimal(18,6)
	Declare @DocumentID int
	Declare @RemainingQty Decimal(18,6)

	Set @Result = 0
	Set @RemainingQty = @Qty	

	IF (Select Sum(isnull(PendingQty,0)) From Stock_Return 
		Where ReturnNumber = @HHSRNo and Product_Code = @ItemCode and ReturnType = @Flag and Processed = 3) < @Qty
	Begin
		Set @Result = 1
		GOTO OVERNOUT
	End	

	DECLARE HHPending CURSOR STATIC FOR
	Select DocumentID, isnull(PendingQty,0) From Stock_Return 
		Where ReturnNumber = @HHSRNo and Product_Code = @ItemCode and ReturnType = @Flag and Processed = 3 
	OPEN HHPending
	FETCH FROM HHPending INTO  @DocumentID, @HHQty 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @HHQty >= @RemainingQty
		Begin
			Update Stock_Return Set PendingQty = isnull(PendingQty,0) - @RemainingQty
			Where ReturnNumber = @HHSRNo and Product_Code = @ItemCode and ReturnType = @Flag and Processed = 3 and DocumentID = @DocumentID
			
			Set @RemainingQty = 0
		End
		Else
		Begin
			Update Stock_Return Set PendingQty = isnull(PendingQty,0) - @HHQty
			Where ReturnNumber = @HHSRNo and Product_Code = @ItemCode and ReturnType = @Flag and Processed = 3 and DocumentID = @DocumentID

			Set @RemainingQty = @RemainingQty - @HHQty			
		End

		FETCH NEXT FROM HHPending INTO  @DocumentID, @HHQty
	END
	CLOSE HHPending
	DEALLOCATE HHPending
	
OVERNOUT:
	Select @Result

