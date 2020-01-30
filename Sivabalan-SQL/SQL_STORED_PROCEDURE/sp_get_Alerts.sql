
CREATE PROCEDURE sp_get_Alerts

AS

SELECT PONumber, PODate, POAbstract.VendorID, Vendors.Vendor_Name,
RequiredDate, VoucherPrefix.Prefix 
FROM POAbstract, Vendors, VoucherPrefix 
WHERE Status & 192 = 0 
AND POAbstract.VendorID = Vendors.VendorID
AND POAbstract.RequiredDate <= getdate()
AND VoucherPrefix.TranID = 'PURCHASE ORDER'
ORDER BY POAbstract.RequiredDate, POAbstract.PONumber, POAbstract.PODate

SELECT PONumber, PODate, POAbstractReceived.CustomerID, 
Customer.Company_Name, RequiredDate, VoucherPrefix.Prefix 
FROM POAbstractReceived, Customer, VoucherPrefix 
WHERE Status & 192 = 0
AND POAbstractReceived.CustomerID = Customer.CustomerID
AND POAbstractReceived.RequiredDate <= getdate()
AND VoucherPrefix.TranID = 'PURCHASE ORDER'
ORDER BY POAbstractReceived.RequiredDate, POAbstractReceived.PONumber,
POAbstractReceived.PODate

SELECT SONumber, SODate, SOAbstract.CustomerID, Customer.Company_Name,
DeliveryDate, VoucherPrefix.Prefix 
FROM SOAbstract, Customer, VoucherPrefix 
WHERE Status & 192 = 0
AND SOAbstract.CustomerID = Customer.CustomerID
AND SOAbstract.DeliveryDate <= getdate()
AND VoucherPrefix.TranID = 'SALE ORDER'
ORDER BY SOAbstract.DeliveryDate, SOAbstract.SONumber, SOAbstract.SODate


