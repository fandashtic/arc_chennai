CREATE PROCEDURE sp_print_RecInvAbstract(@INVNO INT)
AS
SELECT "Invoice Date" = InvoiceDate, 
"Vendor" = Vendor_Name, "Gross Value" = GrossValue, 
"Discount%" = DiscountPercentage, "Discount Value" =DiscountValue, 
"Net Value" = NetValue, 
"Addl. Discount" = AdditionalDiscount, "Freight" = Freight, "DocumentID" = DocumentID 
FROM InvoiceAbstractReceived, Vendors
WHERE InvoiceID = @INVNO 
AND InvoiceAbstractReceived.VendorID = Vendors.VendorID
