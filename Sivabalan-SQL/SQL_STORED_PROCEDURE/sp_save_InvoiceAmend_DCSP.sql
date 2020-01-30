
CREATE Procedure sp_save_InvoiceAmend_DCSP(@INVOICE_ID int,
				      @ITEM_CODE NVARCHAR(15),
				      @BATCH_NUMBER NVARCHAR(255), 
				      @SALE_PRICE Decimal(18,6), 
				      @REQUIRED_QUANTITY Decimal(18,6),
				      @SALE_TAX Decimal(18,6),
				      @DISCOUNT_PER Decimal(18,6), 
				      @DISCOUNT_AMOUNT Decimal(18,6),
				      @AMOUNT Decimal(18,6), 	
				      @TRACK_BATCHES int,
				      @STOCK Decimal(18,6))
AS
DECLARE @BATCH_CODE int 
DECLARE @QUANTITY Decimal(18,6)
DECLARE @RETVAL Decimal(18,6)
DECLARE @TOTAL_QUANTITY Decimal(18,6)

IF @TRACK_BATCHES = 1
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND Batch_Number = @BATCH_NUMBER

	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number, Batch_Code, Quantity FROM Batch_Products
	WHERE Product_Code = @ITEM_CODE and Batch_Number = @BATCH_NUMBER

	END
ELSE
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE

	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number, Batch_Code, Quantity FROM Batch_Products
	WHERE Product_Code = @ITEM_CODE
	
	END

OPEN ReleaseStocks
IF (@TOTAL_QUANTITY + @STOCK) < @REQUIRED_QUANTITY 
	BEGIN
	SET @RETVAL = 0
	GOTO OVERNOUT
	END
ELSE
	BEGIN
	SET @RETVAL = 1
	END
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY

WHILE @@FETCH_STATUS = 0
BEGIN
    IF (@QUANTITY + @STOCK) >= @REQUIRED_QUANTITY 
	BEGIN
        UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY + @STOCK
        WHERE Batch_Code = @BATCH_CODE

        INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number, Quantity, SalePrice, 
	TaxCode, DiscountPercentage, DiscountValue, Amount) 
	VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @REQUIRED_QUANTITY, @SALE_PRICE,
        @SALE_TAX, @DISCOUNT_PER, @DISCOUNT_AMOUNT, @AMOUNT)
        GOTO OVERNOUT
	END
    ELSE
	BEGIN
	set @REQUIRED_QUANTITY = @REQUIRED_QUANTITY - @QUANTITY
	UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE
        INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number, Quantity, SalePrice, 
	TaxCode, DiscountPercentage, DiscountValue, Amount)
	VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @QUANTITY, @SALE_PRICE, 
	@SALE_TAX, @DISCOUNT_PER, @DISCOUNT_AMOUNT, @AMOUNT)
	END 
    FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY
END
OVERNOUT:
CLOSE ReleaseStocks
DEALLOCATE ReleaseStocks
SELECT @RETVAL


