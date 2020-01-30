CREATE PROCEDURE [dbo].[spr_list_vendor_detail](@VENDOR nvarchar(15))
AS
SELECT  VendorID, Address, Phone, "City" = City.CityName, "State" = State.State, 
	"Country" = Country.Country, 
	"PinCode" = case Zip
	WHEN 0 THEN NULL
	ELSE Zip
	END, Fax, Email,"Credit Term" = CreditTerm.Description, "Creation Date" = CreationDate,
        "TIN Number" = Vendors.TIN_Number
FROM 	Vendors
Left Outer Join  City On Vendors.CityID = City.CityID
Left Outer Join State On Vendors.StateID = State.StateID
Left Outer Join Country On Vendors.CountryID = Country.CountryID 
Left Outer Join CreditTerm On Vendors.CreditTerm = CreditTerm.CreditID
WHERE  VendorID = @VENDOR

