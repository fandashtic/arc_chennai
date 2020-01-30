
CREATE PROCEDURE sp_get_StockNorm(@ITEMCODE NVARCHAR(15))

AS

SELECT StockNorm, MinOrderQty FROM Items WHERE Product_Code = @ITEMCODE

