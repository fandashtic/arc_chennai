
CREATE PROCEDURE sp_get_ActualStock(@ITEM_CODE nvarchar(15))

AS
DECLARE @PRICEOPTION int

SELECT @PRICEOPTION = Price_Option FROM ItemCategories, Items WHERE Product_Code = @ITEM_CODE AND ItemCategories.CategoryID = Items.CategoryID

IF @PRICEOPTION = 1
BEGIN
SELECT Batch_Products.Product_Code AS "ProductCode", ProductName, Batch_Number, Expiry, SUM(Quantity), 
SUM(Quantity * PurchasePrice) AS "Value", PurchasePrice, ISNULL(SalePrice, 0) FROM Batch_Products, Items 
WHERE Batch_Products.Product_Code = Items.Product_Code 
AND Batch_Products.Product_Code = @ITEM_CODE 
GROUP BY Batch_Products.Product_Code, ProductName, Batch_Number, Expiry, PurchasePrice, 
SalePrice
END
ELSE
BEGIN
SELECT Batch_Products.Product_Code AS "ProductCode", ProductName, Batch_Number, Expiry, SUM(Quantity), 
SUM(Quantity * PurchasePrice) AS "Value", PurchasePrice, ISNULL(Sale_Price, 0) FROM Batch_Products, Items 
WHERE Batch_Products.Product_Code = Items.Product_Code 
AND Batch_Products.Product_Code = @ITEM_CODE 
GROUP BY Batch_Products.Product_Code, ProductName, Batch_Number, Expiry, PurchasePrice, Sale_Price
END

