CREATE procedure [dbo].[spr_list_DailyCollection_Detail] (@PaymentMode int,
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
	"CustomerID" = Collections.CustomerID,
	"Chq No" = Collections.ChequeNumber,
	"Customer Name" = Customer.Company_Name,
	"Document Date" = CollectionDetail.DocumentDate,
	"DocumentID" = CollectionDetail.OriginalID,
	"Amount Adjusted" = CollectionDetail.AdjustedAmount,
	"Addl Adjustment" = IsNull(CollectionDetail.ExtraCollection, 0),
	"Amount" = Collections.Value
	From Collections, CollectionDetail, Customer, BankMaster, BranchMaster
	Where Collections.DocumentID = CollectionDetail.CollectionID And
	IsNull(Collections.Status, 0) & 128 = 0 And
	Collections.BankCode *= BankMaster.BankCode And
	Collections.BranchCode *= BranchMaster.BranchCode And
	Collections.BankCode  *= BranchMaster.BankCode And
	Collections.CustomerID = Customer.CustomerID And
	Collections.PaymentMode = 0 And
	Collections.DocumentDate Between @FromDate And @ToDate
End
Else If @PaymentMode = 2
Begin
	Select Collections.DocumentID, 
	"Collection No" = Collections.FullDocID,
	"Bank" = IsNull(BankMaster.BankName, N''),
	"Branch" = IsNull(BranchMaster.BranchName, N''),
	"Date" = Collections.ChequeDate,
	"CustomerID" = Collections.CustomerID,
	"Chq No" = Collections.ChequeNumber,
	"Customer Name" = Customer.Company_Name,
	"Document Date" = CollectionDetail.DocumentDate,
	"DocumentID" = CollectionDetail.OriginalID,
	"Amount Adjusted" = CollectionDetail.AdjustedAmount,
	"Addl Adjustment" = IsNull(CollectionDetail.ExtraCollection, 0),
	"Amount" = Collections.Value
	From Collections, CollectionDetail, Customer, BankMaster, BranchMaster
	Where Collections.DocumentID = CollectionDetail.CollectionID And
	IsNull(Collections.Status, 0) & 128 = 0 And
	Collections.BankCode = BankMaster.BankCode And
	Collections.BranchCode = BranchMaster.BranchCode And
	Collections.BankCode  = BranchMaster.BankCode And
	Collections.CustomerID = Customer.CustomerID And
	Collections.PaymentMode = 1 And
	Collections.DocumentDate Between @FromDate And @ToDate And
	dbo.StripDateFromTime(Collections.ChequeDate) = dbo.StripDateFromTime(@FromDate)
End
Else If @PaymentMode = 3
Begin
	Select Collections.DocumentID, 
	"Collection No" = Collections.FullDocID,
	"Bank" = IsNull(BankMaster.BankName, N''),
	"Branch" = IsNull(BranchMaster.BranchName, N''),
	"Date" = Collections.ChequeDate,
	"CustomerID" = Collections.CustomerID,
	"Chq No" = Collections.ChequeNumber,
	"Customer Name" = Customer.Company_Name,
	"Document Date" = CollectionDetail.DocumentDate,
	"DocumentID" = CollectionDetail.OriginalID,
	"Amount Adjusted" = CollectionDetail.AdjustedAmount,
	"Addl Adjustment" = IsNull(CollectionDetail.ExtraCollection, 0),
	"Amount" = Collections.Value
	From Collections, CollectionDetail, Customer, BankMaster, BranchMaster
	Where Collections.DocumentID = CollectionDetail.CollectionID And
	IsNull(Collections.Status, 0) & 128 = 0 And
	Collections.BankCode = BankMaster.BankCode And
	Collections.BranchCode = BranchMaster.BranchCode And
	Collections.BankCode  = BranchMaster.BankCode And
	Collections.CustomerID = Customer.CustomerID And
	Collections.PaymentMode = 1 And
	Collections.DocumentDate Between @FromDate And @ToDate And
	dbo.StripDateFromTime(Collections.ChequeDate) > dbo.StripDateFromTime(@FromDate)
End
Else
Begin
	Select Collections.DocumentID, 
	"Collection No" = Collections.FullDocID,
	"Bank" = IsNull(BankMaster.BankName, N''),
	"Branch" = IsNull(BranchMaster.BranchName, N''),
	"Date" = Collections.ChequeDate,
	"CustomerID" = Collections.CustomerID,
	"Chq No" = Collections.ChequeNumber,
	"Customer Name" = Customer.Company_Name,
	"Document Date" = CollectionDetail.DocumentDate,
	"DocumentID" = CollectionDetail.OriginalID,
	"Amount Adjusted" = CollectionDetail.AdjustedAmount,
	"Addl Adjustment" = IsNull(CollectionDetail.ExtraCollection, 0),
	"Amount" = Collections.Value
	From Collections, CollectionDetail, Customer, BankMaster, BranchMaster
	Where Collections.DocumentID = CollectionDetail.CollectionID And
	IsNull(Collections.Status, 0) & 128 = 0 And
	Collections.BankCode = BankMaster.BankCode And
	Collections.BranchCode = BranchMaster.BranchCode And
	Collections.BankCode  = BranchMaster.BankCode And
	Collections.CustomerID = Customer.CustomerID And
	Collections.PaymentMode = 2 And
	Collections.DocumentDate Between @FromDate And @ToDate
End
