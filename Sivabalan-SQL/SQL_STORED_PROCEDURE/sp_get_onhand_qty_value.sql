
CREATE PROCEDURE sp_get_onhand_qty_value(@PRODUCT_CODE nvarchar(15))
AS
SELECT SUM(Quantity) as OnHandQty, SUM(ISNULL(Quantity, 0) * ISNULL(PurchasePrice, 0)) as OnHandValue
FROM Batch_Products
WHERE Product_Code = @PRODUCT_CODE


