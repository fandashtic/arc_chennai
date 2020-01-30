
CREATE PROCEDURE sp_list_Invoices (@CUSTOMER NVARCHAR(15),@FROMDATE DATETIME,@TODATE DATETIME)    
AS 
  
SELECT InvoiceID, InvoiceDate, Customer.Company_Name,   
InvoiceAbstract.CustomerID, NetValue, InvoiceType, Status,  
DocumentID, Balance,DocReference,DocSerialType ,isnull(GSTFullDocID, '') as GSTFullDocID
FROM InvoiceAbstract, Customer  
WHERE InvoiceAbstract.CustomerID LIKE @CUSTOMER  
AND InvoiceAbstract.CustomerID = Customer.CustomerID  
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE  
And InvoiceType In (1, 3, 4)  
ORDER BY Customer.Company_Name  

