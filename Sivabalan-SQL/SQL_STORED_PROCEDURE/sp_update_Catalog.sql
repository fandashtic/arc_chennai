
CREATE PROCEDURE sp_update_Catalog(@ITEMCODE NVARCHAR(15),
@DESC NVARCHAR(255), @PRICE Decimal(18,6), @UOM INT, @PURCHASED_AT INT)

AS
Declare @PriceOption Int
IF @PURCHASED_AT = 1
	UPDATE Items SET Description = @DESC, Purchase_Price = @PRICE,
	UOM = @UOM, PTS = @PRICE WHERE Product_Code = @ITEMCODE
ELSE IF @PURCHASED_AT = 2
	UPDATE Items SET Description = @DESC, Purchase_Price = @PRICE,
	UOM = @UOM, PTR = @PRICE WHERE Product_Code = @ITEMCODE

select @priceOption=price_option from ItemCategories where CategoryId in( select categoryId from items where Product_code=@ItemCode)
If @PriceOption = 0
Begin
	UPDATE Batch_Products SET PTS = Item.PTS,PTR = Item.PTR from Batch_Products Batch,Items Item
	WHERE Batch.Product_Code = Item.PRODUCT_CODE and Batch.Product_Code = @ITEMCODE 
	and	Isnull(Batch.[free],0) <> 1
End


