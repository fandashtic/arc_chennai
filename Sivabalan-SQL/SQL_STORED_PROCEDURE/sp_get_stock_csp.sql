
CREATE Procedure sp_get_stock_csp(@ITEM_CODE NVARCHAR(15),
				  @BATCH_NUMBER NVARCHAR(255), 
				  @SALE_PRICE Decimal(18,6), 
				  @REQUIRED_QUANTITY Decimal(18,6),
                                  @TRACK_BATCHES int,
				  @CUSTOMER_TYPE int)
AS
DECLARE @TOTAL_QUANTITY Decimal(18,6)

IF @CUSTOMER_TYPE = 1
BEGIN
IF @TRACK_BATCHES = 1
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND Batch_Number = @BATCH_NUMBER AND PTS = @SALE_PRICE
	END
ELSE
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND PTS = @SALE_PRICE
	END
END
ELSE IF @CUSTOMER_TYPE = 2
BEGIN
IF @TRACK_BATCHES = 1
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND Batch_Number = @BATCH_NUMBER AND PTR = @SALE_PRICE
	END
ELSE
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND PTR = @SALE_PRICE
	END
END
ELSE IF @CUSTOMER_TYPE = 3
BEGIN
IF @TRACK_BATCHES = 1
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND Batch_Number = @BATCH_NUMBER AND Company_Price = @SALE_PRICE
	END
ELSE
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND Company_Price = @SALE_PRICE
	END
END
SELECT @TOTAL_QUANTITY

