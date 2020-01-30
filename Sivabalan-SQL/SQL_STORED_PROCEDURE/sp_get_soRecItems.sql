
CREATE PROCEDURE sp_get_soRecItems(@SONumber int)

AS

SELECT 
case
when Items.Product_Code is null then
SODetailReceived.Product_Code
else
Items.Product_Code
end, ProductName, Quantity, SalePrice, SaleTax,
Discount FROM SODetailReceived, Items
WHERE SODetailReceived.SONumber = @SONumber 
AND SODetailReceived.Product_Code = Items.Alias
AND Items.Active = 1

