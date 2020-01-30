
CREATE PROCEDURE sp_get_item_schemes(@ITEM_CODE nvarchar(15))
AS
SELECT Items.ProductName, Schemes.SchemeDescription FROM Items, Schemes, ItemSchemes
WHERE ItemSchemes.Product_Code = @ITEM_CODE AND ItemSchemes.SchemeID = Schemes.SchemeID
	 AND Items.Product_Code =  ItemSchemes.Product_Code AND Schemes.Active = 1 AND
	getdate() BETWEEN ValidFrom AND ValidTO



