CREATE procedure spr_list_Channel_OutStanding_Detail(@ChannelID Int,
							@FromDate datetime,  
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
(CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Value Decimal(18,6) null,
OnetoSevenBills Int,
OnetoSeven Decimal(18,6) null,
EighttoTenBills Int,
EighttoTen Decimal(18,6) null,
EleventoFourteenBills Int,
EleventoFourteen Decimal(18,6) null,
FifteentoTwentyOneBills Int,
FifteentoTwentyOne Decimal(18,6) null,
TwentyTwotoThirtyBills Int,
TwentyTwotoThirty Decimal(18,6) null,
LessthanThirtyBills Int,
LessthanThirty Decimal(18,6) null,
ThirtyOnetoSixtyBills Int,
ThirtyOnetoSixty Decimal(18,6) null,
SixtyOnetoNinetyBills Int,
SixtyOnetoNinety Decimal(18,6) null,
MorethanNinetyBills Int,
MorethanNinety Decimal(18,6) null)

insert #temp(CustomerID, Value, 
OnetoSevenBills, OnetoSeven, 
EighttoTenBills, EighttoTen, 
EleventoFourteenBills, EleventoFourteen,
FifteentoTwentyOneBills, FifteentoTwentyOne, 
TwentyTwotoThirtyBills, TwentyTwotoThirty, 
LessthanThirtyBills, LessthanThirty, 
ThirtyOnetoSixtyBills, ThirtyOnetoSixty, 
SixtyOnetoNinetyBills, SixtyOnetoNinety, 
MorethanNinetyBills, MorethanNinety)
select Customer.CustomerID,  sum(InvoiceAbstract.Balance),
(Select Count(*)
From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Seven And @One And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Seven And @One And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Ten And @Eight And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Ten And @Eight And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Fourteen And @Eleven And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Fourteen And @Eleven And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @TwentyOne And @Fifteen And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @TwentyOne And @Fifteen And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Thirty And @TwentyTwo And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Thirty And @TwentyTwo And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate > @Thirty And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate > @Thirty And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Sixty And @ThirtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Sixty And @ThirtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Ninety And @SixtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Ninety And @SixtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate < @Ninety And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate < @Ninety And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0)
from InvoiceAbstract, Customer
where Invoiceabstract.Customerid = Customer.CustomerID and
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
InvoiceAbstract.Balance > 0 and   
InvoiceAbstract.InvoiceType in (1, 3) and  
InvoiceAbstract.Status & 128 = 0 And
IsNull(Customer.ChannelType, 0) = @ChannelID
group by Customer.CustomerID

insert #temp(CustomerID, Value, 
OnetoSevenBills, OnetoSeven, 
EighttoTenBills, EighttoTen, 
EleventoFourteenBills, EleventoFourteen,
FifteentoTwentyOneBills, FifteentoTwentyOne, 
TwentyTwotoThirtyBills, TwentyTwotoThirty, 
LessthanThirtyBills, LessthanThirty, 
ThirtyOnetoSixtyBills, ThirtyOnetoSixty, 
SixtyOnetoNinetyBills, SixtyOnetoNinety, 
MorethanNinetyBills, MorethanNinety)
select Customer.CustomerID, 0 - sum(InvoiceAbstract.Balance),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Seven And @One And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Seven And @One And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Ten And @Eight And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Ten And @Eight And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Fourteen And @Eleven And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Fourteen And @Eleven And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @TwentyOne And @Fifteen And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @TwentyOne And @Fifteen And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Thirty And @TwentyTwo And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Thirty And @TwentyTwo And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate > @Thirty And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate > @Thirty And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Sixty And @ThirtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Sixty And @ThirtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Ninety And @SixtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate Between @Ninety And @SixtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select Count(*) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate < @Ninety And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = Customer.CustomerID And
Inv.InvoiceDate < @Ninety And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0)
from InvoiceAbstract, Customer
where InvoiceAbstract.CustomerID = Customer.CustomerID and  
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
InvoiceAbstract.Balance > 0 and   
InvoiceAbstract.InvoiceType in (4) and  
InvoiceAbstract.Status & 128 = 0  And
IsNull(Customer.ChannelType, 0) = @ChannelID
group by Customer.CustomerID

insert #temp(CustomerID, Value, 
OnetoSevenBills, OnetoSeven, 
EighttoTenBills, EighttoTen, 
EleventoFourteenBills, EleventoFourteen,
FifteentoTwentyOneBills, FifteentoTwentyOne, 
TwentyTwotoThirtyBills, TwentyTwotoThirty, 
LessthanThirtyBills, LessthanThirty, 
ThirtyOnetoSixtyBills, ThirtyOnetoSixty, 
SixtyOnetoNinetyBills, SixtyOnetoNinety, 
MorethanNinetyBills, MorethanNinety)
select Customer.CustomerID, 0 - sum(Creditnote.Balance),
(Select Count(*) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Seven And @One And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Seven And @One And
Cr.Balance > 0),
(Select Count(*) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Ten And @Eight And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Ten And @Eight And
Cr.Balance > 0),
(Select Count(*) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Fourteen And @Eleven And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Fourteen And @Eleven And
Cr.Balance > 0),
(Select Count(*) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @TwentyOne And @Fifteen And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @TwentyOne And @Fifteen And
Cr.Balance > 0),
(Select Count(*) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Thirty And @TwentyTwo And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Thirty And @TwentyTwo And
Cr.Balance > 0),
(Select Count(*) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate > @Thirty And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate > @Thirty And
Cr.Balance > 0),
(Select Count(*) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Sixty And @ThirtyOne And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Sixty And @ThirtyOne And
Cr.Balance > 0),
(Select Count(*) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Ninety And @SixtyOne And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate Between @Ninety And @SixtyOne And
Cr.Balance > 0),
(Select Count(*) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate < @Ninety And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = Customer.CustomerID And
Cr.DocumentDate < @Ninety And
Cr.Balance > 0)
from Creditnote, Customer
where Creditnote.Customerid like Customer.CustomerID and
Creditnote.DocumentDate between @FromDate and @ToDate and  
Creditnote.Balance > 0 And
IsNull(Customer.ChannelType, 0) = @ChannelID
group by Customer.CustomerID

insert #temp(CustomerID, Value, 
OnetoSevenBills, OnetoSeven, 
EighttoTenBills, EighttoTen, 
EleventoFourteenBills, EleventoFourteen,
FifteentoTwentyOneBills, FifteentoTwentyOne, 
TwentyTwotoThirtyBills, TwentyTwotoThirty, 
LessthanThirtyBills, LessthanThirty, 
ThirtyOnetoSixtyBills, ThirtyOnetoSixty, 
SixtyOnetoNinetyBills, SixtyOnetoNinety, 
MorethanNinetyBills, MorethanNinety)
select Customer.CustomerID, sum(Debitnote.Balance),
(Select Count(*) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Seven And @One And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Seven And @One And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select Count(*) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Ten And @Eight And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Ten And @Eight And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select Count(*) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Fourteen And @Eleven And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Fourteen And @Eleven And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select Count(*) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @TwentyOne And @Fifteen And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @TwentyOne And @Fifteen And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select Count(*) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Thirty And @TwentyTwo And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Thirty And @TwentyTwo And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select Count(*) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate > @Thirty And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate > @Thirty And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select Count(*) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Sixty And @ThirtyOne And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Sixty And @ThirtyOne And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select Count(*) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Ninety And @SixtyOne And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate Between @Ninety And @SixtyOne And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select Count(*) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate < @Ninety And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = Customer.CustomerID And
Db.DocumentDate < @Ninety And
Db.balance > 0
And IsNull(Db.Status, 0) & 192 = 0)
from debitnote, Customer
where Debitnote.Customerid = Customer.CustomerID and
Debitnote.DocumentDate between @FromDate and @ToDate and  
Debitnote.Balance > 0 And
IsNull(Debitnote.Status, 0) & 192 = 0 And
IsNull(Customer.ChannelType, 0) = @ChannelID
group by Customer.CustomerID

insert #temp(CustomerID, Value, 
OnetoSevenBills, OnetoSeven, 
EighttoTenBills, EighttoTen, 
EleventoFourteenBills, EleventoFourteen,
FifteentoTwentyOneBills, FifteentoTwentyOne, 
TwentyTwotoThirtyBills, TwentyTwotoThirty, 
LessthanThirtyBills, LessthanThirty, 
ThirtyOnetoSixtyBills, ThirtyOnetoSixty, 
SixtyOnetoNinetyBills, SixtyOnetoNinety, 
MorethanNinetyBills, MorethanNinety)
Select Customer.CustomerID, 0 - Sum(Collections.Balance),
(Select Count(*) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Seven And @One And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Seven And @One And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select Count(*) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Ten And @Eight And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Ten And @Eight And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select Count(*) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Fourteen And @Eleven And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Fourteen And @Eleven And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select Count(*) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @TwentyOne And @Fifteen And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @TwentyOne And @Fifteen And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select Count(*) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Thirty And @TwentyTwo And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Thirty And @TwentyTwo And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select Count(*) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate > @Thirty And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate > @Thirty And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select Count(*) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Sixty And @ThirtyOne And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Sixty And @ThirtyOne And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select Count(*) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Ninety And @SixtyOne And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate Between @Ninety And @SixtyOne And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select Count(*) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate < @Ninety And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Customer.CustomerID And
Col.DocumentDate < @Ninety And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0)
From Collections, Customer
Where Collections.CustomerID = Customer.CustomerID And
Collections.DocumentDate Between @FromDate And @ToDate And
Collections.Balance > 0 And
IsNull(Collections.Status, 0) & 128 = 0 And
IsNull(Customer.ChannelType, 0) = @ChannelID
group by Customer.CustomerID

select  #temp.CustomerID, 
"CustomerID" = #temp.CustomerID,
"Customer" = Customer.Company_Name,
"Outstanding Value (%c)" = Sum(Value),
"1-7 Days No Of Bills" = Sum(OnetoSevenBills),
"1-7 Days Value (%c)" = Sum(OnetoSeven),
"8-10 Days No Of Bills" = Sum(EighttoTenBills),
"8-10 Days Value (%c)" = Sum(EighttoTen),
"11-14 Days No Of Bills" = Sum(EleventoFourteenBills),
"11-14 Days Value (%c)" = Sum(EleventoFourteen),
"15-21 Days No Of Bills" = Sum(FifteentoTwentyOneBills),
"15-21 Days Value (%c)" = Sum(FifteentoTwentyOne),
"22-30 Days No Of Bills" = Sum(TwentyTwotoThirtyBills),
"22-30 Days Value (%c)" = Sum(TwentyTwotoThirty),
"<30 Days No Of Bills" = Sum(LessthanThirtyBills),
"<30 Days Value (%c)" = Sum(LessthanThirty),
"31-60 Days No Of Bills" = Sum(ThirtyOnetoSixtyBills),
"31-60 Days Value (%c)" = Sum(ThirtyOnetoSixty),
"61-90 Days No Of Bills" = Sum(SixtyOnetoNinetyBills),
"61-90 Days Value (%c)" = Sum(SixtyOnetoNinety),
">90 Days No Of Bills" = Sum(MorethanNinetyBills),
">90 Days Value (%c)" = Sum(MorethanNinety)
From #temp, Customer
Where #temp.CustomerID = Customer.CustomerID
group by #temp.CustomerID, Customer.Company_Name
drop table #temp

