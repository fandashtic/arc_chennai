
CREATE PROCEDURE sp_consolidate_customer(@CUSTOMERID nvarchar(50),
					@COMPANY nvarchar(50),
					@CONTACTPERSON nvarchar(50),
					@CUSTOMERCATEGORY nvarchar(50),
					@BILLING_ADDRESS nvarchar(255),
					@SHIPPING_ADDRESS nvarchar(255),
					@CITY nvarchar(50),
					@AREA nvarchar(50),
					@STATE nvarchar(50),
					@COUNTRY nvarchar(50),
					@PHONE nvarchar(50),
					@EMAIL nvarchar(50),
					@DISCOUNT Decimal(18,6),
					@ACTIVE int,
					@DLNUMBER nvarchar(50),
					@TNGST nvarchar(50),
					@CREDITTERM nvarchar(50),
					@DLNUMBER21 nvarchar(50),
					@CST nvarchar(50),
					@CREDITLIMIT Decimal(18,6),
					@ALTERNATECODE nvarchar(20),
					@CREDITRATING nvarchar(50),
					@CHANNELTYPE int)
AS
DECLARE @CATEGORYID int
DECLARE @AREAID int
DECLARE @CITYID int
DECLARE @STATEID int
DECLARE @COUNTRYID int
DECLARE @CREDITID int
IF NOT EXISTS (SELECT CustomerID FROM Customer WHERE AlternateCode = @ALTERNATECODE Or
CustomerID = @CUSTOMERID)
BEGIN
Select @CITYID = CityID FROM City WHERE CityName = @CITY
Select @STATEID = StateID FROM State WHERE State = @STATE
Select @COUNTRYID = CountryID FROM Country WHERE Country = @COUNTRY
Select @AREAID = AreaID FROM Areas WHERE Area = @AREA
Select @CATEGORYID = CategoryID FROM CustomerCategory WHERE CategoryName = @CUSTOMERCATEGORY
Select @CREDITID = CreditID FROM CreditTerm WHERE Description = @CREDITTERM

Insert Customer(CustomerID, Company_Name, ContactPerson, CustomerCategory, BillingAddress, 
ShippingAddress, CityID, CountryID, AreaID, StateID, Phone, Email, Active, Discount,
DLNumber, TNGST, CreditTerm, DLNumber21, CST, CreditLimit, AlternateCode, CreditRating,
ChannelType)
VALUES (@CUSTOMERID, @COMPANY, @CONTACTPERSON, @CATEGORYID, @BILLING_ADDRESS, 
@SHIPPING_ADDRESS, @CITYID, @COUNTRYID, @AREAID, @STATEID, @PHONE, @EMAIL, @ACTIVE, 
@DISCOUNT, @DLNUMBER, @TNGST, @CREDITID, @DLNUMBER21, @CST, @CREDITLIMIT, @ALTERNATECODE,
@CREDITRATING, @CHANNELTYPE)
END

