
CREATE PROCEDURE sp_get_AlertPO

AS

SELECT PONumber, PODate, POAbstract.VendorID, Vendors.Vendor_Name,
RequiredDate 
FROM POAbstract, Vendors 
WHERE Status & 192 = 0 
AND POAbstract.VendorID = Vendors.VendorID
AND POAbstract.RequiredDate <= getdate()
ORDER BY POAbstract.RequiredDate, POAbstract.PONumber, POAbstract.PODate

SELECT PONumber, PODate, POAbstractReceived.CustomerID, 
Customer.Company_Name, RequiredDate 
FROM POAbstractReceived, Customer
WHERE Status & 192 = 0
AND POAbstractReceived.CustomerID = Customer.CustomerID
AND POAbstractReceived.RequiredDate <= getdate()
ORDER BY POAbstractReceived.RequiredDate, POAbstractReceived.PONumber,
POAbstractReceived.PODate

SELECT SONumber, SODate, SOAbstract.CustomerID, Customer.Company_Name,
DeliveryDate
FROM SOAbstract, Customer
WHERE Status & 192 = 0
AND SOAbstract.CustomerID = Customer.CustomerID
AND SOAbstract.DeliveryDate <= getdate()
ORDER BY SOAbstract.DeliveryDate, SOAbstract.SONumber, SOAbstract.SODate

