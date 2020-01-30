CREATE procedure sp_acc_rpt_list_Customer_OutStanding( @Customer nVarchar(20),
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

Set @One = Cast(Datepart(dd, dbo.Sp_Acc_GetOperatingDate(getdate())) As nVarchar) + N'/' +
Cast(Datepart(mm, dbo.Sp_Acc_GetOperatingDate(getdate())) As nVarchar) + N'/' +
Cast(Datepart(yyyy, dbo.Sp_Acc_GetOperatingDate(getdate())) As nVarchar)
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
Value decimal(18,6) null,
OnetoSeven Decimal(18, 6) null,
EighttoTen Decimal(18, 6) null,
EleventoFourteen Decimal(18, 6) null,
FifteentoTwentyOne Decimal(18, 6) null,
TwentyTwotoThirty Decimal(18, 6) null,
LessthanThirty Decimal(18, 6) null,
ThirtyOnetoSixty Decimal(18, 6) null,
SixtyOnetoNinety Decimal(18, 6) null,
MorethanNinety Decimal(18, 6) null)

insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
select InvoiceAbstract.CustomerID, count(InvoiceID), sum(InvoiceAbstract.Balance),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Seven And @One And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Ten And @Eight And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Fourteen And @Eleven And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @TwentyOne And @Fifteen And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Thirty And @TwentyTwo And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate > @Thirty And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Sixty And @ThirtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Ninety And @SixtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0),
(Select IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate < @Ninety And
Inv.Balance > 0 And
Inv.InvoiceType In (1, 3) And
Inv.Status & 128 = 0)
from InvoiceAbstract
where Invoiceabstract.Customerid like @Customer and
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
InvoiceAbstract.Balance > 0 and   
InvoiceAbstract.InvoiceType in (1, 3) and  
InvoiceAbstract.Status & 128 = 0  
group by InvoiceAbstract.CustomerID  

insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
select InvoiceAbstract.CustomerID, count(InvoiceID), 0 - sum(InvoiceAbstract.Balance),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Seven And @One And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Ten And @Eight And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Fourteen And @Eleven And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @TwentyOne And @Fifteen And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Thirty And @TwentyTwo And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate > @Thirty And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Sixty And @ThirtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate Between @Ninety And @SixtyOne And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0),
(Select 0 - IsNull(Sum(Inv.Balance), 0) From InvoiceAbstract As Inv
Where Inv.CustomerID = InvoiceAbstract.CustomerID And
Inv.InvoiceDate < @Ninety And
Inv.Balance > 0 And
Inv.InvoiceType In (4) And
Inv.Status & 128 = 0)
from InvoiceAbstract
where InvoiceAbstract.CustomerID like @Customer and  
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
InvoiceAbstract.Balance > 0 and   
InvoiceAbstract.InvoiceType in (4) and  
InvoiceAbstract.Status & 128 = 0  
group by InvoiceAbstract.CustomerID  

Create Table #TempCreditNote (TempCustomerID nVarchar(128),TempCreditID Int,TempDocumentDate DateTime,TempBalance Decimal(18,6))
Insert #TempCreditNote(TempCustomerID,TempCreditID,TempDocumentDate,TempBalance)
Select Case When CreditNote.CustomerID is not null then CreditNote.CustomerID 
Else (Select CustomerID from Customer where AccountID=IsNull(Others,0)) End,CreditID,DocumentDate,Balance
from Creditnote
where 
Creditnote.DocumentDate between @FromDate and @ToDate and  
Creditnote.Balance > 0 and
((CreditNote.CustomerID Is Not Null  and Creditnote.Customerid like @Customer)  or 
(CreditNote.Others Is Not Null and  (Select CustomerID from Customer where AccountID=IsNull(Others,0)) is Not Null))



insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
select #TempCreditNote.TempCustomerID, count(TempCreditID), 0 - sum(TempBalance),
(Select 0 - IsNull(Sum(Cr.TempBalance), 0) From #TempCreditNote As Cr
Where Cr.TempCustomerID = #TempCreditNote.TempCustomerID And
Cr.TempDocumentDate Between @Seven And @One And
Cr.TempBalance > 0),
(Select 0 - IsNull(Sum(Cr.TempBalance), 0) From #TempCreditNote As Cr
Where Cr.TempCustomerID = #TempCreditNote.TempCustomerID And
Cr.TempDocumentDate Between @Ten And @Eight And
Cr.TempBalance > 0),
(Select 0 - IsNull(Sum(Cr.TempBalance), 0) From #TempCreditNote As Cr
Where Cr.TempCustomerID = #TempCreditNote.TempCustomerID And
Cr.TempDocumentDate Between @Fourteen And @Eleven And
Cr.TempBalance > 0),
(Select 0 - IsNull(Sum(Cr.TempBalance), 0) From #TempCreditNote As Cr
Where Cr.TempCustomerID = #TempCreditNote.TempCustomerID And
Cr.TempDocumentDate Between @TwentyOne And @Fifteen And
Cr.TempBalance > 0),
(Select 0 - IsNull(Sum(Cr.TempBalance), 0) From #TempCreditNote As Cr
Where Cr.TempCustomerID = #TempCreditNote.TempCustomerID And
Cr.TempDocumentDate Between @Thirty And @TwentyTwo And
Cr.TempBalance > 0),
(Select 0 - IsNull(Sum(Cr.TempBalance), 0) From #TempCreditNote As Cr
Where Cr.TempCustomerID = #TempCreditNote.TempCustomerID And
Cr.TempDocumentDate > @Thirty And
Cr.TempBalance > 0),
(Select 0 - IsNull(Sum(Cr.TempBalance), 0) From #TempCreditNote As Cr
Where Cr.TempCustomerID = #TempCreditNote.TempCustomerID And
Cr.TempDocumentDate Between @Sixty And @ThirtyOne And
Cr.TempBalance > 0),
(Select 0 - IsNull(Sum(Cr.TempBalance), 0) From #TempCreditNote As Cr
Where Cr.TempCustomerID = #TempCreditNote.TempCustomerID And
Cr.TempDocumentDate Between @Ninety And @SixtyOne And
Cr.TempBalance > 0),
(Select 0 - IsNull(Sum(Cr.TempBalance), 0) From #TempCreditNote As Cr
Where Cr.TempCustomerID = #TempCreditNote.TempCustomerID And
Cr.TempDocumentDate < @Ninety And
Cr.TempBalance > 0)
from #TempCreditnote
where #TempCreditnote.TempCustomerid like @Customer
group by #TempCreditnote.TempCustomerID  


Create Table #TempDebitNote (TempCustomerID nVarchar(128),TempDebitID Int,TempDocumentDate DateTime,TempBalance Decimal(18,6))
Insert #TempDebitNote(TempCustomerID,TempDebitID,TempDocumentDate,TempBalance)
Select Case When DebitNote.CustomerID is not null then DebitNote.CustomerID 
Else (Select CustomerID from Customer where AccountID=IsNull(Others,0)) End,DebitID,DocumentDate,Balance
from DebitNote where 
DebitNote.DocumentDate between @FromDate and @ToDate and  
IsNull(Balance,0) > 0 and 
((DebitNote.CustomerID Is Not Null  and DebitNote.Customerid like @Customer)  or 
(DebitNote.Others Is Not Null and  (Select CustomerID from Customer where AccountID=IsNull(Others,0)) is Not Null))

 
insert #temp(CustomerID,Notecount , Value, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
select #TempDebitNote.TempCustomerID, count(TempDebitId), sum(#TempDebitNote.TempBalance),
(Select IsNull(Sum(Db.TempBalance), 0) From #TempDebitNote As Db
Where Db.TempCustomerID = #TempDebitNote.TempCustomerID And
Db.TempDocumentDate Between @Seven And @One And
Db.TempBalance > 0),
(Select IsNull(Sum(Db.TempBalance), 0) From #TempDebitNote As Db
Where Db.TempCustomerID = #TempDebitNote.TempCustomerID And
Db.TempDocumentDate Between @Ten And @Eight And
Db.TempBalance > 0),
(Select IsNull(Sum(Db.TempBalance), 0) From #TempDebitNote As Db
Where Db.TempCustomerID = #TempDebitNote.TempCustomerID And
Db.TempDocumentDate Between @Fourteen And @Eleven And
Db.TempBalance > 0),
(Select IsNull(Sum(Db.TempBalance), 0) From #TempDebitNote As Db
Where Db.TempCustomerID = #TempDebitNote.TempCustomerID And
Db.TempDocumentDate Between @TwentyOne And @Fifteen And
Db.TempBalance > 0),
(Select IsNull(Sum(Db.TempBalance), 0) From #TempDebitNote As Db
Where Db.TempCustomerID = #TempDebitNote.TempCustomerID And
Db.TempDocumentDate Between @Thirty And @TwentyTwo And
Db.TempBalance > 0),
(Select IsNull(Sum(Db.TempBalance), 0) From #TempDebitNote As Db
Where Db.TempCustomerID = #TempDebitNote.TempCustomerID And
Db.TempDocumentDate > @Thirty And
Db.TempBalance > 0),
(Select IsNull(Sum(Db.TempBalance), 0) From #TempDebitNote As Db
Where Db.TempCustomerID = #TempDebitNote.TempCustomerID And
Db.TempDocumentDate Between @Sixty And @ThirtyOne And
Db.TempBalance > 0),
(Select IsNull(Sum(Db.TempBalance), 0) From #TempDebitNote As Db
Where Db.TempCustomerID = #TempDebitNote.TempCustomerID And
Db.TempDocumentDate Between @Ninety And @SixtyOne And
Db.TempBalance > 0),
(Select IsNull(Sum(Db.TempBalance), 0) From #TempDebitNote As Db
Where Db.TempCustomerID = #TempDebitNote.TempCustomerID And
Db.TempDocumentDate < @Ninety And
Db.TempBalance > 0)
from #TempDebitNote
where #TempDebitNote.TempCustomerid like @Customer
group by #TempDebitNote.TempCustomerID  

Create Table #TempCollections (TempCustomerID nVarchar(128),TempDocumentID Int,TempDocumentDate DateTime,TempBalance Decimal(18,6))
Insert #TempCollections(TempCustomerID,TempDocumentID,TempDocumentDate,TempBalance)
Select Case When Collections.CustomerID is not null then Collections.CustomerID 
Else (Select CustomerID from Customer where AccountID=IsNull(Others,0)) End,DocumentID,DocumentDate,Balance
From Collections Where
Collections.DocumentDate Between @FromDate And @ToDate And
Collections.Balance > 0 And
IsNull(Collections.Status, 0) & 128 = 0 and
((Collections.CustomerID is not null  and Collections.CustomerID  Like @Customer)  or 
(Collections.CustomerID is null and  (Select CustomerID from Customer where AccountID=IsNull(Others,0)) is Not Null))

insert #temp(CustomerID, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
Select TempCustomerID, Count(TempDocumentID), 0 - Sum(TempBalance),
(Select 0 - IsNull(Sum(Col.TempBalance), 0) From #TempCollections As Col
Where Col.TempCustomerID = #TempCollections.TempCustomerID And
Col.TempDocumentDate Between @Seven And @One),

(Select 0 - IsNull(Sum(Col.TempBalance), 0) From #TempCollections As Col
Where Col.TempCustomerID = #TempCollections.TempCustomerID And
Col.TempDocumentDate Between @Ten And @Eight),

(Select 0 - IsNull(Sum(Col.TempBalance), 0) From #TempCollections As Col
Where Col.TempCustomerID = #TempCollections.TempCustomerID And
Col.TempDocumentDate Between @Fourteen And @Eleven),

(Select 0 - IsNull(Sum(Col.TempBalance), 0) From #TempCollections As Col
Where Col.TempCustomerID = #TempCollections.TempCustomerID And
Col.TempDocumentDate Between @TwentyOne And @Fifteen ),

(Select 0 - IsNull(Sum(Col.TempBalance), 0) From #TempCollections As Col
Where Col.TempCustomerID = #TempCollections.TempCustomerID And
Col.TempDocumentDate Between @Thirty And @TwentyTwo),

(Select 0 - IsNull(Sum(Col.TempBalance), 0) From #TempCollections As Col
Where Col.TempCustomerID = #TempCollections.TempCustomerID And
Col.TempDocumentDate > @Thirty),

(Select 0 - IsNull(Sum(Col.TempBalance), 0) From #TempCollections As Col
Where Col.TempCustomerID = #TempCollections.TempCustomerID And
Col.TempDocumentDate Between @Sixty And @ThirtyOne),

(Select 0 - IsNull(Sum(Col.TempBalance), 0) From #TempCollections As Col
Where Col.TempCustomerID = #TempCollections.TempCustomerID And
Col.TempDocumentDate Between @Ninety And @SixtyOne),

(Select 0 - IsNull(Sum(Col.TempBalance), 0) From #TempCollections As Col
Where Col.TempCustomerID = #TempCollections.TempCustomerID And
Col.TempDocumentDate < @Ninety)
From #TempCollections
Where 
#TempCollections.TempCustomerID  Like @Customer
Group By #TempCollections.TempCustomerID

select  #temp.CustomerID, "CustomerID" = #temp.CustomerID, 
"Customer" = Customer.Company_Name, "No of Docs" = sum(Notecount),  
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
group by #temp.CustomerID, Customer.Company_Name  

Drop table #TempCollections
Drop table #TempCreditNote
Drop table #TempDebitNote
drop table #temp

