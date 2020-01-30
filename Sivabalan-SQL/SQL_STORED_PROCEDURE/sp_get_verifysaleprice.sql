
CREATE PROCEDURE sp_get_verifysaleprice(@ITEM_CODE nvarchar(15),
					@SALE_PRICE Decimal(18,6),
					@PRICE_OPTION float)
AS
	IF EXISTS (Select Product_Code FROM Batch_Products WHERE Product_Code = @ITEM_CODE AND SalePrice = @SALE_PRICE)
		SELECT 1
	ELSE
		SELECT 0
