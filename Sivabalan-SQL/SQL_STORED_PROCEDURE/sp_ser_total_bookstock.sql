CREATE PROCEDURE sp_ser_total_bookstock(@PRODUCT_CODE nvarchar(15))
AS
SELECT SUM(Quantity) FROM Batch_Products 
WHERE 	Product_Code = @PRODUCT_CODE AND 
	(Expiry IS NULL OR Expiry >= GetDate()) AND
	ISNULL(Damage, 0) = 0

