
CREATE PROCEDURE sp_import_item(@ITEM_CODE nvarchar(15),
				@ITEM_NAME nvarchar(30),
				@MANUFACTURER nvarchar(30),
				@BRAND nvarchar(30),
				@CATEGORY nvarchar(30),
				@UOM nvarchar(50),
				@PURCHASED_AT int,
				@PTS Decimal(18,6),
				@PTR Decimal(18,6),
				@ECP Decimal(18,6),
				@SALE_TAX nvarchar(30),
				@STOCKNORM Decimal(18,6),
				@LOTSIZE Decimal(18,6),
				@TRACK_BATCHES int,
				@TRACK_PKD int,
				@CONVERSION_FACTOR Decimal(18,6),
				@CONVERSION_UNIT nvarchar(50),
				@SALEID int = 2,
				@TAXSUFFERED nvarchar(50),
				@REPORTINGUOM nvarchar(50),
				@REPORTING_UNIT Decimal(18,6))
as
DECLARE @ManufacturerID int
DECLARE @BrandID int
DECLARE @CategoryID int
DECLARE @UomID int
DECLARE @PurchasePrice Decimal(18,6)
DECLARE @TaxID int
DECLARE @TaxID2 int
DECLARE @VTB int
DECLARE @ConversionID int
DECLARE @ReportUOMID int

IF @PURCHASED_AT = 1 set @PurchasePrice = @PTS
IF @PURCHASED_AT = 2 set @PurchasePrice = @PTR
SET @VTB = @TRACK_BATCHES
IF @TRACK_PKD = 1 set @TRACK_BATCHES = 1
IF EXISTS(SELECT ManufacturerID FROM Manufacturer WHERE Manufacturer_Name = @MANUFACTURER)
BEGIN
	SELECT @ManufacturerID = ManufacturerID FROM Manufacturer WHERE Manufacturer_Name = @MANUFACTURER
END
ELSE
BEGIN
	Insert Into Manufacturer(Manufacturer_Name, Active) Values(@MANUFACTURER, 1)
	SELECT @ManufacturerID = @@IDENTITY
END
IF EXISTS(SELECT BrandID FROM Brand WHERE BrandName = @BRAND)
BEGIN
	SELECT @BrandID = BrandID FROM Brand WHERE BrandName = @BRAND
END
ELSE
BEGIN
	Insert Into Brand(ManufacturerID, BrandName, Active) Values(@ManufacturerID, @BRAND, 1)
	SELECT @BrandID = @@IDENTITY
END
SELECT @CategoryID = CategoryID FROM ItemCategories WHERE Category_Name = @CATEGORY

IF EXISTS(SELECT UOM FROM UOM WHERE Description = @UOM)
BEGIN
	SELECT @UomID = UOM FROM UOM WHERE Description = @UOM
END
ELSE
BEGIN
	Insert Into UOM(Description, Active) Values(@UOM, 1)
	SELECT @UomID = @@IDENTITY
END

IF EXISTS(SELECT Tax_Code FROM Tax WHERE Percentage = @SALE_TAX)
BEGIN
	SELECT @TaxID = Tax_Code FROM Tax WHERE Percentage = @SALE_TAX
END
ELSE
BEGIN
	Insert Into Tax(Tax_Description, Percentage, Active) Values(CAST(@SALE_TAX AS nvarchar) + '%', @SALE_TAX, 1)
	SELECT @TaxID = @@IDENTITY
END

IF EXISTS(SELECT Tax_Code FROM Tax WHERE Percentage = @TAXSUFFERED)
BEGIN
	SELECT @TaxID2 = Tax_Code FROM Tax WHERE Percentage = @TAXSUFFERED
END
ELSE
BEGIN
	Insert Into Tax(Tax_Description, Percentage, Active) Values(CAST(@TAXSUFFERED AS nvarchar) + '%', @TAXSUFFERED, 1)
	SELECT @TaxID2 = @@IDENTITY
END

IF EXISTS(SELECT ConversionID FROM ConversionTable WHERE ConversionUnit = @CONVERSION_UNIT)
BEGIN
	SELECT @ConversionID = ConversionID FROM ConversionTable WHERE ConversionUnit = @CONVERSION_UNIT
END
ELSE
BEGIN
	Insert Into ConversionTable(ConversionUnit) Values(@CONVERSION_UNIT)
	SELECT @ConversionID = @@IDENTITY
END

IF EXISTS(SELECT UOM FROM UOM WHERE Description = @REPORTINGUOM)
BEGIN
	SELECT @ReportUOMID = UOM FROM UOM WHERE Description = @REPORTINGUOM
END
ELSE
BEGIN
	Insert Into UOM(Description, Active) Values(@REPORTINGUOM, 1)
	SELECT @ReportUOMID = @@IDENTITY
END

Insert Into Items(Product_Code, ProductName, CategoryID, ManufacturerID, BrandID, UOM, Purchase_Price, Sale_Price, Purchased_At, PTS, PTR, ECP, MRP, Sale_Tax, TaxSuffered, StockNorm, MinOrderQty, Track_Batches, Virtual_Track_Batches, ConversionFactor, ConversionUnit, Active, SaleID, Alias, ReportingUOM, ReportingUnit, TrackPKD)
values(@ITEM_CODE, @ITEM_NAME, @CategoryID, @ManufacturerID, @BrandID, @UomID, @PurchasePrice, @ECP, @PURCHASED_AT, @PTS, @PTR, @ECP, @ECP, @TaxID, @TaxID2, @STOCKNORM, @LOTSIZE, @TRACK_BATCHES, @VTB, @CONVERSION_FACTOR, @conversionID, 1, @SALEID, @ITEM_CODE, @ReportUOMID, @REPORTING_UNIT, @TRACK_PKD)

