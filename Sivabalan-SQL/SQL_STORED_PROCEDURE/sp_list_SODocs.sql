CREATE PROCEDURE sp_list_SODocs(@CUSTOMERID NVARCHAR(15), @FROMDATE DATETIME,
@TODATE DATETIME, @STATUS INT)
AS
Declare @SENT As NVarchar(50)
Declare @NOTSENT As NVarchar(50)

Set @SENT = dbo.LookupDictionaryItem(N'Sent', Default)
Set @NOTSENT = dbo.LookupDictionaryItem(N'Not Sent', Default)

SELECT SONumber, SODate, 
Status = CASE  WHEN (Status & 32=32) or (Status & 4=4) THEN @SENT
		ELSE @NOTSENT END,
Customer.Company_Name, SOAbstract.CustomerID, SOAbstract.DocumentID
FROM SOAbstract, Customer 
WHERE SOAbstract.CustomerID LIKE @CUSTOMERID 
AND Status & 128 = 0 AND Status & @STATUS = 0
AND (SODate BETWEEN @FROMDATE AND @TODATE)
AND SOAbstract.CustomerID = Customer.CustomerID
ORDER BY Customer.Company_Name, SODate

