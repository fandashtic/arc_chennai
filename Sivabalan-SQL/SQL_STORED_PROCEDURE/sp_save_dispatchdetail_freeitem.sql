
CREATE Procedure sp_save_dispatchdetail_freeitem(@DISPATCH_ID int,
				      @ITEM_CODE NVARCHAR(15),
				      @REQUIRED_QUANTITY Decimal(18,6))
AS
DECLARE @BATCH_CODE int 
DECLARE @QUANTITY Decimal(18,6)
DECLARE @RETVAL Decimal(18,6)
DECLARE @TOTAL_QUANTITY Decimal(18,6)
DECLARE @SALEPRICE Decimal(18,6)

SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE

DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT Batch_Code, Quantity, ISNULL(SalePrice, 0) FROM Batch_Products
WHERE Product_Code = @ITEM_CODE AND ISNULL(Quantity, 0) > 0
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
FETCH FROM ReleaseStocks into @BATCH_CODE, @QUANTITY, @SALEPRICE

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @QUANTITY >= @REQUIRED_QUANTITY
	BEGIN
        UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY
        WHERE Batch_Code = @BATCH_CODE

        INSERT INTO DispatchDetail(DispatchID, Product_Code, Batch_Code, Quantity, SalePrice, FlagWord) 
	VALUES (@DISPATCH_ID, @ITEM_CODE, @BATCH_CODE, @REQUIRED_QUANTITY, 0, 1)
        GOTO OVERNOUT
	END
    ELSE
	BEGIN
	set @REQUIRED_QUANTITY = @REQUIRED_QUANTITY - @QUANTITY
	UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE
        INSERT INTO DispatchDetail(DispatchID, Product_Code, Batch_Code, Quantity, SalePrice, FlagWord)
	VALUES (@DISPATCH_ID, @ITEM_CODE, @BATCH_CODE, @QUANTITY, 0, 1)
	END 
    FETCH NEXT FROM ReleaseStocks into @BATCH_CODE, @QUANTITY, @SALEPRICE
END
OVERNOUT:
CLOSE ReleaseStocks
DEALLOCATE ReleaseStocks
SELECT @RETVAL

