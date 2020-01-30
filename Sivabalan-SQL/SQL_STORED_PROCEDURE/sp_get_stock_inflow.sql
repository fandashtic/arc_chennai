CREATE PROCEDURE sp_get_stock_inflow(@PRODUCT_CODE nvarchar(15),
				     @FROM_DATE datetime,
				     @TO_DATE datetime)
AS
DECLARE @TOTAL_QUANTITY Decimal(18,6)
DECLARE @TOTAL_VALUE Decimal(18,6)
DECLARE @RETURN_QTY Decimal(18,6)
DECLARE @RETURN_VALUE Decimal(18,6)

SELECT @TOTAL_QUANTITY = ISNULL(SUM(QuantityReceived),0),
@TOTAL_VALUE = ISNULL(SUM(QuantityReceived * PurchasePrice), 0)
FROM Batch_Products
WHERE   Batch_Products.Product_Code = @PRODUCT_CODE AND 
	Batch_Products.GRN_ID in
	(SELECT GRNID FROM GRNAbstract 
	WHERE GRNAbstract.GRNDate BETWEEN @FROM_DATE AND @TO_DATE And (GRNStatus & 64) = 0)


SELECT @RETURN_QTY = ISNULL(SUM(Quantity),0), @RETURN_VALUE = ISNULL(SUM(Quantity * Rate),0)
FROM AdjustmentReturnDetail, AdjustmentReturnAbstract 
WHERE 	AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID AND 
	AdjustmentReturnDetail.Product_Code = @PRODUCT_CODE AND 
	AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROM_DATE AND @TO_DATE

SELECT "StockInflowQty" = @TOTAL_QUANTITY - @RETURN_QTY, "StockInflowValue" = @TOTAL_VALUE - @RETURN_VALUE
