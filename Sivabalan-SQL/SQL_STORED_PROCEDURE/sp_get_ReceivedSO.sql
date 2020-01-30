
CREATE PROCEDURE sp_get_ReceivedSO(@SONUMBER INT)

AS

SELECT SODate, Vendors.Vendor_Name, DeliveryDate, Value, 
SOAbstractReceived.BillingAddress, SOAbstractReceived.ShippingAddress,
POReference FROM SOAbstractReceived, Vendors
WHERE SONumber = @SONUMBER 
AND SOAbstractReceived.VendorID = Vendors.VendorID

