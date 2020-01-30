
CREATE PROCEDURE sp_get_soRecItems_Pidilite(@SONumber int)

AS

SELECT 
Case 
when Items.Product_Code is null then 
	SODetailReceived.Product_Code
else 
	Items.Product_Code end,
ProductName, "Quantity"=dbo.GetQtyAsMultiple (SODetailReceived.Product_Code,Sum(SODetailReceived.Quantity)), 
SalePrice,"UOM"='Multiple'
FROM SODetailReceived, Items
WHERE SODetailReceived.SONumber = @SONumber 
AND SODetailReceived.Product_Code = Items.Alias
AND Items.Active = 1
Group By SODetailReceived.Product_Code,Items.Product_Code,ProductName,SalePrice

