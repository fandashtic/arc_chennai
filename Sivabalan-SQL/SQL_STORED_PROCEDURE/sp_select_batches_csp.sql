
CREATE PROCEDURE sp_select_batches_csp(@PRODUCT_CODE nvarchar(15),
 @TRACK_BATCHES int)
AS
SELECT Items.Product_Code,Items.ProductName,Batch_Products.Batch_Number, 
	ISNULL(PurchasePrice, Items.Purchase_Price) ,SalePrice
FROM Batch_Products, Items WHERE Items.Product_Code = @PRODUCT_CODE
 AND Items.Product_Code = Batch_Products.Product_Code
 GROUP BY Items.Product_Code, Items.ProductName, 
Batch_Number, PurchasePrice, SalePrice, Items.Purchase_Price

