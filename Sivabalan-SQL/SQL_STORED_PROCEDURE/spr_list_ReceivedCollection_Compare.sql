Create Procedure spr_list_ReceivedCollection_Compare(@FROMDATE DATETIME, @TODATE DATETIME)
as
Select "DocumentID" = Collections.DocumentID, "Received CollectionId" = CollectionsReceived.FullDocID,
"New CollectionID" = Collections.FullDocID,
"Customer Id" = Customer.CustomerId,
"Customer Name" = Customer.Company_Name,
"Received Collection Value" = CollectionsReceived.Value,
"New Collection Value" = Collections.Value,
"Difference" = CollectionsReceived.Value - Collections.Value,
"Branch Forum ID" = BranchForumCode
From CollectionsReceived, Collections, Customer
Where CollectionsReceived.CustomerId=Customer.CustomerID And
CollectionsReceived.DocSerial = IsNull(Collections.OriginalCollection,0)
and Collections.DocumentDate between @fromdate and @todate
And (IsNull(Collections.Status,0) & 192) = 0 
And (IsNull(Collections.Status,0) & 64) = 0 
And IsNull(Collections.OriginalCollection,0) > 0 



