CREATE PROCEDURE sp_print_SalesReturnAbstract(@INVOICEID INT)

AS

SELECT "Invoice Date" = InvoiceDate, "CustomerID" = Customer.CustomerID, 
"Customer" = Company_Name, 
"Address" = InvoiceAbstract.BillingAddress, 
"Gross Value" = GrossValue, 
"Invoice ID" = Inv.Prefix + CAST(DocumentID AS nvarchar),
"TIN Number" = TIN_Number
FROM InvoiceAbstract, Customer, VoucherPrefix Inv
WHERE InvoiceID = @INVOICEID AND InvoiceType = 4 
AND InvoiceAbstract.CustomerID = Customer.CustomerID
AND Inv.TranID = 'SALES RETURN'


