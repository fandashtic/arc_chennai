CREATE PROCEDURE [dbo].[sp_get_InvoiceAbstractReceived](@INVOICENO INT)
AS
SELECT InvoiceType, InvoiceDate, InvoiceAbstractReceived.VendorID,
Vendors.Vendor_Name, BillingAddress, ShippingAddress, GrossValue, DiscountPercentage,
DiscountValue, NetValue, NULL, Reference, AdditionalDiscount, Freight,
InvoiceAbstractReceived.CreditTerm, CreditTerm.Description, DocumentID, 
dbo.LookupDictionaryItem(CASE (InvoiceAbstractReceived.Status & 128)
WHEN 128 THEN
'Processed'
ELSE
'Not Processed'
END, Default)
FROM InvoiceAbstractReceived
Inner Join Vendors on InvoiceAbstractReceived.VendorID = Vendors.VendorID
Left Outer Join CreditTerm on InvoiceAbstractReceived.CreditTerm = CreditTerm.CreditID
WHERE 
--InvoiceAbstractReceived.VendorID = Vendors.VendorID
--AND InvoiceAbstractReceived.CreditTerm *= CreditTerm.CreditID
--AND 
InvoiceAbstractReceived.InvoiceID = @INVOICENO
