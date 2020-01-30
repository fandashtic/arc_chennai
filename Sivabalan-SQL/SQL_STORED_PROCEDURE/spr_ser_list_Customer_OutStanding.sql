CREATE procedure spr_ser_list_Customer_OutStanding(@Customer nvarchar(2550),  
           @FromDate datetime,    
           @ToDate datetime)    
as   	
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
  
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
Declare @NinetyOne as Datetime  
Declare @OneTwenty as datetime  
  
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
Set @NinetyOne = DateAdd(d, -1, @Ninety)  
Set @OneTwenty = DateAdd(d, -29, @NinetyOne)  
  
Set @One = dbo.sp_ser_MakeDayEnd(@One)  
Set @Eight = dbo.sp_ser_MakeDayEnd(@Eight)  
Set @Eleven = dbo.sp_ser_MakeDayEnd(@Eleven)  
Set @Fifteen = dbo.sp_ser_MakeDayEnd(@Fifteen)  
Set @TwentyTwo = dbo.sp_ser_MakeDayEnd(@TwentyTwo)  
Set @ThirtyOne = dbo.sp_ser_MakeDayEnd(@ThirtyOne)  
Set @SixtyOne = dbo.sp_ser_MakeDayEnd(@SixtyOne)  
Set @NinetyOne= dbo.sp_ser_MakeDayEnd(@NinetyOne)  
  
create table #tmpCust(customerid nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @Customer='%'  
   insert into #tmpCust select customerid from customer  
else  
   insert into #tmpCust select * from dbo.sp_ser_SplitIn2Rows(@Customer,@Delimeter)  
  
create table #temp  
(CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
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
NinetyonetoOneTwenty Decimal(18,6) null,  
MorethanOneTwenty Decimal(18,6) null,  
NotOverDue Decimal(18,6)  
)  

insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,  
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,   
SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,NotOverDue)  

Select InvoiceAbstract.CustomerID, count(InvoiceID),
Sum(Case InvoiceAbstract.InvoiceType When 4 then 0-Isnull(InvoiceAbstract.Balance,0) 
When 5 then 0-Isnull(InvoiceAbstract.Balance,0) When 6 then 0-Isnull(InvoiceAbstract.Balance,0)
Else IsNull(InvoiceAbstract.Balance,0) End),  

(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) 
When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0)
Else IsNull(Inv.Balance,0) End)  
From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Seven And @One And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  

(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0) 
Else IsNull(Inv.Balance,0) End)  
From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Ten And @Eight And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) 
When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0) 
Else IsNull(Inv.Balance,0) End)  
From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Fourteen And @Eleven And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  

(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) 
When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0)
Else IsNull(Inv.Balance,0) End)  
From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @TwentyOne And @Fifteen And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) 
When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0) 
Else IsNull(Inv.Balance,0) End)  
From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Thirty And @TwentyTwo And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  

(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) 
When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0) 
Else IsNull(Inv.Balance,0) End)  
From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate > @Thirty And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) 
When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0) 
Else IsNull(Inv.Balance,0) End)  
From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Sixty And @ThirtyOne And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  

(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) 
When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0) 
Else IsNull(Inv.Balance,0) End)  
From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Ninety And @SixtyOne And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) 
When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0) 
Else IsNull(Inv.Balance,0) End)  
From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @OneTwenty And @NinetyOne And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  

(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) 
When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0) 
Else IsNull(Inv.Balance,0) End)  
From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate < @OneTwenty And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
---Added  
(Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0) 
When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0) 
Else IsNull(Inv.Balance,0) End)  
From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.PaymentDate >=@ToDate and  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0 And  
Inv.InvoiceDate between @FromDate and @ToDate)  
from InvoiceAbstract  
where Invoiceabstract.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and  
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
InvoiceAbstract.Balance > 0 and     
InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) and    
InvoiceAbstract.Status & 128 = 0    
group by InvoiceAbstract.CustomerID    
 
insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,  
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,   
SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,NotOverDue)  

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
Cr.DocumentDate Between @OneTwenty And @NinetyOne And  
Cr.Balance > 0),  
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr  
Where Cr.CustomerID = CreditNote.CustomerID And  
Cr.DocumentDate < @OneTwenty And  
Cr.Balance > 0),  
0 - sum(Creditnote.Balance)  
from Creditnote  
where Creditnote.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and  
Creditnote.DocumentDate between @FromDate and @ToDate and    
Creditnote.Balance > 0   
group by Creditnote.CustomerID    
  
insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,  
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,   
SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,NotOverDue)  
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
Db.DocumentDate Between @OneTwenty And @NinetyOne And  
Db.balance > 0),  
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db  
Where Db.CustomerID = DebitNote.CustomerID And  
Db.DocumentDate < @OneTwenty And  
Db.balance > 0),  
sum(Debitnote.Balance)  
from debitnote  
where Debitnote.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and  
Debitnote.DocumentDate between @FromDate and @ToDate and    
Debitnote.Balance > 0   
group by Debitnote.CustomerID    
  
insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,  
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,   
SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,NotOverDue)  
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
Col.DocumentDate Between @OneTwenty And @NinetyOne And  
IsNull(Col.Status, 0) & 128 = 0 And  
Col.Balance > 0),  
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col  
Where Col.CustomerID = Collections.CustomerID And  
Col.DocumentDate < @OneTwenty And  
IsNull(Col.Status, 0) & 128 = 0 And  
Col.Balance > 0),  
  
0 - Sum(Collections.Balance)  
From Collections  
Where Collections.CustomerID in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) And  
Collections.DocumentDate Between @FromDate And @ToDate And  
Collections.Balance > 0 And  
IsNull(Collections.Status, 0) & 128 = 0  
Group By Collections.CustomerID  


insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,  
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,   
SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,NotOverDue)  

select ServiceInvoiceAbstract.CustomerID,Count(ServiceInvoiceID),
Sum(ServiceInvoiceAbstract.Balance),

(Select Sum(SerAbs.Balance) From ServiceInvoiceAbstract As SerAbs
Where SerAbs.CustomerID = ServiceInvoiceAbstract.CustomerID 
And SerAbs.ServiceInvoiceDate Between @Seven And @One 
And IsNull(SerAbs.Balance,0) > 0 
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0),

(Select Sum(SerAbs.Balance) From ServiceInvoiceAbstract As SerAbs  
Where SerAbs.CustomerID = ServiceInvoiceAbstract.CustomerID 
And SerAbs.ServiceInvoiceDate Between @Ten And @Eight 
And IsNull(SerAbs.Balance,0) > 0 
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0),

(Select Sum(SerAbs.Balance) From ServiceInvoiceAbstract As SerAbs
Where SerAbs.CustomerID = ServiceInvoiceAbstract.CustomerID 
And SerAbs.ServiceInvoiceDate Between @Fourteen And @Eleven 
And IsNull(SerAbs.Balance,0) > 0 
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0),

(Select Sum(SerAbs.Balance) From ServiceInvoiceAbstract As SerAbs
Where SerAbs.CustomerID = ServiceInvoiceAbstract.CustomerID 
And SerAbs.ServiceInvoiceDate Between @TwentyOne And @Fifteen 
And IsNull(SerAbs.Balance,0) > 0 
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0),

(Select Sum(SerAbs.Balance) From ServiceInvoiceAbstract As SerAbs
Where SerAbs.CustomerID = ServiceInvoiceAbstract.CustomerID 
And SerAbs.ServiceInvoiceDate Between @Thirty And @TwentyTwo 
And IsNull(SerAbs.Balance,0) > 0 
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0),

(Select Sum(SerAbs.Balance) From ServiceInvoiceAbstract As SerAbs
Where SerAbs.CustomerID = ServiceInvoiceAbstract.CustomerID 
And SerAbs.ServiceInvoiceDate > @Thirty 
And IsNull(SerAbs.Balance,0) > 0 
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0),

(Select Sum(SerAbs.Balance) From ServiceInvoiceAbstract As SerAbs
Where SerAbs.CustomerID = ServiceInvoiceAbstract.CustomerID 
And SerAbs.ServiceInvoiceDate Between @Sixty And @ThirtyOne 
And IsNull(SerAbs.Balance,0) > 0 
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0),

(Select Sum(SerAbs.Balance) From ServiceInvoiceAbstract As SerAbs
Where SerAbs.CustomerID = ServiceInvoiceAbstract.CustomerID 
And SerAbs.ServiceInvoiceDate Between @Ninety And @SixtyOne 
And IsNull(SerAbs.Balance,0) > 0 
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0),

(Select Sum(SerAbs.Balance) From ServiceInvoiceAbstract As SerAbs
Where SerAbs.CustomerID = ServiceInvoiceAbstract.CustomerID 
And SerAbs.ServiceInvoiceDate Between @OneTwenty And @NinetyOne 
And IsNull(SerAbs.Balance,0) > 0 
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0),

(Select Sum(SerAbs.Balance) From ServiceInvoiceAbstract As SerAbs
Where SerAbs.CustomerID = ServiceInvoiceAbstract.CustomerID 
And SerAbs.ServiceInvoiceDate < @OneTwenty 
And IsNull(SerAbs.Balance,0) > 0 
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0),

(Select Sum(SerAbs.Balance) From ServiceInvoiceAbstract As SerAbs
Where SerAbs.CustomerID = ServiceInvoiceAbstract.CustomerID 
And SerAbs.PaymentDate >=@ToDate 
And IsNull(SerAbs.Balance,0) > 0 
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0
And SerAbs.ServiceInvoiceDate between @FromDate and @ToDate)  

From ServiceInvoiceAbstract  
where ServiceInvoiceabstract.Customerid in (select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)   
And ServiceInvoiceAbstract.ServiceInvoiceDate between @FromDate and @ToDate 
And IsNull(ServiceInvoiceAbstract.Balance,0) > 0 
And IsNull(ServiceInvoiceAbstract.ServiceInvoiceType,0) = 1
And IsNull(ServiceInvoiceAbstract.Status,0) & 192 = 0    
group by ServiceInvoiceAbstract.CustomerID
  
select  #temp.CustomerID, "Customer ID" = #temp.CustomerID,

"Forum Code"=(Select AlternateCode from Customer where CustomerId=#temp.CustomerID),  

"Beat Name"=dbo.sp_ser_GetBeatDescForCus(#temp.CustomerID),  

"Channel Type"=(Select Customer_Channel.ChannelDesc  
  From Customer,Customer_Channel  
   Where Customer.ChannelType=Customer_Channel.ChannelType  
   and Customer.Customerid=#temp.CustomerID),  

"Credit Term"=dbo.sp_ser_GetCreditTermForCus(#temp.CustomerID),  

"Customer" = Customer.Company_Name, "No of Docs" = sum(Notecount),    

"Not Over Due"=Sum(NotOverDue), 

"Over Due"=
Isnull((Select Sum(Case InvoiceType When 4 then 0-IsNull(Balance,0)
When 5 then 0-IsNull(Balance,0) When 6 then 0-IsNull(Balance,0)  
Else IsNull(Balance,0) End) from InvoiceAbstract 
Where Invoicetype In (1, 2, 3, 4, 5, 6) And (Status & 128) =0 
And CustomerId=#temp.CustomerId And PaymentDate < @ToDate 
And Invoicedate between @fromdate and @todate And Balance <> 0), 0)
+
Isnull((Select Sum(IsNull(Balance,0)) from ServiceInvoiceAbstract 
Where ServiceInvoicetype = 1 And IsNull(Status,0) & 192 =0 
And CustomerId=#temp.CustomerId And PaymentDate < @ToDate 
And ServiceInvoicedate between @fromdate and @todate And Balance <> 0), 0),  	


"Outstanding Value (%c)" = Sum(Value),  

"1-7 Days" = Sum(OnetoSeven),  
"8-10 Days" = Sum(EighttoTen),  
"11-14 Days" = Sum(EleventoFourteen),  
"15-21 Days" = Sum(FifteentoTwentyOne),  
"22-30 Days" = Sum(TwentyTwotoThirty),  
"<30 Days" = Sum(LessthanThirty),  
"31-60 Days" = Sum(ThirtyOnetoSixty),  
"61-90 Days" = Sum(SixtyOnetoNinety),  
"91-120 Days" = Sum(NinetyonetoOneTwenty),  
">120 Days" = Sum(MorethanOneTwenty)  
From #temp, Customer    
where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID  
group by #temp.CustomerID, Customer.Company_Name   
  
drop table #temp  
drop table #tmpCust  
  
