CREATE PROCEDURE Spr_get_StockOutDetail      
(      
 @StockOutID Int      
)      
AS      
BEGIN      
 SELECT 1,"Item Code" = ProductCode, "Item Name" = ProductName, "Quantity" = (Quantity-TotalStock)     
 FROM StockOutDetail INNER JOIN Items ON StockOutDetail.ProductCode=Items.Product_Code      
 WHERE StockOutID=@StockOutID      
END  

