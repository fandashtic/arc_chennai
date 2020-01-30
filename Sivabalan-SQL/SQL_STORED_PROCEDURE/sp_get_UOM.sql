CREATE procedure [dbo].[sp_get_UOM](@ITEMCODE NVARCHAR(15))

AS

SELECT UOM.Description FROM Items, UOM WHERE Items.Product_Code = @ITEMCODE AND
Items.UOM *= UOM.UOM
