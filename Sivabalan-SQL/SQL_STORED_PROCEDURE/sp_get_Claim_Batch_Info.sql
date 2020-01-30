CREATE PROCEDURE sp_get_Claim_Batch_Info(@ITEMCODE NVARCHAR(15), @FLAGS int = 0,
				@Damage int = 0 )
AS

if @Damage = 1
	SELECT Batch_Number, Expiry, SUM(Quantity-isnull(ClaimedAlready,0)), 
	PurchasePrice FROM Batch_Products
	WHERE Batch_Products.Product_Code = @ITEMCODE AND
	(ISNULL(Batch_Products.Flags,0) & @FLAGS) = 0 AND 
	ISNULL(ClaimedAlready,0) < Quantity and 
	ISNULL(Damage,0) IN(1,2)
	GROUP BY Batch_Number, Expiry, PurchasePrice
	HAVING SUM(Quantity) > 0
	Order By IsNull(Expiry,'9999'), MIN(Batch_Code) 
else
	SELECT Batch_Number, Expiry, SUM(Quantity), PurchasePrice, PTR  FROM Batch_Products
	WHERE Batch_Products.Product_Code = @ITEMCODE AND
	(ISNULL(Batch_Products.Flags,0) & @FLAGS) = 0 AND 
	ISNULL(ClaimedAlready,0) < Quantity
	GROUP BY Batch_Number, Expiry, PurchasePrice, PTR 
	HAVING SUM(Quantity) > 0
	Order By IsNull(Expiry,'9999'), MIN(Batch_Code) 


