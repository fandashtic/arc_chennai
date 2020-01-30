Create Procedure spr_list_ReceivedCollections(@FROMDATE DATETIME, @TODATE DATETIME)
as

Declare @PROCESSED As NVarchar(50)
Declare @NOTPROCESSED As NVarchar(50)
Declare @CANCELLED As NVarchar(50)

Set @PROCESSED = dbo.LookupDictionaryItem(N'Processed', Default)
Set @NOTPROCESSED = dbo.LookupDictionaryItem(N'Not Processed', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)

Select CollectionsReceived.DocSerial,
"Collection Id" = CollectionsReceived.FullDocID,
"Collection Date" = DocumentDate,
"Customer Id" = Customer.CustomerId,
"Customer Name" = Customer.Company_Name,
"Value" = Value,
"Balance" = Balance,
"Doc Ref"=DocReference,
"Status" = Case 
When Isnull(Status,0) & 64 <> 0 then
@CANCELLED
When Isnull(Status,0) & 128 <> 0 then
@PROCESSED
Else
@NOTPROCESSED
End
From CollectionsReceived,Customer
Where CollectionsReceived.CustomerId=Customer.CustomerID
and CollectionsReceived.DocumentDate between @fromdate and @todate



