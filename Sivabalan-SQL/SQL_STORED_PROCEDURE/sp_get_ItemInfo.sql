CREATE procedure [dbo].[sp_get_ItemInfo](@ALIASCODE nvarchar(15))

AS

SELECT ItemCategories.Category_Name, Manufacturer.Manufacturer_Name,
Vendors.Vendor_Name, Brand.BrandName, Track_Batches, Tax.Tax_Description, 
Purchased_AT, Items.SaleID, Tax_Suffered.Tax_Description, Product_Code, TrackPKD, 
Virtual_Track_Batches
FROM Items, ItemCategories, Manufacturer, Vendors, Brand, Tax, Tax as Tax_Suffered
WHERE Items.Alias = @ALIASCODE 
AND Items.Preferred_Vendor *= Vendors.VendorID
AND Items.ManufacturerID *= Manufacturer.ManufacturerID
AND Items.CategoryID *= ItemCategories.CategoryID
AND Items.Sale_Tax *= Tax.Tax_Code
AND Items.BrandID *= Brand.BrandID
AND Items.TaxSuffered *= Tax_Suffered.Tax_Code
