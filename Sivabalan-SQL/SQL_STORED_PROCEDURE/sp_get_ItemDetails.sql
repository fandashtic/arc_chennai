CREATE procedure  [dbo].[sp_get_ItemDetails](@ITEMCODE NVARCHAR(15))

AS

SELECT Items.ProductName, Items.Description, UOM.Description, Sale_Price, MRP
FROM Items, UOM 
WHERE Items.Product_Code = @ITEMCODE AND Items.UOM *= UOM.UOM
