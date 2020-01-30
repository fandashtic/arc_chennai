CREATE PROCEDURE sp_update_StockNorm(@ITEMCODE NVARCHAR(15),
				     @STOCKNORM Decimal(18,6))
AS
UPDATE Items SET StockNorm = @STOCKNORM WHERE Product_Code = @ITEMCODE And isNull(MinOrderQty,0) <= @STOCKNORM

SELECT @@ROWCOUNT

