CREATE procedure [dbo].[sp_rec_SOInfo](@SONUMBER INT)

AS

SELECT SODate, DeliveryDate, Vendors.Vendor_Name, SOAbstractReceived.Value, 
SOAbstractReceived.BillingAddress, SOAbstractReceived.ShippingAddress, 
SOAbstractReceived.RefNumber, CreditTerm.Description, SOAbstractReceived.POReference,
SOAbstractReceived.VendorID, SOAbstractReceived.DocumentID, SOAbstractReceived.Status
FROM SOAbstractReceived, Vendors, CreditTerm
WHERE SOAbstractReceived.SONumber = @SONUMBER 
AND SOAbstractReceived.VendorID = Vendors.VendorID
AND SOAbstractReceived.CreditTerm *= CreditTerm.CreditID
