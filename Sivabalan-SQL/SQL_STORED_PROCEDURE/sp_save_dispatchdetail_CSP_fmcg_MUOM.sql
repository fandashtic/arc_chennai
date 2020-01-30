CREATE Procedure sp_save_dispatchdetail_CSP_fmcg_MUOM(@DISPATCH_ID int,
				@ITEM_CODE NVARCHAR(15),
				@BATCH_NUMBER NVARCHAR(255), 
				@SALE_PRICE Decimal(18,6), 
				@REQUIRED_QUANTITY Decimal(18,6),
				@TRACK_BATCHES int,
				@TRACK_INVENTORY int,
				@FLAG int,
				@FreeRow Int = 0,
				@OpeningDate datetime = Null,
				@BackDatedTransaction int = 0,
				@UOMID Int,
				@UOMQty Decimal(18,6),
				@UOMPrice Decimal(18,6),
				@Serial int = 0)
AS
DECLARE @BATCH_CODE int 
DECLARE @QUANTITY Decimal(18,6)
DECLARE @RETVAL Decimal(18,6)
DECLARE @TOTAL_QUANTITY Decimal(18,6)
DECLARE @PURCHASEPRICE Decimal(18,6)
DECLARE @DIFF Decimal(18,6)

IF @TRACK_INVENTORY = 0
BEGIN
	SET @RETVAL = 1
        INSERT INTO DispatchDetail(DispatchID, Product_Code, Batch_Code, Quantity, 
	SalePrice, FlagWord, UOM, UOMQty, UOMPrice,Serial)
	VALUES (@DISPATCH_ID, @ITEM_CODE, 0, @REQUIRED_QUANTITY, @SALE_PRICE, @FLAG,
	@UOMID, @UOMQty, @UOMPrice,@Serial)
	GOTO ALL_SAID_AND_DONE
END
IF @TRACK_BATCHES = 1
	BEGIN
	SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
	WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
	AND ISNULL(SalePrice, 0) = @SALE_PRICE AND (Expiry >= GetDate() OR Expiry IS NULL) 
	And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow

	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice FROM Batch_Products
	WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
	and ISNULL(SalePrice, 0) = @SALE_PRICE AND ISNULL(Quantity, 0) > 0 
	AND (Expiry >= GetDate() OR Expiry IS NULL) 
	And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
	END
ELSE
	BEGIN
	SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
	WHERE Product_Code = @ITEM_CODE AND ISNULL(SalePrice, 0) = @SALE_PRICE 
	And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow

	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice FROM Batch_Products
	WHERE Product_Code = @ITEM_CODE AND ISNULL(SalePrice, 0) = @SALE_PRICE 
	AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
	And isnull(Free, 0) = @FreeRow
	END

OPEN ReleaseStocks
IF @TOTAL_QUANTITY < @REQUIRED_QUANTITY
	BEGIN
	SET @RETVAL = 0
	GOTO OVERNOUT
	END
ELSE
	BEGIN
	SET @RETVAL = 1
	END
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @PURCHASEPRICE

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @QUANTITY >= @REQUIRED_QUANTITY
	BEGIN
        UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY
	WHERE Batch_Code = @BATCH_CODE

	IF @@ROWCOUNT = 0
	BEGIN
		SET @RETVAL = 1
		GOTO OVERNOUT
	END
        INSERT INTO DispatchDetail(DispatchID, Product_Code, Batch_Code, Quantity, 
	SalePrice, FlagWord, UOM, UOMQty, UOMPrice,Serial)
	VALUES (@DISPATCH_ID, @ITEM_CODE, @BATCH_CODE, @REQUIRED_QUANTITY, @SALE_PRICE, 
	@FLAG, @UOMID, @UOMQty, @UOMPrice,@Serial)
	IF @BackDatedTransaction = 1 
	BEGIN
	SET @DIFF = 0 - @REQUIRED_QUANTITY
	exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @PURCHASEPRICE
	END
        GOTO OVERNOUT
	END
    ELSE
	BEGIN
	set @REQUIRED_QUANTITY = @REQUIRED_QUANTITY - @QUANTITY
	UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE
	IF @@ROWCOUNT = 0
	BEGIN
		SET @RETVAL = 1
		GOTO OVERNOUT
	END
        INSERT INTO DispatchDetail(DispatchID, Product_Code, Batch_Code, Quantity, 
	SalePrice, FlagWord, UOM, UOMQty, UOMPrice,Serial)
	VALUES (@DISPATCH_ID, @ITEM_CODE, @BATCH_CODE, @QUANTITY, @SALE_PRICE, @FLAG,
	@UOMID, @UOMQty, @UOMPrice,@Serial)
	IF @BackDatedTransaction = 1 
	BEGIN
	SET @DIFF = 0 - @QUANTITY
	exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @PURCHASEPRICE
	END
	END 
	Set @UOMQTY = 0
    FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @PURCHASEPRICE
END
OVERNOUT:
CLOSE ReleaseStocks
DEALLOCATE ReleaseStocks
ALL_SAID_AND_DONE:
SELECT @RETVAL




