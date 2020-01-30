CREATE procedure [dbo].[spr_list_item_detail_FMCG](@PRODUCT_CODE nvarchar(15))
AS

Declare @YES As NVarchar(50)
Declare @NO As NVarchar(50)

Set @YES = dbo.LookupDictionaryItem(N'Yes', Default)
Set @NO = dbo.LookupDictionaryItem(N'No', Default)

SELECT Product_Code, "Preferred Vendor" = Vendors.Vendor_Name, 
	"Manufacturer" = Manufacturer.Manufacturer_Name, "Brand" = Brand.BrandName,
	"UOM" = UOM.Description, 
	"Sale Price" = ISNULL(Items.Sale_Price, 0),
	"Purchase Price" = ISNULL(Items.Purchase_Price, 0), 
	"MRP" = ISNULL(MRP, 0), 
	"Sale Tax" = Tax.Tax_Description, 
	"StockNorm" = ISNULL(StockNorm, 0), 
	"MOQ" = ISNULL(MinOrderQty, 0),
	"Track Batches" = CASE Items.Track_Batches
	WHEN 0 THEN @NO
	WHEN 1 THEN @YES
	END,
	"Tax Suffered" = b.Tax_Description
FROM Items, Vendors, Manufacturer, Brand, UOM, Tax, Tax b
WHERE   Items.Preferred_Vendor *= Vendors.VendorID
	AND Items.ManufacturerID *= Manufacturer.ManufacturerID AND Items.BrandID *= Brand.BrandID
	AND Items.UOM *= UOM.UOM AND Items.Sale_Tax *= Tax.Tax_Code AND Product_Code = @PRODUCT_CODE
	And Items.TaxSuffered *= b.Tax_Code
