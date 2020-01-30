
CREATE PROCEDURE sp_get_InvalidItems(@SONUMBER INT)

AS

SELECT SODetailReceived.Product_Code 
FROM SODetailReceived
WHERE SONumber = @SONUMBER AND
SODetailReceived.Product_Code NOT IN (SELECT Alias FROM Items)
UNION
SELECT SODetailReceived.Product_Code 
FROM SODetailReceived, Items
WHERE SONumber = @SONUMBER AND
SODetailReceived.Product_Code = Items.Alias AND Items.Active = 0

