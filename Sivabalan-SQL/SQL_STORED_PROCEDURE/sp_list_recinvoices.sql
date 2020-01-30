
CREATE PROCEDURE sp_list_recinvoices(	@VENDOR NVARCHAR(15),
					@FROMDATE DATETIME,
					@TODATE DATETIME)

AS

SELECT  InvoiceAbstractReceived.InvoiceID, InvoiceAbstractReceived.InvoiceDate, 
Vendors.Vendor_Name, InvoiceAbstractReceived.VendorID, InvoiceAbstractReceived.NetValue,
InvoiceAbstractReceived.InvoiceType, InvoiceAbstractReceived.Status, 
InvoiceAbstractReceived.DocumentID
FROM InvoiceAbstractReceived, Vendors
WHERE InvoiceAbstractReceived.VendorID LIKE @VENDOR AND
InvoiceAbstractReceived.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
InvoiceAbstractReceived.VendorID = Vendors.VendorID
ORDER BY Vendors.Vendor_Name, InvoiceAbstractReceived.InvoiceDate

