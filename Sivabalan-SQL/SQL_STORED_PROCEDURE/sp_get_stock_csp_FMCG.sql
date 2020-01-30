
CREATE Procedure sp_get_stock_csp_FMCG(@ITEM_CODE NVARCHAR(15),
				  @BATCH_NUMBER NVARCHAR(255), 
				  @SALE_PRICE Decimal(18,6), 
				  @REQUIRED_QUANTITY Decimal(18,6),
                                  @TRACK_BATCHES int)
AS
DECLARE @TOTAL_QUANTITY Decimal(18,6)

IF @TRACK_BATCHES = 1
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND Batch_Number = @BATCH_NUMBER AND SalePrice = @SALE_PRICE
	END
ELSE
	BEGIN
	SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND SalePrice = @SALE_PRICE
	END
SELECT @TOTAL_QUANTITY

