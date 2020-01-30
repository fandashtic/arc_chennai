CREATE PROCEDURE sp_print_RecsoAbstract(@SONumber int)
AS
SELECT "SC Date" = SODate, "Delivery Date" = DeliveryDate, 
"Vendor" = Vendors.Vendor_Name, "Value" = SOAbstractReceived.Value,
"Billing Address" = SOAbstractReceived.BillingAddress, 
"Shipping Address" = SOAbstractReceived.ShippingAddress, 
"Credit Term" = CreditTerm.Description, 
"POReference" = PO.Prefix + CAST(POReference AS nvarchar), 
"DocumentID" = DocumentID
FROM SOAbstractReceived, Vendors, CreditTerm, VoucherPrefix PO 
WHERE SONumber = @SONumber AND SOAbstractReceived.VendorID = Vendors.VendorID
AND SOAbstractReceived.CreditTerm = CreditTerm.CreditID
AND PO.TranID = 'PURCHASE ORDER'
