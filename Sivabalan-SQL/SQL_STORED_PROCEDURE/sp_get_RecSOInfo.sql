
CREATE PROCEDURE sp_get_RecSOInfo

AS

SELECT SONumber, SODate, RefNumber, Vendors.Vendor_Name, 
SOAbstractReceived.VendorID, SOAbstractReceived.Value, SOAbstractReceived.CreationTime, 
SOAbstractReceived.POReference, SOAbstractReceived.DocumentID FROM 
SOAbstractReceived, Vendors
WHERE SOAbstractReceived.Status = 0 
AND SOAbstractReceived.VendorID = Vendors.VendorID
ORDER BY Vendors.Vendor_Name, SOAbstractReceived.SODate

