Create Procedure sp_acc_rpt_List_ShortageExcess_Detail (@Unused int,
						@FromDate datetime,
						 @ToDate datetime)
As
Select CollectionDetail.DocumentID,
"Doc ID" = CollectionDetail.OriginalID,
"Doc Date" = CollectionDetail.DocumentDate,
"Doc Ref" = IsNull(CollectionDetail.DocRef, N''),
-- "Customer ID" = Collections.CustomerID,
-- "Customer" = Customer.Company_Name,
"Type"= case when Collections.Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,  	 
"Account Name" = Case when Collections.others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,     
"Collection ID" = Collections.FullDocID,
"Extra Collection" = IsNull(CollectionDetail.ExtraCollection, 0),
"Write Off" = IsNull(CollectionDetail.Adjustment, 0)
From CollectionDetail, Collections
Where CollectionDetail.CollectionID = Collections.DocumentID And
Collections.DocumentDate Between @FromDate And @ToDate And
(IsNull(CollectionDetail.ExtraCollection, 0) <> 0 Or
IsNull(CollectionDetail.Adjustment, 0) <> 0) And
--Collections.CustomerID = Customer.CustomerID And
IsNull(Collections.Status, 0) & 128 = 0

