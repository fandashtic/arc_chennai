CREATE procedure sp_filter_batchinfo_FMCG (@ItemCode nvarchar(15))        
as        
DECLARE @PRICE_OPTION int        
DECLARE @SALE_PRICE Decimal(18,6)        
SELECT @PRICE_OPTION = ISNULL(Price_Option, 0), @SALE_PRICE = ISNULL(Sale_Price, 0) 
FROM Items, ItemCategories 
WHERE Items.CategoryID = ItemCategories.CategoryID 
and Items.Product_Code = @ItemCode

SELECT Batch_Number, Expiry, SUM(Quantity), 
case @PRICE_OPTION 
when 1 then 
	Max(IsNull(Batch_Products.SalePrice, 0))
else
	(CASE isnull(Free, 0)
	WHEN 1 THEN
	0        
	ELSE        
	@SALE_PRICE 
	END)        
end, PKD, isnull(Free, 0) 
FROM Batch_Products
WHERE Batch_Products.Product_Code = @ITEMCODE And Quantity > 0 And ISNULL(Damage, 0) = 0        
GROUP BY isnull(Free, 0), Batch_Number, IsNull(Batch_Products.SalePrice, 0), Expiry, PKD  
HAVING SUM(Quantity) > 0     
Order By IsNull(Free, 0), IsNull(Expiry,'9999'), PKD, Min(Batch_Code) 



