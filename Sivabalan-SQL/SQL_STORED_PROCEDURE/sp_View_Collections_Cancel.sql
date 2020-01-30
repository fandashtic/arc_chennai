CREATE Procedure sp_View_Collections_Cancel (@CustomerID nvarchar(15),  
       @FromDate DateTime,  
       @ToDate DateTime)  
As  
Select Customer.Company_Name, Customer.CustomerID, FullDocID, Collections.DocumentDate,   
Value, DocumentID, Balance, Status,"DocID" = Collections.DocumentReference,  
"DocType" = Collections.DocSerialType  
from Collections, Customer  
where Collections.CustomerID = Customer.CustomerID And  
Collections.CustomerID Like @CustomerID And  
Collections.DocumentDate Between @FromDate And @ToDate And  
(IsNull(Collections.Status, 0) & 192) = 0 And  
((IsNull(Status, 0) = 0 Or IsNULL(Status,0) = 2) Or IsNull(Status, 0) = 32)
order by Customer.Company_Name, Collections.DocumentDate 
