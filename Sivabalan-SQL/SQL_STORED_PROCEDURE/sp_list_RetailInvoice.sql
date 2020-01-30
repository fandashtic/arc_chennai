CREATE PROCEDURE sp_list_RetailInvoice(@CUSTID INT, @FROMDATE DATETIME, 
				       @TODATE DATETIME,
					@STATUS int)
AS
IF @STATUS = 128
BEGIN
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID, 
Cash_Customer.CustomerName, NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType
FROM Cash_Customer, InvoiceAbstract
WHERE InvoiceAbstract.CustomerID = Cash_Customer.CustomerID
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.CustomerID = @CUSTID
AND InvoiceAbstract.InvoiceType = 2
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID
END
ELSE IF @STATUS = 256
BEGIN
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID, 
Cash_Customer.CustomerName, NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType
FROM Cash_Customer, InvoiceAbstract
WHERE InvoiceAbstract.CustomerID = Cash_Customer.CustomerID
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.CustomerID = @CUSTID
AND InvoiceAbstract.InvoiceType = 2 AND (Status & 128) = 0
AND IsNull(InvoiceAbstract.Status, 0) & 256 = 0
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID
END
ELSE
BEGIN
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID, 
Cash_Customer.CustomerName, NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType
FROM Cash_Customer, InvoiceAbstract
WHERE InvoiceAbstract.CustomerID = Cash_Customer.CustomerID
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.CustomerID = @CUSTID
AND InvoiceAbstract.InvoiceType = 2 AND (Status & 128) = 0
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID
END







