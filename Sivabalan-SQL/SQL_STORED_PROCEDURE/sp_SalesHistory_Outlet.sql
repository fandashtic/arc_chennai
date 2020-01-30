Create PROCEDURE sp_SalesHistory_Outlet
		@FromDate Datetime,
		@ToDate  Datetime,
		@FromSalesManID int,
		@ToSalesManID int
AS
Select 	InvoiceAbstract.InvoiceDate  as InvoiceDate, InvoiceAbstract.DocReference as InvoiceReferenceNumber,
	sum(InvoiceAbstract.GrossValue) as  InvoiceGrossAmount,InvoiceAbstract.DiscountValue AS Discount,
	sum(InvoiceAbstract.NetValue+InvoiceAbstract.RoundOffAmount) as InvoiceNetAmount,
	InvoiceAbstract.CustomerID AS OutletCode,Customer.Company_Name as OutletName,
	Beat.Description as Beat,Salesman.Salesman_Name as SalesmanName		
From    InvoiceAbstract 
Inner Join Customer On InvoiceAbstract.CustomerId = Customer.CustomerId
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID 
Left Outer Join SalesMan On InvoiceAbstract.SalesManId = SalesMan.SalesManId
where   
	Invoicedate Between @FromDate And @Todate  and 
	InvoiceAbstract.SalesManID Between @FromSalesManID and @ToSalesManID and
	(isnull(InvoiceAbstract.Status,0) & 128 ) = 0  and 
	(isnull(InvoiceAbstract.Status,0) & 64 ) = 0 and
	InvoiceAbstract.InvoiceType in (1,3) 
Group By  InvoiceAbstract.CustomerID,Customer.Company_Name,InvoiceAbstract.DiscountValue,Beat.Description,SalesMan.Salesman_Name,
	  InvoiceAbstract.DocReference,InvoiceAbstract.InvoiceDate,InvoiceAbstract.ReferenceNumber
order by InvoiceAbstract.CustomerID
