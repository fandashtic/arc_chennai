CREATE PROCEDURE sp_get_order_qty_value(@PRODUCT_CODE nvarchar(15),
					@FROM_DATE datetime,
					@TO_DATE datetime)
AS
SELECT  SUM(Quantity) as OnOrderQty, SUM(Quantity * PurchasePrice) as OnOrderValue FROM PODetail, POAbstract
WHERE   Product_Code = @PRODUCT_CODE AND POAbstract.PONumber = PODetail.PONumber
	AND POAbstract.PODate BETWEEN @FROM_DATE AND @TO_DATE And (POAbstract.Status & 128) = 0
