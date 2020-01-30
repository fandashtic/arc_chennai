CREATE procedure spr_list_cash_collections(@FromDate datetime,  
        @ToDate datetime)  
as  
select DocumentID, "Collection ID" =  Collections.FullDocID, "Document Ref" = DocReference,  
"Date" = Collections.DocumentDate, "CustomerID" = Collections.CustomerID,
"Customer" = Customer.Company_Name, "Amount" = Value  
from Collections, Customer  
where Collections.CustomerID = Customer.CustomerID and  
Collections.PaymentMode = 0 and 
(IsNull(Collections.Status, 0) & 64) = 0 And
(IsNull(Collections.Status,0) & 128) = 0 And 
Collections.DocumentDate Between @FromDate And @ToDate
Order By Collections.DocumentDate



