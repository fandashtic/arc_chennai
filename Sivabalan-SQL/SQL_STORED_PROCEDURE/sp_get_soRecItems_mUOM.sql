Create PROCEDURE sp_get_soRecItems_mUOM(@SONumber int)
AS
SELECT "Item Code"=
Case 
when Items.Product_Code is null then 
	SODetailReceived.Product_Code
else 
	Items.Product_Code end,
ProductName, "Quantity"=dbo.GetQtyAsMultiple (SODetailReceived.Product_Code,Sum(SODetailReceived.Quantity)), 
SalePrice,"UOM"='Multiple',"TaxSuffered"=IsNull(SODetailReceived.TaxSuffered,0),IsNull(Discount,0),"UOMID"=SODetailReceived.UOM,
"TaxApplicableON" = ISNULL(TaxApplicableon,0),"TaxPartOff"=Isnull(TaxPartOff,0),"TaxSuffApplicableon"=isnull(TaxSuffApplicableon,0),
"TaxSuffPartOff"=Isnull(TaxSuffPartOff,0)
FROM SODetailReceived, Items
WHERE SODetailReceived.SONumber = @SONumber 
AND SODetailReceived.Product_Code = Items.Alias
AND Items.Active = 1
Group By SODetailReceived.Product_Code,Items.Product_Code,ProductName,SalePrice,
SODetailReceived.TaxSuffered,SODetailReceived.Discount,SODetailReceived.UOM,TaxApplicableON,TaxSuffPartOff,
TaxPartOff,TaxSuffApplicableon
