
CREATE PROCEDURE sp_get_PendingQty(@PRODUCTCODE NVARCHAR(15))

AS

SELECT SUM(PODetail.Pending), Product_Code FROM POAbstract, PODetail 
WHERE PODetail.PONumber = POAbstract.PONumber AND (POAbstract.Status & 128 = 0)
AND Product_Code = @PRODUCTCODE
GROUP BY Product_Code

