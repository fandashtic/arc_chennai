
CREATE PROCEDURE sp_get_RecInvInfo

AS

SELECT InvoiceID, InvoiceDate, Reference, Vendors.Vendor_Name,
InvoiceAbstractReceived.VendorID, NetValue, CreationTime, DocumentID
FROM InvoiceAbstractReceived, Vendors
WHERE Status = 0 
AND InvoiceAbstractReceived.VendorID = Vendors.VendorID
ORDER BY Vendors.Vendor_Name, InvoiceDate

