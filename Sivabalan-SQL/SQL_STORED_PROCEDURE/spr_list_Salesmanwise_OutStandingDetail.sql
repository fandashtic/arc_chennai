CREATE procedure spr_list_Salesmanwise_OutStandingDetail(@SalesmanID int,
							@FromDate datetime,
							@ToDate datetime)
as
create table #temp
(
	SalesmanID int not null,
	Balance Decimal(18,6) not null,
	CustomerID nvarchar(15) not null
)
insert into #temp
select 	ISNULL(InvoiceAbstract.SalesmanID, 0), ISNULL(Sum(Balance), 0),
	CustomerID
from InvoiceAbstract
where InvoiceAbstract.Status & 128 = 0 and
InvoiceAbstract.Balance > 0 and
InvoiceAbstract.InvoiceType in (1, 3) and
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate
group by InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID

insert into #temp
select ISNULL(InvoiceAbstract.SalesmanID, 0), 0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID
FROM InvoiceAbstract
WHERE ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND
(Status & 128) = 0 AND
InvoiceDate Between @FromDate AND @ToDate

insert into #temp
SELECT ISNULL(SalesmanID, 0), 0 - ISNULL(Balance, 0), CustomerID FROM Collections
WHERE ISNULL(Balance, 0) > 0 AND 
DocumentDate Between @FromDate AND @ToDate And
IsNull(Collections.Status, 0) & 128 = 0

insert into #temp 
SELECT  ISNULL(SalesmanID, 0), 0 - ISNULL(Balance, 0), CustomerID FROM CreditNote
WHERE   ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND
	CustomerID IS NOT NULL

insert into #temp 
SELECT ISNULL(SalesmanID, 0), ISNULL(Balance, 0), CustomerID FROM DebitNote
WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND
	CustomerID IS NOT NULL

select #temp.CustomerID, "Customer" = Customer.Company_Name,
"OutStanding" = sum(Balance), "Credit Limit" = Customer.CreditLimit,
"Last Payment Date" = (Select Max(DocumentDate) from Collections 
where Collections.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = #temp.CustomerID)
from #temp, Customer
WHERE #temp.SalesmanID = @SalesmanID and
#temp.CustomerID = Customer.CustomerID
Group By #temp.CustomerID, Customer.Company_Name, Customer.CreditLimit
drop table #temp


