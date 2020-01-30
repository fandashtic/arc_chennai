CREATE PROCEDURE spr_list_expiryitem_detail( @ITEMCODE nvarchar(15),
					   @EXPDATE datetime)
AS
SELECT Batch_Number, "Batch" = Batch_Number, "Expiry" = Expiry, "Quantity" = Quantity, 
"Value" = (PurchasePrice * Quantity) FROM Batch_products
WHERE Product_Code = @ITEMCODE AND Expiry IS NOT NULL AND Expiry <= @EXPDATE
and Quantity > 0
