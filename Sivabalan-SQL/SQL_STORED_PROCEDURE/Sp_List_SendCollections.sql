CREATE PROCEDURE Sp_List_SendCollections(@CustomerID NVARCHAR(15), @FROMDATE DATETIME,      
    @TODATE DATETIME,@STATUS INT)      
AS      

Declare @SENT As NVarchar(50)
Declare @NOTSENT As NVarchar(50)

Set @SENT = dbo.LookupDictionaryItem(N'Sent', Default)
Set @NOTSENT = dbo.LookupDictionaryItem(N'Not Sent', Default)

SELECT "CollectionID" = DocumentID, "CollectionDate" = DocumentDate, 
"Status" = Case IsNull(Status,0) & 32 WHEN 32 THEN @SENT ELSE @NOTSENT END, 
"CustomerName" = Company_Name, DocumentID,DocumentID,Status, Balance, Value
FROM Collections, Customer
WHERE Collections.CustomerID LIKE @CustomerID
AND Collections.CustomerID = Customer.CustomerID
AND IsNull(Status,0) & 128 = 0 AND IsNull(Status,0) & @STATUS = 0   
AND DocumentDate BETWEEN @FROMDATE AND @TODATE      
And CustomerCategory not in (4,5)
ORDER BY "CustomerName", "CollectionDate"      







