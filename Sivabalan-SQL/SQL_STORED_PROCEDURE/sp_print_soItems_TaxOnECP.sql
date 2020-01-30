CREATE procedure [dbo].[sp_print_soItems_TaxOnECP](@SONumber int)
AS
SELECT "Item Code" = SODetail.Product_Code, 
"Item Name" = ProductName, 
"Quantity" = Quantity, 
"Sale Price" = SalePrice, 
"Tax Applicable%" = ISNULL(SaleTax, 0) + ISNULL(TaxCode2, 0),
"Discount" = Discount, 
"UOM" = IsNull(UOM1.Description,N''), 
"Pending" = Pending, 
"Tax Suffered%" = ISNULL(SODetail.TaxSuffered, 0),
"Amount" = ((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) +
((((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) + 
(((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100)) * (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100) +
(((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100),
"Tax Applicable Amount" = ((((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) 
+ (((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100)) 
* (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100),
"Tax Suffered Amount" = (((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100),
"Manufacturer Code" = Manufacturer.ManufacturerCode,
"Manufacturer Name" = Manufacturer.Manufacturer_Name,
"Brand" = Brand.BrandName, 
"Category" = ItemCategories.Category_Name,
"Conversion Unit" = ConversionTable.ConversionUnit,
"Conversion Factor" = Items.ConversionFactor,
"Reporting UOM" = IsNull(RUOM.Description,N''),
"Reporting Unit" = Items.ReportingUnit,
"Reporting Unit Qty" = (Quantity / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),
"Conversion Unit Qty" = (Quantity * Items.ConversionFactor),
"Item Desc" = IsNull(Items.Description, N''),
"Description" = IsNull(Items.Description,N''), 
"Item Gross Value" = Quantity * SalePrice,
"Invoice Gross Value" = IsNull(dbo.GetInvoiceGrossValueFromSC(@SONumber, SODetail.Product_Code),0),
"Total Tax Amount"=Round((((SODetail.Quantity * SODetail.SalePrice) - ((SODetail.Quantity * SODetail.SalePrice) * SODetail.Discount / 100))
*(IsNull(SODetail.TaxSuffered,0) + Isnull(SODetail.SaleTax,0) + Isnull(SODetail.TaxCode2,0))/100),2),
SODETAIL.ECP,"Batch"=SoDetail.Batch_Number,
"PriceOption" = ItemCategories.Price_Option,"TrackBatch"= Items.Track_Batches,
"VAT" = isnull(sodetail.vat,0),
"TaxApplicableon" = isnull(sodetail.taxapplicableon,0),
"TaxPartOff" = isnull(sodetail.taxpartoff,0),
"TaxSuffApplicableon" = isnull(sodetail.taxSuffapplicableon,0),
"TaxsuffPartOff" = isnull(sodetail.taxsuffpartoff,0)
FROM SODetail, Items, UOM As UOM1, Manufacturer, Brand, ItemCategories, ConversionTable, 
UOM As RUOM
WHERE SODetail.SONumber = @SONumber 
AND SODetail.Product_Code = Items.Product_Code 
AND Items.UOM *= UOM1.UOM
And Items.ReportingUOM *= RUOM.UOM
AND Items.ManufacturerID = Manufacturer.ManufacturerID
AND Items.CategoryID = ItemCategories.CategoryID
AND Items.BrandID = Brand.BrandID
AND Items.ConversionUnit *= ConversionTable.ConversionID
Order by SoDetail.Serial Asc
