CREATE procedure spr_list_Customer_OutStandingGill( @Customer nvarchar(2550),
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
Declare @TotValue As decimal(18,6)
Declare @CFValue As decimal(18,6)
Declare @SumCFValue as decimal(18,6)
Declare @cusid as nvarchar(40)

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

Create table #tmpCus(CustomerID nvarchar(255))  

if @Customer ='%'   
   Insert into #tmpCus select CustomerID from Customer
Else  
   Insert into #tmpCus select * from dbo.sp_SplitIn2Rows(@Customer, @Delimeter)  


Set @SumCFValue=0.00

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
(CustomerID nvarchar(15),  
NoteCount int null,  
Value Decimal(18,6) null,
OnetoSeven Decimal(18,6) null,
EighttoTen Decimal(18,6) null,
EleventoFourteen Decimal(18,6) null,
FifteentoTwentyOne Decimal(18,6) null,
TwentyTwotoThirty Decimal(18,6) null,
LessthanThirty Decimal(18,6) null,
ThirtyOnetoSixty Decimal(18,6) null,
SixtyOnetoNinety Decimal(18,6) null,
MorethanNinety Decimal(18,6) null,
CumValue Decimal(18,6),
NotOverDue Decimal(18,6)
)

insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety,NotOverDue)
select InvoiceAbstract.CustomerID, count(InvoiceID), sum(InvoiceAbstract.Balance),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
--IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Seven And @One And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
--IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Ten And @Eight And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
--IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Fourteen And @Eleven And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End) 
--IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @TwentyOne And @Fifteen And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
--IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Thirty And @TwentyTwo And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
--IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate > @Thirty And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End)
--IsNull(Sum(Inv.Balance), 0) 
From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Sixty And @ThirtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3,4) And
Inv.Status & 128 = 0),
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) Else IsNull(Inv.Balance,0) End) 
--IsNull(Sum(Inv.Balance), 0) 
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
where Invoiceabstract.Customerid In (Select CustomerID From #tmpCus) and
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

insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety,NotOverDue)
select Creditnote.CustomerID, count(CreditID), 0 - sum(Creditnote.Balance),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate Between @Seven And @One And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate Between @Ten And @Eight And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate Between @Fourteen And @Eleven And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate Between @TwentyOne And @Fifteen And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate Between @Thirty And @TwentyTwo And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate > @Thirty And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate Between @Sixty And @ThirtyOne And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate Between @Ninety And @SixtyOne And
Cr.Balance > 0),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.CustomerID = CreditNote.CustomerID And
Cr.DocumentDate < @Ninety And
Cr.Balance > 0),
0 - sum(Creditnote.Balance)
from Creditnote
where Creditnote.Customerid In (Select CustomerID From #tmpCus) and
Creditnote.DocumentDate between @FromDate and @ToDate and  
Creditnote.Balance > 0 
group by Creditnote.CustomerID  

insert #temp(CustomerID,Notecount , Value, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety,NotOverdue)
select Debitnote.CustomerID, count(DebitId), sum(Debitnote.Balance),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate Between @Seven And @One And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate Between @Ten And @Eight And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate Between @Fourteen And @Eleven And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate Between @TwentyOne And @Fifteen And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate Between @Thirty And @TwentyTwo And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate > @Thirty And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate Between @Sixty And @ThirtyOne And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate Between @Ninety And @SixtyOne And
Db.balance > 0),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.CustomerID = DebitNote.CustomerID And
Db.DocumentDate < @Ninety And
Db.balance > 0),
sum(Debitnote.Balance)
from debitnote
where Debitnote.Customerid In (Select CustomerID From #tmpCus) and
Debitnote.DocumentDate between @FromDate and @ToDate and  
Debitnote.Balance > 0 
group by Debitnote.CustomerID  

insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety,NotOverdue)
Select Collections.CustomerID, Count(DocumentID), 0 - Sum(Collections.Balance),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate Between @Seven And @One And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate Between @Ten And @Eight And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate Between @Fourteen And @Eleven And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate Between @TwentyOne And @Fifteen And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate Between @Thirty And @TwentyTwo And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate > @Thirty And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.CustomerID = Collections.CustomerID And
Col.DocumentDate Between @Sixty And @ThirtyOne And
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
0 - Sum(Collections.Balance)
From Collections
Where Collections.CustomerID In (Select CustomerID From #tmpCus) And
Collections.DocumentDate Between @FromDate And @ToDate And
Collections.Balance > 0 And
IsNull(Collections.Status, 0) & 128 = 0
Group By Collections.CustomerID

Declare  CFCursor Cursor for
   Select Customerid, Sum(Value) from #temp group by Customerid
Open CFCursor
  fetch next from CFCursor into @cusid,@CFValue
   While @@fetch_status =0
    begin
           Set @SumCFValue=@SumCFValue + @CFValue
	   Update #temp set CumValue=@SumCFValue where Customerid=@cusid
	     fetch next from CFCursor into @cusid,@CFValue
    end
   close CFCursor
deallocate CFCursor

Select @TotValue=sum(Value) From #temp


select  #temp.CustomerID, "CustomerID" = #temp.CustomerID, 
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
"Average Sale For 3 Months"=(Select Sum(case when Invoicetype=4 then 0-Netvalue else Netvalue  end )/ 3 from InvoiceAbstract
				Where Invoicetype<>2 and (Status & 128) =0
				And CustomerId=#temp.CustomerId
			and Invoicedate between dateadd(d,-90,@todate) and @todate),
"Cumulative % of the Outstanding"=Cast(((CumValue/@TotValue)*100) as decimal(18,6)),
"Outstanding Value (%c)" = Sum(Value),
"1-7 Days" = Sum(OnetoSeven),
"8-10 Days" = Sum(EighttoTen),
"11-14 Days" = Sum(EleventoFourteen),
"15-21 Days" = Sum(FifteentoTwentyOne),
"22-30 Days" = Sum(TwentyTwotoThirty),
"<30 Days" = Sum(LessthanThirty),
"31-60 Days" = Sum(ThirtyOnetoSixty),
"61-90 Days" = Sum(SixtyOnetoNinety),
">90 Days" = Sum(MorethanNinety)
From #temp, Customer  
where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID
group by #temp.CustomerID, Customer.Company_Name,#temp.CumValue  

drop table #temp
drop table #tmpCus


