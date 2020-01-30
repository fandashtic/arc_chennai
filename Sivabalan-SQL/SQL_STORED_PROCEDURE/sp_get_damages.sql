CREATE PROCEDURE sp_get_damages(@PRODUCT_CODE nvarchar(15),
				@FROM_DATE datetime,
				@TO_DATE datetime)
AS
SELECT SUM(OldQty - Quantity) as DamagesQty, SUM(OldValue - Rate) as DamagesValue
FROM StockAdjustment , StockAdjustmentAbstract 
WHERE   Product_Code = @PRODUCT_CODE AND StockAdjustment.SerialNO = StockAdjustmentAbstract.AdjustmentID
	AND StockAdjustmentAbstract.AdjustmentDate BETWEEN @FROM_DATE AND @TO_DATE And ISNULL(AdjustmentType,0) = 1
