CREATE PROCEDURE sp_get_ReceivedINV(@INVNUMBER INT)

AS

SELECT InvoiceDate, Vendors.Vendor_Name, InvoiceType, GrossValue, 
DiscountPercentage, DiscountValue, Reference, NetValue, AdditionalDiscount, Freight,
 Vendors.CreditTerm, InvoiceTime
 FROM InvoiceAbstractReceived, Vendors
WHERE InvoiceID = @INVNUMBER 
AND InvoiceAbstractReceived.VendorID = Vendors.VendorID


