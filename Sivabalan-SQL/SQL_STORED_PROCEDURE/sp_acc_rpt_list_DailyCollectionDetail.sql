CREATE Procedure [dbo].[sp_acc_rpt_list_DailyCollectionDetail] (@PaymentMode int,
						@FromDate Datetime,
						@ToDate Datetime)
As
If @PaymentMode = 1 
Begin
	Select Collections.DocumentID, 
	"Collection No" = Collections.FullDocID,
	"Bank" = IsNull(BankMaster.BankName, N''),
	"Branch" = IsNull(BranchMaster.BranchName, N''),
	"Date" = Collections.ChequeDate,
	"Type"= case when Collections.Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,  	 
	"Account Name" = Case when  Collections.others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
	else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,     
--	"CustomerID" = Collections.CustomerID,
	"Chq No" = Collections.ChequeNumber,
	"Document Date" = CollectionDetail.DocumentDate,
	"DocumentID" = CollectionDetail.OriginalID,
	"Amount Adjusted" = CollectionDetail.AdjustedAmount,
	"Addl Adjustment" = IsNull(CollectionDetail.ExtraCollection, 0),
	"Amount" = Collections.Value
	From Collections
	Left Join CollectionDetail on Collections.DocumentID = CollectionDetail.CollectionID
	Left Join BankMaster on Collections.BankCode = BankMaster.BankCode
	Left Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode and Collections.BankCode  = BranchMaster.BankCode
	Where 
	--Collections.DocumentID *= CollectionDetail.CollectionID And
	IsNull(Collections.Status, 0) & 128 = 0 And
	--Collections.BankCode *= BankMaster.BankCode And
	--Collections.BranchCode *= BranchMaster.BranchCode And
	--Collections.BankCode  *= BranchMaster.BankCode And
	Collections.PaymentMode = 0 And
	dbo.stripdatefromtime(Collections.DocumentDate) Between @FromDate And @ToDate
End
Else If @PaymentMode = 2
Begin
	Select Collections.DocumentID, 
	"Collection No" = Collections.FullDocID,
	"Bank" = IsNull(BankMaster.BankName, N''),
	"Branch" = IsNull(BranchMaster.BranchName, N''),
	"Date" = Collections.ChequeDate,
	"Type"= case when  Collections.Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,  	 
	"Account Name" = Case when  Collections.others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
	else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,     
--	"CustomerID" = Collections.CustomerID,
	"Chq No" = Collections.ChequeNumber,
	"Document Date" = CollectionDetail.DocumentDate,
	"DocumentID" = CollectionDetail.OriginalID,
	"Amount Adjusted" = CollectionDetail.AdjustedAmount,
	"Addl Adjustment" = IsNull(CollectionDetail.ExtraCollection, 0),
	"Amount" = Collections.Value
	From Collections
	Left Join CollectionDetail on Collections.DocumentID = CollectionDetail.CollectionID
	Inner Join BankMaster on Collections.BankCode = BankMaster.BankCode
	Inner Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode And Collections.BankCode  = BranchMaster.BankCode
	Where 
	--Collections.DocumentID *= CollectionDetail.CollectionID And
	IsNull(Collections.Status, 0) & 128 = 0 And
	--Collections.BankCode = BankMaster.BankCode And
	--Collections.BranchCode = BranchMaster.BranchCode And
	--Collections.BankCode  = BranchMaster.BankCode And
	Collections.PaymentMode = 1 And
	dbo.stripdatefromtime(Collections.DocumentDate) Between @FromDate And @ToDate And
	dbo.StripDateFromTime(Collections.ChequeDate) = dbo.StripDateFromTime(@FromDate)
End
Else If @PaymentMode = 3
Begin
	Select Collections.DocumentID, 
	"Collection No" = Collections.FullDocID,
	"Bank" = IsNull(BankMaster.BankName, N''),
	"Branch" = IsNull(BranchMaster.BranchName, N''),
	"Date" = Collections.ChequeDate,
	"Type"= case when  Collections.Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,  	 
	"Account Name" = Case when  Collections.others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
	else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,     
--	"CustomerID" = Collections.CustomerID,
	"Chq No" = Collections.ChequeNumber,
	"Document Date" = CollectionDetail.DocumentDate,
	"DocumentID" = CollectionDetail.OriginalID,
	"Amount Adjusted" = CollectionDetail.AdjustedAmount,
	"Addl Adjustment" = IsNull(CollectionDetail.ExtraCollection, 0),
	"Amount" = Collections.Value
	From Collections
	Left Join CollectionDetail on Collections.DocumentID = CollectionDetail.CollectionID
	Inner Join BankMaster on Collections.BankCode = BankMaster.BankCode
	Inner Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode And Collections.BankCode  = BranchMaster.BankCode
	Where 
	--Collections.DocumentID *= CollectionDetail.CollectionID And
	IsNull(Collections.Status, 0) & 128 = 0 And
	--Collections.BankCode = BankMaster.BankCode And
	--Collections.BranchCode = BranchMaster.BranchCode And
	--Collections.BankCode  = BranchMaster.BankCode And
	Collections.PaymentMode = 1 And
	dbo.stripdatefromtime(Collections.DocumentDate) Between @FromDate And @ToDate And
	dbo.StripDateFromTime(Collections.ChequeDate) > dbo.StripDateFromTime(@FromDate)
End
Else
Begin
	Select Collections.DocumentID, 
	"Collection No" = Collections.FullDocID,
	"Bank" = IsNull(BankMaster.BankName, N''),
	"Branch" = IsNull(BranchMaster.BranchName, N''),
	"Date" = Collections.ChequeDate,
	"Type"= case when  Collections.Others is not null then dbo.LookupDictionaryItem('Others',Default) else dbo.LookupDictionaryItem('Customer',Default) end,  	 
	"Account Name" = Case when  Collections.others is null then (Select Company_Name from Customer where CustomerID=Collections.CustomerID) 
	else (Select AccountName from AccountsMaster where AccountID=Collections.Others) end,     
--	"CustomerID" = Collections.CustomerID,
	"Chq No" = Collections.ChequeNumber,
	"Document Date" = CollectionDetail.DocumentDate,
	"DocumentID" = CollectionDetail.OriginalID,
	"Amount Adjusted" = CollectionDetail.AdjustedAmount,
	"Addl Adjustment" = IsNull(CollectionDetail.ExtraCollection, 0),
	"Amount" = Collections.Value
	From Collections
	Left Join CollectionDetail on Collections.DocumentID = CollectionDetail.CollectionID
	Inner Join BankMaster on Collections.BankCode = BankMaster.BankCode
	Inner Join BranchMaster on Collections.BranchCode = BranchMaster.BranchCode And Collections.BankCode  = BranchMaster.BankCode 
	Where 
	--Collections.DocumentID *= CollectionDetail.CollectionID And
	IsNull(Collections.Status, 0) & 128 = 0 And
	--Collections.BankCode = BankMaster.BankCode And
	--Collections.BranchCode = BranchMaster.BranchCode And
	--Collections.BankCode  = BranchMaster.BankCode And
	Collections.PaymentMode = 2 And
	dbo.stripdatefromtime(Collections.DocumentDate) Between @FromDate And @ToDate
End
