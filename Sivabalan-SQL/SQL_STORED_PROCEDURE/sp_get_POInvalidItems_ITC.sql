Create PROCEDURE sp_get_POInvalidItems_ITC(@PONumber INT)    
AS    
SELECT PODetailReceived.Product_Code   
FROM PODetailReceived  
WHERE PONumber = @PONumber AND   
(
	Isnull(PODetailReceived.Product_Code,N'') NOT IN (SELECT PRODUCT_CODE FROM Items)
	or 
	Isnull(PODetailReceived.Product_Code,N'') in (select product_code from Items where active = 0)
)

