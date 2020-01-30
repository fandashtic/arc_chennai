Create procedure spr_outstanding_allCustomers(@Dummy int,@FromDate datetime,@ToDate datetime)  
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
  
create table #temp (customerid nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,   
doccount int null,   
value Decimal(18,6)null,  
OnetoSeven Decimal(18,6) null,  
EighttoTen Decimal(18,6) null,  
EleventoFourteen Decimal(18,6) null,  
FifteentoTwentyOne Decimal(18,6) null,  
TwentyTwotoThirty Decimal(18,6) null,  
LessthanThirty Decimal(18,6) null,  
ThirtyOnetoSixty Decimal(18,6) null,  
SixtyOnetoNinety Decimal(18,6) null,  
MorethanNinety Decimal(18,6) null)  
  
insert #temp(customerid, doccount, value, OnetoSeven, EighttoTen, EleventoFourteen,  
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,   
SixtyOnetoNinety, MorethanNinety)  
select InvoiceAbstract.CustomerID,  
 count(InvoiceID),  
(Select sum( case A.InvoiceType   
 when 4 then (0 - isnull(A.Balance, 0))   
 when 5 then (0 - isnull(A.Balance, 0))   
 when 6 then (0 - isnull(A.Balance, 0))   
 else isnull(A.Balance, 0) end)  
from InvoiceAbstract A  
where  A.Balance > 0 and A.CustomerID  = InvoiceAbstract.CustomerID And  
 A.InvoiceType in (1, 2, 3, 4, 5, 6) and  
 A.Status & 128 = 0 And A.InvoiceDate between @FromDate and @ToDate),  
(Select Sum(Case Inv.InvoiceType  
When 4 Then  0 - IsNull(Inv.Balance, 0)   
When 5 Then  0 - IsNull(Inv.Balance, 0)   
When 6 Then  0 - IsNull(Inv.Balance, 0)   
Else IsNull(Inv.Balance, 0)   
End) From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Seven And @One And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType  
When 4 Then 0 - IsNull(Inv.Balance, 0)   
When 5 Then 0 - IsNull(Inv.Balance, 0)   
When 6 Then 0 - IsNull(Inv.Balance, 0)   
Else  
IsNull(Inv.Balance, 0)   
End) From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Ten And @Eight And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType  
When 4 Then 0 - IsNull(Inv.Balance, 0)   
When 5 Then 0 - IsNull(Inv.Balance, 0)   
When 6 Then 0 - IsNull(Inv.Balance, 0)   
Else  
IsNull(Inv.Balance, 0)   
End) From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Fourteen And @Eleven And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType  
When 4 Then  0 - IsNull(Inv.Balance, 0)   
When 5 Then  0 - IsNull(Inv.Balance, 0)   
When 6 Then  0 - IsNull(Inv.Balance, 0)   
Else IsNull(Inv.Balance, 0)   
End) From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @TwentyOne And @Fifteen And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType  
When 4 Then 0 - IsNull(Inv.Balance, 0)   
When 5 Then 0 - IsNull(Inv.Balance, 0)   
When 6 Then 0 - IsNull(Inv.Balance, 0)   
Else  
IsNull(Inv.Balance, 0)   
End) From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Thirty And @TwentyTwo And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType  
When 4 Then 0 - IsNull(Inv.Balance, 0)   
When 5 Then 0 - IsNull(Inv.Balance, 0)   
When 6 Then 0 - IsNull(Inv.Balance, 0)   
Else  
IsNull(Inv.Balance, 0)   
End) From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate > @Thirty And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType  
When 4 Then 0 - IsNull(Inv.Balance, 0)   
When 5 Then 0 - IsNull(Inv.Balance, 0)   
When 6 Then 0 - IsNull(Inv.Balance, 0)   
Else  
IsNull(Inv.Balance, 0)   
End) From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Sixty And @ThirtyOne And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType  
When 4 Then 0 - IsNull(Inv.Balance, 0)   
When 5 Then 0 - IsNull(Inv.Balance, 0)   
When 6 Then 0 - IsNull(Inv.Balance, 0)   
Else  
IsNull(Inv.Balance, 0)   
End) From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate Between @Ninety And @SixtyOne And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0),  
(Select Sum(Case Inv.InvoiceType  
When 4 Then 0 - IsNull(Inv.Balance, 0)   
When 5 Then 0 - IsNull(Inv.Balance, 0)   
When 6 Then 0 - IsNull(Inv.Balance, 0)   
Else IsNull(Inv.Balance, 0)   
End) From InvoiceAbstract As Inv  
Where Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceDate < @Ninety And  
Inv.Balance > 0 And  
Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And  
Inv.Status & 128 = 0)  
from InvoiceAbstract  
where --InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
 InvoiceAbstract.Balance > 0 and   
 InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) and  
 InvoiceAbstract.Status & 128 = 0  
group by InvoiceAbstract.CustomerID  
  
insert #temp(customerid, doccount, value, OnetoSeven, EighttoTen, EleventoFourteen,  
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,   
SixtyOnetoNinety, MorethanNinety)  
select creditnote.CustomerID,   
 count(CreditID),   
(select 0 - sum(C.Balance)from  creditnote C  
 where C.CustomerID = creditnote.CustomerID  
 And C.DocumentDate between @FromDate and @ToDate),  
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
Cr.Balance > 0)  
from creditnote  
where creditnote.CustomerID is not null and  
creditnote.Balance > 0  --and creditnote.DocumentDate between @FromDate and @ToDate   
group by creditnote.CustomerID    
  
insert #temp(customerid, doccount, Value, OnetoSeven, EighttoTen, EleventoFourteen,  
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,   
SixtyOnetoNinety, MorethanNinety)  
select debitnote.CustomerID,   
 count(DebitID),   
(Select sum(D.Balance) From Debitnote D  
 Where D.CustomerID = Debitnote.CustomerID  
 And D.DocumentDate between @FromDate and @ToDate),  
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
Db.balance > 0)  
from debitnote  
where debitnote.CustomerID is not null and  
debitnote.Balance > 0  --and debitnote.DocumentDate between @FromDate and @ToDate   
group by debitnote.CustomerID    
  
insert #temp(CustomerID, DocCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,  
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,   
SixtyOnetoNinety, MorethanNinety)  
Select Collections.CustomerID, Count(DocumentID) ,  
(Select 0 - IsNull(Sum(Balance), 0) From Collections  
 Where DocumentDate Between @FromDate And @ToDate Group By Collections.CustomerID),  
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
Col.Balance > 0)  
From Collections  
Where IsNull(Balance, 0) > 0 And  
IsNull(Status, 0) & 128 = 0 --And DocumentDate Between @FromDate And @ToDate  
Group By Collections.CustomerID  
  
select #temp.customerid,   
 "CustomerID" = #temp.customerid,   
 "Customer" =  Customer.Company_Name,  
 "No. Of Documents" = sum(Isnull(doccount,0)),
 "OutStanding Value" = sum(Isnull(value,0)),  
 "1-7 Days" = Sum(Isnull(OnetoSeven,0)),  
 "8-10 Days" = Sum(Isnull(EighttoTen,0)),  
 "11-14 Days" = Sum(Isnull(EleventoFourteen,0)),  
 "15-21 Days" = Sum(Isnull(FifteentoTwentyOne,0)),  
 "22-30 Days" = Sum(Isnull(TwentyTwotoThirty,0)),  
 "<30 Days" = Sum(Isnull(LessthanThirty,0)),  
 "31-60 Days" = Sum(Isnull(ThirtyOnetoSixty,0)),  
 "61-90 Days" = Sum(Isnull(SixtyOnetoNinety,0)),  
 ">90 Days" = Sum(Isnull(MorethanNinety,0))  
from #temp, Customer  
where #temp.customerid collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID  
group By #temp.customerid,Customer.Company_Name  
drop table #temp  
