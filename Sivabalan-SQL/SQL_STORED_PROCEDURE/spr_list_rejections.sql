CREATE PROCEDURE spr_list_rejections(@FROMDATE datetime,
				     @TODATE datetime)
AS
SELECT  GRNDetail.Product_Code, "Item Code" = GRNDetail.Product_Code, "Item Name" = Items.ProductName,
	"Rejection" = SUM(GRNDetail.QuantityRejected)
FROM GRNAbstract, GRNDetail, Items
WHERE   GRNAbstract.GRNID = GRNDetail.GRNID AND 
	GRNDetail.Product_Code = Items.Product_Code AND 
	GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE
	AND (GRNAbstract.GRNStatus & 64) = 0
	AND (GRNAbstract.GRNStatus & 32) = 0
GROUP BY  GRNDetail.Product_Code, Items.ProductName
HAVING SUM(GRNDetail.QuantityRejected) > 0
ORDER BY GRNDetail.Product_Code
