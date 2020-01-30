
CREATE PROCEDURE sp_get_qty_rejected(@PRODUCT_CODE nvarchar(15),
				     @FROM_DATE datetime,
				     @TO_DATE datetime)
AS
SELECT SUM(QuantityRejected) FROM GRNDetail, GRNAbstract
WHERE   Product_Code = @PRODUCT_CODE AND 
	GRNAbstract.GRNDate BETWEEN @FROM_DATE AND @TO_DATE
	AND GRNAbstract.GRNID = GRNDetail.GRNID

