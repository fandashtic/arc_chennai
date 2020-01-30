
CREATE PROCEDURE spr_list_Itemwise_Purchase(@FROMDATE DATETIME,
						   @TODATE DATETIME)
AS
SELECT PODetail.Product_Code, PODetail.Product_Code, Items.ProductName,
"Total Purchase Order" = SUM(PODetail.Quantity), "Total Pending Order" = SUM(PODetail.Pending)
FROM POAbstract, PODetail, Items
WHERE POAbstract.PODate BETWEEN @FROMDATE AND @TODATE
AND POAbstract.PONumber = PODetail.PONumber
AND PODetail.Product_Code = Items.Product_Code
GROUP BY PODetail.Product_Code, Items.ProductName
ORDER BY PODetail.Product_Code

