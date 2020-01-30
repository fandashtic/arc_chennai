CREATE procedure [dbo].[spc_vendors]
AS
SELECT VendorID, Vendor_Name, ContactPerson, Address, CityName, State, Country, 
Zip, Fax, Phone, Email, Vendors.Active, AlternateCode
FROM Vendors, City, State, Country
WHERE   Vendors.CityID *= City.CityID AND 
	Vendors.StateID *= State.StateID AND
	Vendors.CountryID *= Country.CountryID
