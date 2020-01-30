CREATE PROCEDURE sp_rate_changed(@ITEMCODE varchar(50), @Batch varchar(20), @NEWRATE float, @CustomerType int)
AS
DECLARE @PriceOption int

Select @PriceOption = Price_Option From ItemCategories, Items
Where ItemCategories.CategoryID = Items.CategoryID And Items.Product_Code = @ITEMCODE

IF @PriceOption = 1
BEGIN
	select 0
END
ELSE
BEGIN
	select 1
END
