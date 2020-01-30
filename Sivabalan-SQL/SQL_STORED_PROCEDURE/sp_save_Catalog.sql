
CREATE PROCEDURE sp_save_Catalog(@ITEMCODE NVARCHAR(15),
@DESC NVARCHAR(255), @PRICE Decimal(18,6), @UOM INT, @MRP Decimal(18,6), @PURCHASED_AT INT)

AS
Declare @PriceOption int
IF @PURCHASED_AT = 1
	UPDATE Items SET Description = @DESC, Purchase_Price = @PRICE,
	UOM = @UOM, MRP = @MRP, PTS = @PRICE WHERE Product_Code = @ITEMCODE
ELSE IF @PURCHASED_AT = 2
	UPDATE Items SET Description = @DESC, Purchase_Price = @PRICE,
	UOM = @UOM, MRP = @MRP, PTR = @PRICE WHERE Product_Code = @ITEMCODE

--To Update Price for NonCSP Items
select @priceOption=price_option from ItemCategories where CategoryId in( select categoryId from items where Product_code=@ItemCode)
If @PriceOption = 0
Begin
	UPDATE Batch_Products SET PTS = Item.PTS,PTR = Item.PTR from Batch_Products Batch,Items Item
	WHERE Batch.Product_Code = Item.PRODUCT_CODE and Batch.Product_Code = @ITEMCODE 
	and Isnull([free],0) <> 1
End




