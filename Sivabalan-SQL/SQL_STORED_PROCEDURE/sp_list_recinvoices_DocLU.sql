CREATE PROCEDURE sp_list_recinvoices_DocLU(@FromDocID int,
					   @ToDocID int)
AS
SELECT  InvoiceAbstractReceived.InvoiceID, InvoiceAbstractReceived.InvoiceDate, 
Vendors.Vendor_Name, InvoiceAbstractReceived.VendorID, InvoiceAbstractReceived.NetValue,
InvoiceAbstractReceived.InvoiceType, InvoiceAbstractReceived.Status, 
InvoiceAbstractReceived.DocumentID
FROM InvoiceAbstractReceived, Vendors
WHERE dbo.GetTrueVal(InvoiceAbstractReceived.DocumentID) BETWEEN @FromDocID AND @ToDocID AND
InvoiceAbstractReceived.VendorID = Vendors.VendorID
ORDER BY Vendors.Vendor_Name, InvoiceAbstractReceived.InvoiceDate
