
CREATE PROCEDURE sp_update_Catalog_fmcg(@ITEMCODE NVARCHAR(15),
@DESC NVARCHAR(255), @PRICE Decimal(18,6), @UOM INT)

AS
	UPDATE Items SET Description = @DESC, Purchase_Price = @PRICE,
	UOM = @UOM WHERE Product_Code = @ITEMCODE

