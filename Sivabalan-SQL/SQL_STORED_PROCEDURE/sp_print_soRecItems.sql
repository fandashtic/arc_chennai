CREATE procedure [dbo].[sp_print_soRecItems](@SONumber int)
AS
SELECT 
"Item Code" = 
case
when Items.Product_Code is null then
SODetailReceived.Product_Code
else
Items.Product_Code
end, "Item Name" = ProductName, "Quantity" = Quantity, "Sale Price" = SalePrice, 
"Tax" = SaleTax,"Discount" = Discount,
"TaxSuffered"=SODetailReceived.TaxSuffered,"TaxSuffApplicableOn"=TaxSuffApplicableOn,
"TaxSuffPartOff"=TaxSuffPartOff,"TaxApplicableOn"=TaxApplicableOn,"TaxPartOff"=TaxPartOff,
"Vat"=Vat
FROM SODetailReceived, Items
WHERE SODetailReceived.SONumber = @SONumber 
AND SODetailReceived.Product_Code *= Items.Alias
