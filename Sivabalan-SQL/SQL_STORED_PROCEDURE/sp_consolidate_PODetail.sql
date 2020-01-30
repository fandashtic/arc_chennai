CREATE PROCEDURE sp_consolidate_PODetail(@PONUMBER int)
AS
SELECT Items.Alias, "PO Quantity" = Quantity, 
"Pending Quantity" = Pending,"Purchase Price" = PurchasePrice
FROM PODetail, Items
WHERE PONumber = @PONUMBER AND PODetail.Product_Code = Items.Product_Code

