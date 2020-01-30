CREATE procedure spr_list_Pidilite_Customer_OutStanding( @Customer nvarchar(2550),
					      @FromDate datetime,  
					      @ToDate datetime)  
as 
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

Declare @One As Datetime
Declare @Fifteen As Datetime
Declare @Sixteen As Datetime
Declare @Thirty As Datetime
Declare @ThirtyOne As Datetime
Declare @FourtyFive As Datetime
Declare @FourtySix As Datetime
Declare @Sixty As Datetime
Declare @SixtyOne As Datetime
Declare @Ninety As Datetime
-- Declare @ThirtyOne As Datetime
-- Declare @Sixty As Datetime
-- Declare @SixtyOne As Datetime
-- Declare @Ninety As Datetime
-- Declare @NinetyOne as Datetime
-- Declare @OneTwenty as datetime


Set @One = Cast(Datepart(dd, GetDate()) As nvarchar) + '/' +
Cast(Datepart(mm, GetDate()) As nvarchar) + '/' +
Cast(Datepart(yyyy, GetDate()) As nvarchar)
Set @Fifteen = DateAdd(d, -15, @One)
--Select @One
--Select @Fifteen
Set @Sixteen = DateAdd(d, -1, @Fifteen)
Set @Thirty = DateAdd(d, -14, @Sixteen)
Set @ThirtyOne = DateAdd(d, -1, @Thirty)
Set @FourtyFive = DateAdd(d, -14, @ThirtyOne)
Set @FourtySix = DateAdd(d, -1, @FourtyFive)
Set @Sixty = DateAdd(d, -14, @FourtySix)
Set @SixtyOne = DateAdd(d, -1, @Sixty)
Set @Ninety = DateAdd(d, -29, @SixtyOne)
-- Set @ThirtyOne = DateAdd(d, -1, @Thirty)
-- Set @Sixty = DateAdd(d, -29, @ThirtyOne)
-- Set @SixtyOne = DateAdd(d, -1, @Sixty)
-- Set @Ninety = DateAdd(d, -29, @SixtyOne)
-- Set @NinetyOne = DateAdd(d, -1, @Ninety)
-- Set @OneTwenty = DateAdd(d, -29, @NinetyOne)

Set @One = dbo.MakeDayEnd(@One)
--Set @Fifteen = dbo.MakeDayEnd(@Fifteen)
--Select @Fifteen
Set @Sixteen = dbo.MakeDayEnd(@Sixteen)
Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)
Set @FourtySix = dbo.MakeDayEnd(@FourtySix)
Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)
-- Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)
-- Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)
-- Set @NinetyOne= dbo.MakeDayEnd(@NinetyOne)

create table #tmpCust(customerid nvarchar(255))
if @Customer='%'
   insert into #tmpCust select customerid from customer
else
   insert into #tmpCust select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)

create table #temp
(CustomerID nvarchar(15),  
NoteCount int null,  
Value Decimal(18,6) null,
LessthanFifteen Decimal(18,6) null,
--EighttoTen Decimal(18,6) null,
SixteenToThirty Decimal(18,6) null,
ThirtyOneToFourtyFive Decimal(18,6) null,
FourtysixToSixty Decimal(18,6) null,
SixtyOneToNinety Decimal(18,6) null,
GreaterthanNinety Decimal(18,6) null,
-- SixtyOnetoNinety Decimal(18,6) null,
-- NinetyonetoOneTwenty Decimal(18,6) null,
-- MorethanOneTwenty Decimal(18,6) null,
NotOverDue Decimal(18,6)
)


insert #temp(CustomerID, NoteCount, Value, LessthanFifteen, SixteenToThirty, ThirtyOneToFourtyFive,
FourtysixToSixty, SixtyOneToNinety, GreaterthanNinety, --ThirtyOnetoSixty, 
--SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,
NotOverDue)
select InvoiceAbstract.CustomerID, count(InvoiceID), sum(InvoiceAbstract.Balance),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
-- IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate >= @Fifteen And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3, 4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
-- IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Thirty And @Sixteen And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
-- IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @FourtyFive And @ThirtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
-- IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Sixty And @FourtySix And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
-- IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Ninety And @SixtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
--IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate < @Ninety And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
-- (Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
-- --IsNull(Sum(Inv.Balance), 0) 
-- From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate Between @Sixty And @ThirtyOne And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (1, 3,4) And
-- Inv.Status & 128 = 0),
-- (Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
-- --IsNull(Sum(Inv.Balance), 0) 
-- From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate Between @Ninety And @SixtyOne And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (1, 3,4) And
-- Inv.Status & 128 = 0),
-- (Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
-- --IsNull(Sum(Inv.Balance), 0) 
-- From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate Between @OneTwenty And @NinetyOne And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (1, 3,4) And
-- Inv.Status & 128 = 0),
-- (Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
-- --IsNull(Sum(Inv.Balance), 0) 
-- From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate < @OneTwenty And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (1, 3,4) And
-- Inv.Status & 128 = 0),
---Added
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
--IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.PaymentDate >=@ToDate and
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0 And
Inv.InvoiceDate between @FromDate and @ToDate
)

from InvoiceAbstract
where Invoiceabstract.Customerid in(select customerid from #tmpCust) and
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
InvoiceAbstract.Balance > 0 and   
InvoiceAbstract.InvoiceType in (1, 3,4) and  
InvoiceAbstract.Status & 128 = 0  
group by InvoiceAbstract.CustomerID  

-- insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,
-- FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
-- SixtyOnetoNinety, MorethanNinety,NotOverDue)
-- select InvoiceAbstract.CustomerID, count(InvoiceID), 0 - sum(InvoiceAbstract.Balance),
-- (Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate Between @Seven And @One And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (4) And
-- Inv.Status & 128 = 0),
-- (Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate Between @Ten And @Eight And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (4) And
-- Inv.Status & 128 = 0),
-- (Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate Between @Fourteen And @Eleven And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (4) And
-- Inv.Status & 128 = 0),
-- (Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate Between @TwentyOne And @Fifteen And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (4) And
-- Inv.Status & 128 = 0),
-- (Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate Between @Thirty And @TwentyTwo And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (4) And
-- Inv.Status & 128 = 0),
-- (Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate > @Thirty And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (4) And
-- Inv.Status & 128 = 0),
-- (Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate Between @Sixty And @ThirtyOne And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (4) And
-- Inv.Status & 128 = 0),
-- (Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate Between @Ninety And @SixtyOne And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (4) And
-- Inv.Status & 128 = 0),
-- (Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.InvoiceDate < @Ninety And
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (4) And
-- Inv.Status & 128 = 0),
-- --Added
-- (Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
-- Where Inv.CustomerID = InvoiceAbstract.CustomerID And
-- Inv.PaymentDate >=@ToDate and
-- Inv.Balance > 0 And
-- Inv.InvoiceType In (4) And
-- Inv.Status & 128 = 0 and
-- Inv.InvoiceDate between @FromDate and @ToDate
-- )
-- 
-- from InvoiceAbstract
-- where InvoiceAbstract.CustomerID like @Customer and  
-- InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
-- InvoiceAbstract.Balance > 0 and   
-- InvoiceAbstract.InvoiceType in (4) and  
-- InvoiceAbstract.Status & 128 = 0  
-- group by InvoiceAbstract.CustomerID  

insert #temp(CustomerID, NoteCount, Value, LessthanFifteen, SixteenToThirty, ThirtyOneToFourtyFive,
FourtysixToSixty, SixtyOneToNinety, GreaterthanNinety, -- ThirtyOnetoSixty, 
--SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,
NotOverDue)
select Creditnote.CustomerID, count(CreditID), 0 - sum(Creditnote.Balance),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate >= @Fifteen And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate Between @Thirty And @Sixteen And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate Between @FourtyFive And @ThirtyOne And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate Between @Sixty And @FourtySix And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate Between @Ninety And @SixtyOne And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate < @Ninety And
Cr.Balance > 0),
-- (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
-- Where Cr.CustomerID = CreditNote.CustomerID And
-- Cr.DocumentDate Between @Sixty And @ThirtyOne And
-- Cr.Balance > 0),
-- (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
-- Where Cr.CustomerID = CreditNote.CustomerID And
-- Cr.DocumentDate Between @Ninety And @SixtyOne And
-- Cr.Balance > 0),
-- (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
-- Where Cr.CustomerID = CreditNote.CustomerID And
-- Cr.DocumentDate Between @OneTwenty And @NinetyOne And
-- Cr.Balance > 0),
-- (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
-- Where Cr.CustomerID = CreditNote.CustomerID And
-- Cr.DocumentDate < @OneTwenty And
-- Cr.Balance > 0),
0 - sum(Creditnote.Balance)
from Creditnote
where Creditnote.Customerid in(select customerid from #tmpCust) and
Creditnote.DocumentDate between @FromDate and @ToDate and  
Creditnote.Balance > 0 
group by Creditnote.CustomerID  

insert #temp(CustomerID, NoteCount, Value, LessthanFifteen, SixteenToThirty, ThirtyOneToFourtyFive,
FourtysixToSixty, SixtyOneToNinety, GreaterthanNinety, -- ThirtyOnetoSixty, 
--SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,
NotOverDue)
select Debitnote.CustomerID, count(DebitId), sum(Debitnote.Balance),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate >= @Fifteen And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate Between @Thirty And @Sixteen And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate Between @FourtyFive And @ThirtyOne And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate Between @Sixty And @FourtySix And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate Between @Ninety And @SixtyOne And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate < @Ninety And
Db.balance > 0),
-- (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
-- Where Db.CustomerID = DebitNote.CustomerID And
-- Db.DocumentDate Between @Sixty And @ThirtyOne And
-- Db.balance > 0),
-- (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
-- Where Db.CustomerID = DebitNote.CustomerID And
-- Db.DocumentDate Between @Ninety And @SixtyOne And
-- Db.balance > 0),
-- (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
-- Where Db.CustomerID = DebitNote.CustomerID And
-- Db.DocumentDate Between @OneTwenty And @NinetyOne And
-- Db.balance > 0),
-- (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
-- Where Db.CustomerID = DebitNote.CustomerID And
-- Db.DocumentDate < @OneTwenty And
-- Db.balance > 0),
sum(Debitnote.Balance)
from debitnote
where Debitnote.Customerid in(select customerid from #tmpCust) and
Debitnote.DocumentDate between @FromDate and @ToDate and  
Debitnote.Balance > 0 
group by Debitnote.CustomerID  

insert #temp(CustomerID, NoteCount, Value, LessthanFifteen, SixteenToThirty, ThirtyOneToFourtyFive,
FourtysixToSixty, SixtyOneToNinety, GreaterthanNinety, -- ThirtyOnetoSixty, 
--SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,
NotOverDue)
Select Collections.CustomerID, Count(DocumentID), 0 - Sum(Collections.Balance),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate >= @Fifteen And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate Between @Thirty And @Sixteen And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate Between @FourtyFive And @ThirtyOne And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate Between @Sixty And @FourtySix And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate Between @Ninety And @SixtyOne And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate < @Ninety And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
-- (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
-- Where Col.CustomerID = Collections.CustomerID And
-- Col.DocumentDate Between @Sixty And @ThirtyOne And
-- IsNull(Col.Status, 0) & 128 = 0 And
-- Col.Balance > 0),
-- (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
-- Where Col.CustomerID = Collections.CustomerID And
-- Col.DocumentDate Between @Ninety And @SixtyOne And
-- IsNull(Col.Status, 0) & 128 = 0 And
-- Col.Balance > 0),
-- (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
-- Where Col.CustomerID = Collections.CustomerID And
-- Col.DocumentDate Between @OneTwenty And @NinetyOne And
-- IsNull(Col.Status, 0) & 128 = 0 And
-- Col.Balance > 0),
-- (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
-- Where Col.CustomerID = Collections.CustomerID And
-- Col.DocumentDate < @OneTwenty And
-- IsNull(Col.Status, 0) & 128 = 0 And
-- Col.Balance > 0),

0 - Sum(Collections.Balance)
From Collections
Where Collections.CustomerID in(select customerid from #tmpCust) And
Collections.DocumentDate Between @FromDate And @ToDate And
Collections.Balance > 0 And
IsNull(Collections.Status, 0) & 128 = 0
Group By Collections.CustomerID


select  #temp.CustomerID, "CustomerID" = #temp.CustomerID, 
"Forum Code"=(Select AlternateCode from Customer where CustomerId=#temp.CustomerID),
"Beat Name"=dbo.fn_GetBeatDescForCus(#temp.CustomerID),
"Channel Type"=(Select Customer_Channel.ChannelDesc
			From Customer,Customer_Channel
			Where Customer.ChannelType=Customer_Channel.ChannelType
			and Customer.Customerid=#temp.CustomerID),
"Credit Term"=dbo.fn_GetCreditTermForCus(#temp.CustomerID),
"Customer" = Customer.Company_Name, "No of Docs" = sum(Notecount),  
"Not Over Due"=Sum(NotOverDue),
"Over Due"=(Select Sum(case when Invoicetype=4 then 0-balance else balance  end ) from InvoiceAbstract
		Where Invoicetype<>2 and (Status & 128) =0 And CustomerId=#temp.CustomerId
		and PaymentDate < @ToDate and Invoicedate between @fromdate and @todate And Balance <> 0 ),
"Outstanding Value (%c)" = Sum(Value),

"<15 Days" = Sum(LessthanFifteen),
"16-30 Days" = Sum(SixteenToThirty),
"31-45 Days" = Sum(ThirtyOneToFourtyFive),
"46-60 Days" = Sum(FourtysixToSixty),
"61-90 Days" = Sum(SixtyOneToNinety),
">90 Days" = Sum(GreaterthanNinety)
-- "31-60 Days" = Sum(ThirtyOnetoSixty),
-- "61-90 Days" = Sum(SixtyOnetoNinety),
-- "91-120 Days" = Sum(NinetyonetoOneTwenty),
-- ">120 Days" = Sum(MorethanOneTwenty)
From #temp, Customer  
where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID
group by #temp.CustomerID, Customer.Company_Name 

drop table #temp
drop table #tmpCust



