CREATE PROCEDURE sp_list_AllRetailCustomerInvoice(@FROMDATE DATETIME, @TODATE DATETIME, @STATUS int)        
AS      
Declare @WALKINCUSTOMER nVarchar(50)  
set @WALKINCUSTOMER = dbo.LookUpDictionaryItem('WalkIn Customer',default)  
IF @STATUS = 128      
BEGIN      
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID,       
(case when Customer.Company_Name = N'WalkIn Customer' then @WALKINCUSTOMER ELSE Customer.Company_Name End ) as Company_Name ,       
NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType,Balance,isnull(GSTFullDocID,'') as GSTFullDocID      
FROM Customer, InvoiceAbstract      
WHERE InvoiceAbstract.CustomerID = CAST(Customer.CustomerID AS NVARCHAR)      
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE       
AND InvoiceType in(2,5,6)     
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID      
END      
ELSE IF @STATUS = 256      
BEGIN      
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID,       
(case When Customer.Company_Name = N'WalkIn Customer' then @WALKINCUSTOMER ELSE Customer.Company_Name End ) as Company_Name ,            
NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType,Balance,isnull(GSTFullDocID,'') as GSTFullDocID      
FROM Customer, InvoiceAbstract      
WHERE InvoiceAbstract.CustomerID = CAST(Customer.CustomerID AS NVARCHAR)      
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE       
AND InvoiceType = 2 AND (Status & 128) = 0      
AND IsNull(Status, 0) & 256 = 0      
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID      
END      
ELSE      
BEGIN      
SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID,       
(case When Customer.Company_Name = N'WalkIn Customer' then @WALKINCUSTOMER ELSE Customer.Company_Name End ) as Company_Name ,       
NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType, Balance,isnull(GSTFullDocID,'') as GSTFullDocID      
FROM Customer
 Right Outer Join InvoiceAbstract On InvoiceAbstract.CustomerID = CAST(Customer.CustomerID AS NVARCHAR)            
WHERE InvoiceDate BETWEEN @FROMDATE AND @TODATE       
AND InvoiceType in(2,5,6) AND (Status & 128) = 0      
ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID      
END 
  
