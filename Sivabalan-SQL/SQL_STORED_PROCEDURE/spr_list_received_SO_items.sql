CREATE procedure [dbo].[spr_list_received_SO_items](@SONUMBER INT)
AS
SELECT  Items.Product_Code, "Item Code" = Items.Product_Code, Quantity, 
	"Sale Price" = SalePrice, "Sale Tax" = SaleTax,"Discount %"=Discount
FROM    SODetailReceived, Items
WHERE	SONumber = @SONUMBER AND
	SODetailReceived.Product_Code *= Items.Alias
