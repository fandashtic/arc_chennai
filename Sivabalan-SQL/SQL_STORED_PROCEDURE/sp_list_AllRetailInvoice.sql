CREATE procedure [dbo].[sp_list_AllRetailInvoice](@FROMDATE DATETIME, @TODATE DATETIME, @STATUS int)

AS
Declare @NOCUSTOMER as NVarchar(20)

Set @NOCUSTOMER = dbo.LookupDictionaryItem(N'No Customer', Default)

IF @STATUS = 128
BEGIN
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID, 
CASE ISNULL(Cash_Customer.CustomerName,N'') 
WHEN N'' THEN 
	@NOCUSTOMER
ELSE 
	Cash_Customer.CustomerName
END, 
NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType
FROM Cash_Customer, InvoiceAbstract
WHERE InvoiceAbstract.CustomerID *= CAST(Cash_Customer.CustomerID AS NVARCHAR)
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE 
AND InvoiceType = 2
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID
END
ELSE IF @STATUS = 256
BEGIN
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID, 
CASE ISNULL(Cash_Customer.CustomerName,N'') 
WHEN N'' THEN 
	@NOCUSTOMER
ELSE 
	Cash_Customer.CustomerName
END, 
NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType
FROM Cash_Customer, InvoiceAbstract
WHERE InvoiceAbstract.CustomerID *= CAST(Cash_Customer.CustomerID AS NVARCHAR)
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE 
AND InvoiceType = 2 AND (Status & 128) = 0
AND IsNull(Status, 0) & 256 = 0
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID
END
ELSE
BEGIN
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID, 
CASE ISNULL(Cash_Customer.CustomerName,N'') 
WHEN N'' THEN 
	@NOCUSTOMER
ELSE 
	Cash_Customer.CustomerName
END, 
NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType
FROM Cash_Customer, InvoiceAbstract
WHERE InvoiceAbstract.CustomerID *= CAST(Cash_Customer.CustomerID AS NVARCHAR)
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE 
AND InvoiceType = 2 AND (Status & 128) = 0
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID
END
