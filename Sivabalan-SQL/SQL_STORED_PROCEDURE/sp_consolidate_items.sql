
CREATE PROCEDURE sp_consolidate_items(@ITEM_CODE nvarchar(15),
				      @ITEM_NAME nvarchar(30),
				      @DESCRIPTION nvarchar(255),
				      @CATEGORY nvarchar(50),
				      @MANUFACTURER nvarchar(50),
				      @BRAND nvarchar(50),
				      @UOM nvarchar(50),
				      @PURCHASE_PRICE Decimal(18,6),
				      @SALE_PRICE Decimal(18,6),
				      @SALE_TAX nvarchar(50),
				      @MRP Decimal(18,6),
				      @VENDOR nvarchar(50),
				      @STOCKNORM Decimal(18,6),
				      @MOQ Decimal(18,6),
				      @TRACK_BATCHES int,
				      @CONVERSION_FACTOR Decimal(18,6),
				      @CONVERSION_UNIT nvarchar(50),
				      @ACTIVE int,
				      @SALEID int,
				      @COMPANYPRICE Decimal(18,6),
				      @PTS Decimal(18,6),
				      @PTR Decimal(18,6),
				      @ECP Decimal(18,6),
				      @PURCHASED_AT int,
				      @COMPANY_MARGIN Decimal(18,6),
				      @STOCKIST_MARGIN Decimal(18,6),
				      @RETAILER_MARGIN Decimal(18,6),
				      @PURCHASE_TAX nvarchar(50),
				      @FORUMCODE nvarchar(20),
				      @REPORTINGUOM nvarchar(50),
				      @REPORTINGUNIT Decimal(18,6),
				      @VIRTUAL_TRACK_BATCHES int)
AS
DECLARE @CATEGORYID int
DECLARE @MANUFACTURERID int
DECLARE @BRANDID int
DECLARE @VENDORID nvarchar(50)
DECLARE @UOMID int
DECLARE @TAXID int
DECLARE @CONVERSIONID int
DECLARE @TAXSUFFERED Decimal(18,6)
DECLARE @REPORTINGUOMID int

IF NOT EXISTS (SELECT Product_Code FROM Items WHERE Alias = @FORUMCODE Or
ProductName = @ITEM_NAME Or Product_Code = @ITEM_CODE)
BEGIN
SELECT @CATEGORYID = CategoryID FROM ItemCategories WHERE Category_Name = @CATEGORY
SELECT @MANUFACTURERID = ManufacturerID FROM Manufacturer WHERE Manufacturer_Name = @MANUFACTURER
SELECT @BRANDID = BrandID FROM Brand WHERE BrandName = @BRAND
SELECT @UOMID = UOM FROM UOM WHERE Description = @UOM
SELECT @TAXID = Tax_Code FROM Tax WHERE Tax_Description = @SALE_TAX
SELECT @VENDORID = VendorID FROM Vendors WHERE Vendor_Name = @VENDOR
SELECT @CONVERSIONID = ConversionID FROM ConversionTable WHERE ConversionUnit = @CONVERSION_UNIT
SELECT @TAXSUFFERED = Tax_Code FROM Tax WHERE Tax_Description = @PURCHASE_TAX
SELECT @REPORTINGUOMID = UOM FROM UOM WHERE Description = @REPORTINGUOM

INSERT INTO ITEMS(Product_Code, ProductName, Description, CategoryID, ManufacturerID, 
BrandID, UOM, Purchase_Price, Sale_Price, Sale_Tax, MRP, Preferred_Vendor, StockNorm, 
MinOrderQty, Track_Batches, ConversionFactor, ConversionUnit, Active, SaleID,
Company_Price, PTS, PTR, ECP, Purchased_At, Company_Margin, Stockist_Margin,
Retailer_Margin, TaxSuffered, Alias, ReportingUOM, ReportingUnit, Virtual_Track_Batches)
VALUES(@ITEM_CODE, @ITEM_NAME, @DESCRIPTION, @CATEGORYID, @MANUFACTURERID, @BRANDID, 
@UOMID, @PURCHASE_PRICE, @SALE_PRICE, @TAXID, @MRP, @VENDORID, @STOCKNORM, @MOQ, 
@TRACK_BATCHES, @CONVERSION_FACTOR, @CONVERSIONID, @ACTIVE, @SALEID, @COMPANYPRICE,
@PTS, @PTR, @ECP, @PURCHASED_AT, @COMPANY_MARGIN, @STOCKIST_MARGIN, @RETAILER_MARGIN,
@TAXSUFFERED, @FORUMCODE, @REPORTINGUOMID, @REPORTINGUNIT, @VIRTUAL_TRACK_BATCHES)
END

