CREATE procedure [dbo].[spc_customers]
AS
SELECT CustomerID, Company_Name, ContactPerson, CategoryName, BillingAddress, 
ShippingAddress, CityName, Area, State, Country, Phone, Email, Discount, Customer.Active,
DLNumber, TNGST, CreditTerm.Description, DLNumber21, CST, CreditLimit, Alternatecode,
CreditRating, ChannelType
FROM Customer, CustomerCategory, City, Areas, Country, State, CreditTerm
WHERE	Customer.CustomerCategory *= CustomerCategory.CategoryID AND 
	Customer.CityID *= City.CityID AND
	Customer.StateID *= State.StateID AND
	Customer.CountryID *= Country.CountryID AND 
	Customer.AreaID *= Areas.AreaID AND
	Customer.CreditTerm *= CreditTerm.CreditID
