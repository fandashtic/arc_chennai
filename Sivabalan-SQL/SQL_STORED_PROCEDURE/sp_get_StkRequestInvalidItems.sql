CREATE PROCEDURE sp_get_StkRequestInvalidItems(@RequestNo INT)    
AS    
SELECT Stock_Request_Detail_Received.ForumCode   
FROM Stock_Request_Detail_Received 
WHERE Stk_Req_Number = @RequestNo AND   
(
	Isnull(Stock_Request_Detail_Received.Product_Code,N'') NOT IN (SELECT PRODUCT_CODE FROM Items)
	or 
	Isnull(Stock_Request_Detail_Received.Product_Code,N'') in (select product_code from Items where active = 0)
)

