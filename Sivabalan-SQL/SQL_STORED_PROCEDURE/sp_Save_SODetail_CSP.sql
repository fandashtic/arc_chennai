
CREATE Procedure sp_Save_SODetail_CSP(@DISPATCH_ID int,
				      @ITEM_CODE NVARCHAR(15),
				      @BATCH_NUMBER NVARCHAR(255), 
				      @SALE_PRICE Decimal(18,6), 
				      @REQUIRED_QUANTITY Decimal(18,6),
				      @SALE_TAX Decimal(18,6),
				      @DISCOUNT Decimal(18,6), 
				      @TRACK_BATCHES int)
AS
DECLARE @BATCH_CODE int 
DECLARE @QUANTITY Decimal(18,6)
DECLARE @RETVAL Decimal(18,6)
DECLARE @TOTAL_QUANTITY Decimal(18,6)

IF @TRACK_BATCHES = 1
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND Batch_Number = @BATCH_NUMBER AND SalePrice = @SALE_PRICE

	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number, Batch_Code, Quantity FROM Batch_Products
	WHERE Product_Code = @ITEM_CODE and Batch_Number = @BATCH_NUMBER and SalePrice = @SALE_PRICE

	END
ELSE
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND SalePrice = @SALE_PRICE

	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number, Batch_Code, Quantity FROM Batch_Products
	WHERE Product_Code = @ITEM_CODE AND SalePrice = @SALE_PRICE
	
	END

IF @TOTAL_QUANTITY < @REQUIRED_QUANTITY
	BEGIN
	SET @RETVAL = 0
	GOTO OVERNOUT
	END
ELSE
	BEGIN
	SET @RETVAL = 1
	END

OPEN ReleaseStocks
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @QUANTITY >= @REQUIRED_QUANTITY
	BEGIN
        UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY
        WHERE Batch_Code = @BATCH_CODE

        INSERT INTO DispatchDetail(DispatchID, Product_Code, Batch_Code, Quantity, SalePrice) 
	VALUES (@DISPATCH_ID, @ITEM_CODE, @BATCH_CODE, @REQUIRED_QUANTITY, @SALE_PRICE)
        GOTO OVERNOUT
	END
    ELSE
	BEGIN
	set @REQUIRED_QUANTITY = @REQUIRED_QUANTITY - @QUANTITY
	UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE
        INSERT INTO DispatchDetail(DispatchID, Product_Code, Batch_Code, Quantity, SalePrice)
	VALUES (@DISPATCH_ID, @ITEM_CODE, @BATCH_CODE, @QUANTITY, @SALE_PRICE)
	END 
    FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY
END
OVERNOUT:
CLOSE ReleaseStocks
DEALLOCATE ReleaseStocks
SELECT @RETVAL

