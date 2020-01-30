Create PROCEDURE sp_Collection
		@FromDate Datetime,
		@ToDate  Datetime,
		@FromSalesManID int,
		@ToSalesManID int
AS
Select 	Collections.Beatid  as Beat,Salesman.Salesman_Name as SalesmanName,Customer.Company_Name as Customer,
	CollectionDetail.PaymentDate as Collection_Date,CollectionDetail.AdjustedAmount as Collection_Amount ,Collections.PaymentMode as Mode_of_Payment,
	Collections.ChequeNumber as Cheque_DD_Number,Collections.ChequeDate as Cheque_DD_date,Collections.BankCode as Bank_ID,Collections.BranchCode as Branch_ID	

From    CollectionDetail 
Inner Join Collections On Collections.DocumentID = CollectionDetail.DocumentID 
Inner Join Customer On Collections.CustomerId = Customer.CustomerId 
Left Outer Join Beat On Collections.BeatID = Beat.BeatID 
Left Outer Join SalesMan On Collections.SalesManId = SalesMan.SalesManId 
Left Outer Join InvoiceAbstract On InvoiceAbstract.InvoiceID = CollectionDetail.DocumentID and CollectionDetail.DocumentType in (4, 6, 1)
where  	
	Collections.SalesManID Between @FromSalesManID and @ToSalesManID and
	Invoicedate Between @FromDate And @Todate  and 
	(isnull(InvoiceAbstract.Status,0) & 128 ) = 0  and 
	(isnull(InvoiceAbstract.Status,0) & 64 ) = 0 and
	InvoiceAbstract.InvoiceType in (1,3) 
