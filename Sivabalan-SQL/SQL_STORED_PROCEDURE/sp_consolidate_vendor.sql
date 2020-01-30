
CREATE PROCEDURE sp_consolidate_vendor (@VENDORID nvarchar(50),
					@VENDOR nvarchar(50),
					@CONTACTPERSON nvarchar(50),
					@ADDRESS nvarchar(255),
					@CITY nvarchar(50),
					@STATE nvarchar(50),
					@COUNTRY nvarchar(50),
					@ZIP int,
					@FAX nvarchar(50),
					@PHONE nvarchar(50),
					@EMAIL nvarchar(50),
					@ACTIVE int,
					@ALTERNATECODE nvarchar(20))
AS
DECLARE @CITYID int
DECLARE @STATEID int
DECLARE @COUNTRYID int
IF NOT EXISTS (SELECT VendorID FROM Vendors WHERE AlternateCode = @ALTERNATECODE Or 
VendorID = @VENDORID )
BEGIN
Select @CITYID = CityID FROM City WHERE CityName = @CITY
Select @STATEID = StateID FROM State WHERE State = @STATE
Select @COUNTRYID = CountryID FROM Country WHERE Country = @COUNTRY
Insert Vendors(VendorID, Vendor_Name, ContactPerson, Address, CityID, StateID, 
CountryID, Zip, Fax, Phone, Email, Active, AlternateCode)
VALUES (@VENDORID, @VENDOR, @CONTACTPERSON, @ADDRESS, @CITYID, @STATEID, 
@COUNTRYID, @ZIP, @FAX, @PHONE, @EMAIL, @ACTIVE, @ALTERNATECODE)
END

