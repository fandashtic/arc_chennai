create procedure sp_ser_acc_rpt_list_Salesmanwise_Beat_OutStandDetail(@SalesmanBeatID varchar(50),
							@FromDate datetime,
							@ToDate datetime)
as
DECLARE @SalesmanID int
DECLARE @BeatID int
DECLARE @Pos int

set @Pos = charindex(';', @SalesmanBeatID)
Set @SalesmanID = Cast(SubString(@SalesmanBeatID, 1, @Pos-1) as int)
Set @BeatID = Cast(SubString(@SalesmanBeatID, @Pos+1, 50) as int)
create table #temp
(
	SalesmanID int not null,
	BeatID int not null,
	Balance Decimal(18,6) not null,
	CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS not null
)
insert into #temp
select 	ISNULL(InvoiceAbstract.SalesmanID, 0), ISNULL(InvoiceAbstract.BeatID, 0), 
	ISNULL(Sum(Balance), 0), CustomerID
from InvoiceAbstract
where IsNull(InvoiceAbstract.Status,0) & 128 = 0 and
InvoiceAbstract.Balance > 0 and
InvoiceAbstract.InvoiceType in (1, 3) and
ISNULL(InvoiceAbstract.BeatID, 0) = @BeatID and
ISNULL(InvoiceAbstract.SalesmanID, 0) = @SalesManID and
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate
group by ISNULL(InvoiceAbstract.SalesmanID, 0), ISNULL(InvoiceAbstract.BeatID, 0), InvoiceAbstract.CustomerID

insert into #temp
select  ISNULL(InvoiceAbstract.SalesmanID, 0), ISNULL(InvoiceAbstract.BeatID, 0), 
	0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID
FROM InvoiceAbstract
WHERE ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND
(IsNull(Status,0) & 128) = 0 AND
ISNULL(InvoiceAbstract.BeatID, 0) = @BeatID and
ISNULL(InvoiceAbstract.SalesmanID, 0) = @SalesManID and
InvoiceDate Between @FromDate AND @ToDate

--Begin: Service Invoice Impact
if @salesmanid = 0 and @beatid = 0 
begin
	insert into #temp
	select 0,0,isNull(Balance,0),CustomerID
	from ServiceInvoiceAbstract 
	where isNull(balance,0) > 0 and ServiceInvoiceType in (1) and
	(isNull(status,0) & 192) = 0 and serviceInvoiceDate between @FromDate AND @ToDate
end
--End: Service Invoice Impact

insert into #temp
SELECT  ISNULL(SalesmanID, 0), ISNULL(BeatID, 0), 0 - ISNULL(Balance, 0), 
	CustomerID FROM Collections
WHERE 	ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate
and ISNULL(SalesmanID, 0) = @SalesManID and  ISNULL(BeatID, 0) = @BeatID
and CustomerID is not null

insert into #temp 
SELECT  ISNULL(CreditNote.SalesmanID, 0), IsNull(Beat_Salesman.BeatID, 0), 
	0 - ISNULL(Balance, 0), CreditNote.CustomerID FROM CreditNote
	Left Outer join Beat_Salesman on CreditNote.CustomerID = Beat_Salesman.CustomerID
WHERE   ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate
	and	CreditNote.CustomerID IS NOT NULL
	and IsNull(CreditNote.SalesmanID,0) = @Salesmanid
	and IsNull(Beat_Salesman.BeatID,0) = @BeatID

insert into #temp 
SELECT  ISNULL(DebitNote.SalesmanID, 0), ISNULL(Beat_Salesman.BeatID, 0), 
	ISNULL(Balance, 0), DebitNote.CustomerID FROM DebitNote
	Left Outer join Beat_Salesman on DebitNote.CustomerID = Beat_Salesman.CustomerID
WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate
	AND DebitNote.CustomerID IS NOT NULL 
	and IsNull(DebitNote.SalesmanID,0) = @Salesmanid
	and IsNull(Beat_Salesman.BeatID,0) = @BeatID

select #temp.CustomerID, "Customer" = Customer.Company_Name,
"OutStanding" = sum(Balance), "Credit Limit" = isNull(Customer.CreditLimit,0),
"Last Payment Date" = (Select Max(DocumentDate) from Collections 
where Collections.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = #temp.CustomerID)
from #temp, Customer
WHERE 
#temp.CustomerID = Customer.CustomerID
Group By #temp.CustomerID, Customer.Company_Name, Customer.CreditLimit
drop table #temp

