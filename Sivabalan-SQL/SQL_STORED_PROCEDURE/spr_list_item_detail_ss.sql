CREATE procedure [dbo].[spr_list_item_detail_ss](@PRODUCT_CODE nvarchar(15))
AS

Declare @PRICETOSTOCKIST As NVarchar(50)
Declare @PRICETORETAILER As NVarchar(50)
Declare @YES As NVarchar(50)
Declare @NO As NVarchar(50)

Set @PRICETOSTOCKIST = dbo.LookupDictionaryItem(N'Price to Stockist', Default)
Set @PRICETORETAILER = dbo.LookupDictionaryItem(N'Price to Retailer', Default)
Set @YES = dbo.LookupDictionaryItem(N'Yes', Default)
Set @NO = dbo.LookupDictionaryItem(N'No', Default)

SELECT Product_Code, "Preferred Vendor" = Vendors.Vendor_Name, 
	"Manufacturer" = Manufacturer.Manufacturer_Name, "Division" = Brand.BrandName,
	"UOM" = UOM.Description, 
	"Purchased At" = CASE Items.Purchased_At
	WHEN 1 THEN @PRICETOSTOCKIST
	WHEN 2 THEN @PRICETORETAILER
	END,
	"PTSS" = ISNULL(Items.PTS, 0),
	"PTS" = ISNULL(Items.PTR, 0),
	"PTR" = ISNULL(Items.Company_Price, 0),
	"ECP" = ISNULL(Items.ECP, 0),
	"Purchase Price" = ISNULL(Items.Purchase_Price, 0), 
	"MRP" = ISNULL(MRP, 0), 
	"Sale Tax" = Tax.Tax_Description, 
	"StockNorm" = ISNULL(StockNorm, 0), 
	"MOQ" = ISNULL(MinOrderQty, 0),
	"Track Batches" = CASE Items.Track_Batches
	WHEN 0 THEN @NO
	WHEN 1 THEN @YES
	END,
	"Tax Suffered" = Items.TaxSuffered
FROM Items, Vendors, Manufacturer, Brand, UOM, Tax
WHERE   Items.Preferred_Vendor *= Vendors.VendorID
	AND Items.ManufacturerID *= Manufacturer.ManufacturerID AND Items.BrandID *= Brand.BrandID
	AND Items.UOM *= UOM.UOM AND Items.Sale_Tax *= Tax.Tax_Code AND Product_Code = @PRODUCT_CODE
