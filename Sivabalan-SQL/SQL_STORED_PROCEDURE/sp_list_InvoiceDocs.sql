CREATE PROCEDURE sp_list_InvoiceDocs(@CUSTOMERID NVARCHAR(15), @FROMDATE DATETIME,
@TODATE DATETIME, @STATUS INT)
AS
SELECT InvoiceID, InvoiceDate, 
Status = dbo.LookupDictionaryItem(CASE Status & 32 WHEN 32 THEN 'Sent' ELSE 'Not Sent' END, Default), 
Customer.Company_Name, InvoiceAbstract.CustomerID
InvoiceType , DocumentID
FROM InvoiceAbstract, Customer 
WHERE InvoiceAbstract.CustomerID like @CUSTOMERID 
AND Status & 128 = 0 AND Status & @STATUS = 0 AND InvoiceType in (1,3)
And (status & 1024)=0 --The status 1024 is set for an implicit invoice when an customerpointredemption is made.
AND (InvoiceDate BETWEEN @FROMDATE AND @TODATE)
AND InvoiceAbstract.CustomerID = Customer.CustomerID
ORDER BY Customer.Company_Name, InvoiceDate

