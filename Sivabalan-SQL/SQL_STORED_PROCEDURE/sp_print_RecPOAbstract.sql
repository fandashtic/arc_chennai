CREATE PROCEDURE sp_print_RecPOAbstract(@PONo INT)
AS
SELECT "PO Date" = PODate, "Required Date" = RequiredDate, 
"Customer" = Customer.Company_Name, "Value" = POAbstractReceived.Value,
"Billing Address" = POAbstractReceived.BillingAddress, 
"Shipping Address" = POAbstractReceived.ShippingAddress, 
"PO Reference" = PO.Prefix + CAST(POReference AS nvarchar), 
"PO No" = POPrefix + CAST(DocumentID AS nvarchar)
FROM POAbstractReceived, Customer, VoucherPrefix GRN, VoucherPrefix PO
WHERE POAbstractReceived.PONumber = @PONo 
AND POAbstractReceived.CustomerID = Customer.CustomerID
AND PO.TranID = 'PURCHASE ORDER'
AND GRN.TranID = 'GOODS RECEIVED NOTE'
