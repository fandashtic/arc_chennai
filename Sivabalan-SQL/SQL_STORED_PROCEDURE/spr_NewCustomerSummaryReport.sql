CREATE Procedure spr_NewCustomerSummaryReport(@FromDate datetime,@ToDate Datetime)
As
Declare @NOSALESMAN nVarchar(50)
set @NOSALESMAN = dbo.LookupDictionaryItem(N'No SalesMan',default)
Select Customer.CustomerID,
"SalesMan Name" = IsNull(SalesMan_Name,@NOSALESMAN),
"Customer"=Customer.Company_Name,
"Creation Date"=Customer.CreationDate
From Customer Left Outer Join Beat_SalesMan on Beat_SalesMan.Customerid  = Customer.CustomerID
Left Outer Join SalesMan on SalesMan.SalesManID=Beat_SalesMan.SalesManid 
Where Customer.CreationDate Between @FromDate And @ToDate
Order By Customer.CreationDate

