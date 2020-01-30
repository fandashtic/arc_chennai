CREATE procedure [dbo].[spr_list_Salesmanwise_OutStanding](@FromDate datetime,
						   @ToDate datetime)
as
Declare @One As Datetime
Declare @Seven As Datetime
Declare @Eight As Datetime
Declare @Ten As Datetime
Declare @Eleven As Datetime
Declare @Fourteen As Datetime
Declare @Fifteen As Datetime
Declare @TwentyOne As Datetime
Declare @TwentyTwo As Datetime
Declare @Thirty As Datetime
Declare @ThirtyOne As Datetime
Declare @Sixty As Datetime
Declare @SixtyOne As Datetime
Declare @Ninety As Datetime
Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)

Set @One = Cast(Datepart(dd, GetDate()) As nvarchar) + '/' +
Cast(Datepart(mm, GetDate()) As nvarchar) + '/' +
Cast(Datepart(yyyy, GetDate()) As nvarchar)
Set @Seven = DateAdd(d, -7, @One)
Set @Eight = DateAdd(d, -1, @Seven)
Set @Ten = DateAdd(d, -2, @Eight)
Set @Eleven = DateAdd(d, -1, @Ten)
Set @Fourteen = DateAdd(d, -3, @Eleven)
Set @Fifteen = DateAdd(d, -1, @Fourteen)
Set @TwentyOne = DateAdd(d, -6, @Fifteen)
Set @TwentyTwo = DateAdd(d, -1, @TwentyOne)
Set @Thirty = DateAdd(d, -8, @TwentyTwo)
Set @ThirtyOne = DateAdd(d, -1, @Thirty)
Set @Sixty = DateAdd(d, -29, @ThirtyOne)
Set @SixtyOne = DateAdd(d, -1, @Sixty)
Set @Ninety = DateAdd(d, -29, @SixtyOne)

Set @One = dbo.MakeDayEnd(@One)
Set @Eight = dbo.MakeDayEnd(@Eight)
Set @Eleven = dbo.MakeDayEnd(@Eleven)
Set @Fifteen = dbo.MakeDayEnd(@Fifteen)
Set @TwentyTwo = dbo.MakeDayEnd(@TwentyTwo)
Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)
Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)

create table #temp
(SalesmanID int not null,
Balance Decimal(18,6) not null,
CustomerID nvarchar(15) not null,
OnetoSeven Decimal(18,6) null,
EighttoTen Decimal(18,6) null,
EleventoFourteen Decimal(18,6) null,
FifteentoTwentyOne Decimal(18,6) null,
TwentyTwotoThirty Decimal(18,6) null,
LessthanThirty Decimal(18,6) null,
ThirtyOnetoSixty Decimal(18,6) null,
SixtyOnetoNinety Decimal(18,6) null,
MorethanNinety Decimal(18,6) null)

insert into #temp (SalesmanID, Balance, CustomerID, OnetoSeven, EighttoTen, 
EleventoFourteen, FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
select 	ISNULL(InvoiceAbstract.SalesmanID, 0), ISNULL(Sum(Balance), 0),
	CustomerID,
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Seven And @One And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Ten And @Seven And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Fourteen And @Eleven And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @TwentyOne And @Fifteen And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Thirty And @TwentyTwo And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate > @Thirty And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Sixty And @ThirtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Ninety And @SixtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate < @Ninety And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID)
from InvoiceAbstract
where InvoiceAbstract.Status & 128 = 0 and
InvoiceAbstract.Balance > 0 and
InvoiceAbstract.InvoiceType in (1, 3) and
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate
group by InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID

insert into #temp (SalesmanID, Balance, CustomerID, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
select ISNULL(InvoiceAbstract.SalesmanID, 0), 0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID,
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Seven And @One And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Ten And @Seven And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Fourteen And @Eleven And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @TwentyOne And @Fifteen And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Thirty And @TwentyTwo And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate > @Thirty And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Sixty And @ThirtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate Between @Ninety And @SixtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.InvoiceDate < @Ninety And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0 And
Inv.SalesmanID = InvoiceAbstract.SalesmanID And
Inv.CustomerID = InvoiceAbstract.CustomerID)
FROM InvoiceAbstract
WHERE ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND
(Status & 128) = 0 AND
InvoiceDate Between @FromDate AND @ToDate

insert into #temp (SalesmanID, Balance, CustomerID, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
SELECT ISNULL(SalesmanID, 0), 0 - ISNULL(Balance, 0), CustomerID,
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Seven And @One And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And 
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Ten And @Eight And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And 
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Fourteen And @Eleven And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And 
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @TwentyOne And @Fifteen And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And 
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Thirty And @TwentyTwo And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And 
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate > @Thirty And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And 
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Sixty And @ThirtyOne And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And 
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Ninety And @SixtyOne And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And 
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate < @Ninety And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And 
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID)
From Collections
WHERE ISNULL(Balance, 0) > 0 AND 
DocumentDate Between @FromDate AND @ToDate And
IsNull(Collections.Status, 0) & 128 = 0 

insert into #temp (SalesmanID, Balance, CustomerID, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
SELECT  ISNULL(SalesmanID, 0), 0 - ISNULL(Balance, 0), CustomerID,
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Seven And @One And
Cr.Balance > 0 And
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Ten And @Eight And
Cr.Balance > 0 And
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Fourteen And @Eleven And
Cr.Balance > 0 And
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @TwentyOne And @Fifteen And
Cr.Balance > 0 And
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Thirty And @TwentyTwo And
Cr.Balance > 0 And
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate > @Thirty And
Cr.Balance > 0 And
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Sixty And @ThirtyOne And
Cr.Balance > 0 And
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Ninety And @SixtyOne And
Cr.Balance > 0 And
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate < @Ninety And
Cr.Balance > 0 And
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID)
From CreditNote
WHERE   ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND
	CustomerID IS NOT NULL

insert into #temp (SalesmanID, Balance, CustomerID, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
SELECT ISNULL(SalesmanID, 0), ISNULL(Balance, 0), CustomerID,
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Seven And @One And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Ten And @Eight And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Fourteen And @Eleven And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @TwentyOne And @Fifteen And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Thirty And @TwentyTwo And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate > @Thirty And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Sixty And @ThirtyOne And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Ninety And @SixtyOne And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate < @Ninety And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID)
From DebitNote
WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND
	CustomerID IS NOT NULL

select #temp.SalesmanID, "Salesman" = IsNull(Salesman.Salesman_Name, @OTHERS), 
"Net Outstanding (%c)" = SUM(Balance),
"1-7 Days" = Sum(OnetoSeven),
"8-10 Days" = Sum(EighttoTen),
"11-14 Days" = Sum(EleventoFourteen),
"15-21 Days" = Sum(FifteentoTwentyOne),
"22-30 Days" = Sum(TwentyTwotoThirty),
"<30 Days" = Sum(LessthanThirty),
"31-60 Days" = Sum(ThirtyOnetoSixty),
"61-90 Days" = Sum(SixtyOnetoNinety),
">90 Days" = Sum(MorethanNinety)
from #temp, Salesman
WHERE #temp.SalesmanID *= Salesman.SalesmanID
Group By #temp.SalesmanID, Salesman.Salesman_Name
drop table #temp
