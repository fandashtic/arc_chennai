CREATE PROCEDURE [dbo].[spr_list_brands]
AS

Declare @ACTIVE As NVarchar(50)
Declare @INACTIVE As NVarchar(50)

Set @ACTIVE = dbo.LookupDictionaryItem(N'Active', Default)
Set @INACTIVE = dbo.LookupDictionaryItem(N'Inactive', Default)


SELECT BrandID, "Division" = BrandName, "Manufacturer" = ISNULL(Manufacturer.Manufacturer_Name, N''),
	"Active" = 
	case Brand.Active
	WHEN 1 THEN @ACTIVE
	ELSE @INACTIVE
	END,
	"Creation Date" = Brand.CreationDate
FROM Brand
Left Outer Join Manufacturer ON Brand.ManufacturerID = Manufacturer.ManufacturerID
WHERE Brand.ManufacturerID = Manufacturer.ManufacturerID
