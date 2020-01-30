
CREATE PROCEDURE sp_save_Catalog_fmcg(@ITEMCODE NVARCHAR(15),
@DESC NVARCHAR(255), @PRICE Decimal(18,6), @UOM INT, @MRP Decimal(18,6))

AS

	UPDATE Items SET Description = @DESC, Purchase_Price = @PRICE,
	UOM = @UOM, MRP = @MRP WHERE Product_Code = @ITEMCODE

