create procedure sp_acc_rpt_list_Salesmanwise_Beat_OutStandDetail(@SalesmanBeatID nvarchar(50),
							@FromDate datetime,
							@ToDate datetime)
as
DECLARE @SalesmanID int
DECLARE @BeatID int
DECLARE @Pos int

set @Pos = charindex(N';', @SalesmanBeatID)
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
where InvoiceAbstract.Status & 128 = 0 and
InvoiceAbstract.Balance > 0 and
InvoiceAbstract.InvoiceType in (1, 3) and
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate
group by ISNULL(InvoiceAbstract.SalesmanID, 0), ISNULL(InvoiceAbstract.BeatID, 0), InvoiceAbstract.CustomerID

insert into #temp
select  ISNULL(InvoiceAbstract.SalesmanID, 0), ISNULL(InvoiceAbstract.BeatID, 0), 
	0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID
FROM InvoiceAbstract
WHERE ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND
(Status & 128) = 0 AND
InvoiceDate Between @FromDate AND @ToDate

insert into #temp
SELECT  ISNULL(SalesmanID, 0), ISNULL(BeatID, 0), 0 - ISNULL(Balance, 0), 
	CustomerID FROM Collections
WHERE 	ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate
and CustomerID is not null

insert into #temp 
SELECT  ISNULL(CreditNote.SalesmanID, 0), IsNull(Beat_Salesman.BeatID, 0), 
	0 - ISNULL(Balance, 0), CreditNote.CustomerID FROM CreditNote, Beat_Salesman
WHERE   ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND
	CreditNote.CustomerID IS NOT NULL 
	--And CreditNote.CustomerID *= Beat_Salesman.CustomerID
	and beat_salesman.CustomerID = CreditNote.CustomerID  
	and beat_salesman.BeatID = @BeatID  
	and beat_salesman.salesmanid = CreditNote.salesmanid  
	and beat_salesman.salesmanid = @salesmanid 

insert into #temp 
SELECT  ISNULL(DebitNote.SalesmanID, 0), ISNULL(Beat_Salesman.BeatID, 0), 
	ISNULL(Balance, 0), DebitNote.CustomerID FROM DebitNote, Beat_Salesman
WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND
	DebitNote.CustomerID IS NOT NULL And IsNull(DebitNote.Status, 0) & 192 = 0  And
--DebitNote.CustomerID *= Beat_Salesman.CustomerID
  beat_salesman.CustomerID = DebitNote.CustomerID and 
  beat_salesman.BeatID = @BeatID and 
  beat_salesman.salesmanid = debitnote.salesmanid and 
  beat_salesman.salesmanid = @salesmanid 

select #temp.CustomerID, "Customer" = Customer.Company_Name,
"OutStanding" = sum(Balance), "Credit Limit" = Customer.CreditLimit,
"Last Payment Date" = (Select Max(DocumentDate) from Collections 
where Collections.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = #temp.CustomerID)
from #temp, Customer
WHERE #temp.SalesmanID = @SalesmanID and
#temp.BeatID = @BeatID and
#temp.CustomerID = Customer.CustomerID
Group By #temp.CustomerID, Customer.Company_Name, Customer.CreditLimit
drop table #temp



