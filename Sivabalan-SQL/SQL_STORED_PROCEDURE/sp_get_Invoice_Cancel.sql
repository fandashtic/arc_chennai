CREATE PROCEDURE sp_get_Invoice_Cancel (@CustomerID NVARCHAR(15),   
				@FromDate DATETIME, @ToDate DATETIME, @FLAG int = 0)   
AS  

	SELECT InvoiceAbstract.CustomerID AS "CustomerID", Company_Name, InvoiceID, InvoiceDate,   
		NetValue, InvoiceType, DocumentID, ISNULL(Status, 0), Balance, invoicereference,  
		DocReference,DocSerialType,isnull(GSTFullDocID, '') as GSTFullDocID 
	FROM InvoiceAbstract, Customer  
	WHERE InvoiceType in (1,3,4)  
		--AND (InvoiceAbstract.Status & 128) = 0   
		AND InvoiceAbstract.CustomerID = Customer.CustomerID   
		AND InvoiceAbstract.CustomerID like @CustomerID  
		AND InvoiceDate BETWEEN @FromDate AND @ToDate   
		--AND NetValue = ISNULL(Balance, 0)   
		AND (InvoiceAbstract.Status & @FLAG) = 0  
		AND (InvoiceAbstract.Status & 1024) = 0   	  
	ORDER BY InvoiceAbstract.CustomerID  

