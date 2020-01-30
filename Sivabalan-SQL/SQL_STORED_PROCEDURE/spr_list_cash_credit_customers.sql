
CREATE PROCEDURE spr_list_cash_credit_customers(@CREDITID int,
						@FROMDATE datetime,
						@TODATE datetime)
AS
SELECT 	InvoiceAbstract.CustomerID, "Customer ID"=InvoiceAbstract.CustomerID, 
	"Customer Name"=Customer.Company_Name, "Gross Sales (%c)"=Sum(NetValue)
FROM 	InvoiceAbstract, Customer
WHERE 	InvoiceAbstract.CreditTerm = @CREDITID AND
	InvoiceAbstract.InvoiceType in (1, 3) AND
	(InvoiceAbstract.Status & 128) = 0 AND
	InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
	InvoiceAbstract.CustomerID = Customer.CustomerID
GROUP BY InvoiceAbstract.CustomerID, Customer.Company_Name

