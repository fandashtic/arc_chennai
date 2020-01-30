CREATE PROCEDURE sp_get_StkTfrInInvalidItems(@DocSerial INT)    
AS    
SELECT StockTransferOutDetailReceived.ForumCode   
FROM StockTransferOutDetailReceived  
WHERE DocSerial = @DocSerial AND   
(
	Isnull(StockTransferOutDetailReceived.Product_Code,N'') NOT IN (SELECT PRODUCT_CODE FROM Items)
	or 
	Isnull(StockTransferOutDetailReceived.Product_Code,N'') in (select product_code from Items where active = 0)
)
