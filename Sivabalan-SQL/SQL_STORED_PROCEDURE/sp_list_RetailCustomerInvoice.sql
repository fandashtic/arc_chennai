CREATE PROCEDURE sp_list_RetailCustomerInvoice(@CUSTID nvarchar(10), @FROMDATE DATETIME,   
           @TODATE DATETIME,  
           @STATUS int)  
AS  
IF @STATUS = 128  
BEGIN  
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID,   
Customer.Company_Name, NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType,Balance
,isnull(GSTFullDocID,'') as GSTFullDocID  
FROM Customer, InvoiceAbstract  
WHERE InvoiceAbstract.CustomerID = Customer.CustomerID  
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceAbstract.CustomerID = @CUSTID  
AND InvoiceAbstract.InvoiceType In (2,5,6)  
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID  
END  
ELSE IF @STATUS = 256  
BEGIN  
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID,   
Customer.Company_Name, NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType,Balance
,isnull(GSTFullDocID,'') as GSTFullDocID  
FROM Customer, InvoiceAbstract  
WHERE InvoiceAbstract.CustomerID = Customer.CustomerID  
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceAbstract.CustomerID = @CUSTID  
AND InvoiceAbstract.InvoiceType = 2 AND (Status & 128) = 0  
AND IsNull(InvoiceAbstract.Status, 0) & 256 = 0  
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID  
END  
ELSE  
BEGIN  
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID,   
Customer.Company_Name, NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType,Balance
,isnull(GSTFullDocID,'') as GSTFullDocID  
FROM Customer, InvoiceAbstract  
WHERE InvoiceAbstract.CustomerID = Customer.CustomerID  
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceAbstract.CustomerID = @CUSTID  
AND InvoiceAbstract.InvoiceType In (2,5,6) AND (Status & 128) = 0  
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID  
END 

