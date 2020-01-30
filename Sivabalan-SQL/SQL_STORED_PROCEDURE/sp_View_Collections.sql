CREATE procedure sp_View_Collections(@CustomerID nvarchar(15),  
      @FromDate datetime,  
      @ToDate datetime)  
as  
select Customer.Company_Name, Customer.CustomerID, FullDocID, Collections.DocumentDate,   
Value, DocumentID, Balance, Status, OriginalRef,  
"DocID" = (Case When Collections.DocumentReference is null then Collections.FullDocID else Collections.DocumentReference end),  
"DocType" = Collections.DocSerialType  
from Collections, Customer  
where Collections.CustomerID = Customer.CustomerID and  
Collections.CustomerID like @CustomerID and  
Collections.DocumentDate between @FromDate and @ToDate   
order by Customer.Company_Name, Collections.DocumentDate  
