
CREATE PROCEDURE sp_get_POInvalidItems(@PONUMBER INT)

AS

SELECT PODetailReceived.Product_Code 
FROM PODetailReceived
WHERE PONumber = @PONUMBER AND
PODetailReceived.Product_Code not in 
(select product_code from items)


