
CREATE PROCEDURE sp_get_CntCatalogNotification(@FROMDATE DATETIME, 
					   @TODATE DATETIME)

AS

SELECT Count(*) FROM CatalogNotification 
WHERE ReceivedDate BETWEEN @FROMDATE AND @TODATE

