CREATE PROCEDURE [dbo].[spr_stock_alert]
AS
exec sp_update_orderqty
SELECT  Items.Product_Code, "Item Code" = Items.Product_Code, 
	"Item Name" = Items.ProductName,
	"On Hand Qty" = ISNULL(SUM(Batch_Products.Quantity), 0), 
	"Pending Orders" = ISNULL((SELECT SUM(PODetail.Pending) 
	FROM POAbstract, PODetail 
	WHERE POAbstract.PONumber = PODetail.PONumber AND 
	(POAbstract.Status & 128) = 0 AND 
	PODetail.Product_Code = Items.Product_Code), 0), 
	"OrderQty" = ISNULL(OrderQty, 0), 
	"Stock Norm" = ISNULL(Items.StockNorm, 0),
	"Lot Size" = ISNULL(Items.MinOrderQty, 0)
FROM Items
Left Outer join Batch_Products on Items.Product_Code = Batch_Products.Product_Code
WHERE 
--Items.Product_Code *= Batch_Products.Product_Code AND 
	ISNULL(OrderQty, 0) >= ISNULL(MinOrderQty, 0)
	AND ISNULL(OrderQty, 0) > 0
GROUP BY Items.Product_Code, Items.ProductName, Items.OrderQty, 
	Items.StockNorm, Items.MinOrderQty

