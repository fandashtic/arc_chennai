
CREATE PROCEDURE spr_list_received_invoices(@FROM_DATE datetime,
					    @TO_DATE datetime)
AS
SELECT  InvoiceID, 
	"InvoiceID" = DocumentID, 
	"Invoice Date" = InvoiceDate, "Vendor" = Vendors.Vendor_Name, 
	"Gross" = GrossValue, "Trade Discount" = DiscountPercentage, "Additional Discount" = AdditionalDiscount,
	Freight, "Net" = NetValue
FROM    InvoiceAbstractReceived, Vendors
WHERE   InvoiceAbstractReceived.VendorID = Vendors.VendorID AND
	InvoiceDate BETWEEN @FROM_DATE AND @TO_DATE

