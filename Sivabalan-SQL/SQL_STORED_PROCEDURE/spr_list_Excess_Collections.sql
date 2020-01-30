CREATE procedure spr_list_Excess_Collections(@FromDate datetime,  
          @ToDate datetime)  
as  
select DocumentID, "Collection ID" = FullDocID, "Document Ref" = DocReference, "Collection Date" = DocumentDate,  
"Customer" = Customer.Company_Name, "Amount" = Value, "Excess" = Balance  
from Collections, Customer  
where Collections.CustomerID = Customer.CustomerID and  
Collections.DocumentDate between @FromDate and @ToDate 
and (IsNull(Collections.Status, 0) & 64) = 0 
And (IsNull(Collections.Status,0) & 128) = 0 
and Balance > 0 



