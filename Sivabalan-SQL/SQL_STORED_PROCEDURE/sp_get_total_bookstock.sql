CREATE PROCEDURE sp_get_total_bookstock(@PRODUCT_CODE nvarchar(15))  
AS  
SELECT SUM(Quantity) FROM Batch_Products   
WHERE  Product_Code = @PRODUCT_CODE 



  


