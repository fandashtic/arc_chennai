CREATE procedure [dbo].[sp_get_SOReceivedItems](@SONUMBER INT)

AS

SELECT Items.Product_Code, Sum(Quantity) FROM SODetailReceived, Items
WHERE SONumber = @SONUMBER AND
SODetailReceived.Product_Code *= Items.Alias
GROUP BY Items.Product_Code ORDER BY Items.Product_Code
