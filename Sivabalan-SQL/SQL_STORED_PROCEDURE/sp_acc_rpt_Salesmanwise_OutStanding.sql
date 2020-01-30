CREATE procedure sp_acc_rpt_Salesmanwise_OutStanding(@FromDate datetime,
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
(SalesmanID int not null,
Balance Decimal(18,6) not null,
CustomerID nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS not null,
OnetoSeven Decimal(18, 6) null,
EighttoTen Decimal(18, 6) null,
EleventoFourteen Decimal(18, 6) null,
FifteentoTwentyOne Decimal(18, 6) null,
TwentyTwotoThirty Decimal(18, 6) null,
LessthanThirty Decimal(18, 6) null,
ThirtyOnetoSixty Decimal(18, 6) null,
SixtyOnetoNinety Decimal(18, 6) null,
MorethanNinety Decimal(18, 6) null)




select salesmanId, sum(OnetoSeven) OnetoSeven, sum(EighttoTen) EighttoTen, 
sum(EleventoFourteen) EleventoFourteen, sum(FifteentoTwentyOne) FifteentoTwentyOne, 
sum(TwentyTwotoThirty) TwentyTwotoThirty, sum(LessthanThirty) LessthanThirty, 
sum(ThirtyOnetoSixty) ThirtyOnetoSixty, sum(SixtyOnetoNinety) SixtyOnetoNinety, 
sum(MorethanNinety) MorethanNinety 
Into #tempInvoice from 
(
    select Case when Dsost.InvoiceDocumentID Is NULL then Ia.SalesmanID Else Dsost.MappedSalesmanID End SalesmanID
    , Case When Ia.InvoiceDate Between @Seven And @One then 
            Case when Ia.Invoicetype in (1, 2, 3) then ISNULL(Ia.Balance, 0) 
                when Ia.Invoicetype in (4, 5, 6) then (0 - ISNULL(Ia.Balance, 0)) 
            End 
      Else 0   
      End 'OnetoSeven'
    , Case When Ia.InvoiceDate Between @Ten And @Seven  then 
            Case when Ia.Invoicetype in (1, 2, 3) then ISNULL(Ia.Balance, 0) 
                when Ia.Invoicetype in (4, 5, 6) then (0 - ISNULL(Ia.Balance, 0)) 
            End 
      Else 0   
      End 'EighttoTen'
    , Case When Ia.InvoiceDate Between @Fourteen And @Eleven  then 
            Case when Ia.Invoicetype in (1, 2, 3) then ISNULL(Ia.Balance, 0) 
                when Ia.Invoicetype in (4, 5, 6) then (0 - ISNULL(Ia.Balance, 0)) 
            End 
      Else 0   
      End 'EleventoFourteen' 
    , Case When Ia.InvoiceDate Between @TwentyOne And @Fifteen  then 
            Case when Ia.Invoicetype in (1, 2, 3) then ISNULL(Ia.Balance, 0) 
                when Ia.Invoicetype in (4, 5, 6) then (0 - ISNULL(Ia.Balance, 0)) 
            End 
      Else 0   
      End 'FifteentoTwentyOne' 
    , Case When Ia.InvoiceDate Between @Thirty And @TwentyTwo   then 
            Case when Ia.Invoicetype in (1, 2, 3) then ISNULL(Ia.Balance, 0) 
                when Ia.Invoicetype in (4, 5, 6) then (0 - ISNULL(Ia.Balance, 0)) 
            End 
      Else 0   
      End 'TwentyTwotoThirty' 
    , Case When Ia.InvoiceDate > @Thirty  then 
            Case when Ia.Invoicetype in (1, 2, 3) then ISNULL(Ia.Balance, 0) 
                when Ia.Invoicetype in (4, 5, 6) then (0 - ISNULL(Ia.Balance, 0)) 
            End 
      Else 0   
      End 'LessthanThirty'  
    , Case When Ia.InvoiceDate Between @Sixty And @ThirtyOne then 
            Case when Ia.Invoicetype in (1, 2, 3) then ISNULL(Ia.Balance, 0) 
                when Ia.Invoicetype in (4, 5, 6) then (0 - ISNULL(Ia.Balance, 0)) 
            End 
      Else 0   
      End 'ThirtyOnetoSixty' 
    , Case When Ia.InvoiceDate Between @Ninety And @SixtyOne then 
        Case when Ia.Invoicetype in (1, 2, 3) then ISNULL(Ia.Balance, 0) 
            when Ia.Invoicetype in (4, 5, 6) then (0 - ISNULL(Ia.Balance, 0)) 
        End 
      Else 0   
      End 'SixtyOnetoNinety' 
    , Case When Ia.InvoiceDate < @Ninety then
        Case when Ia.Invoicetype in (1, 2, 3) then ISNULL(Ia.Balance, 0) 
            when Ia.Invoicetype in (4, 5, 6) then (0 - ISNULL(Ia.Balance, 0)) 
        End 
      Else 0   
      End 'MorethanNinety' 
    from InvoiceAbstract Ia Left Outer Join tbl_mERP_DSOSTransfer Dsost on Ia.DocumentID = Dsost.InvoiceDocumentID 
    where Ia.Status & 128 = 0 and Ia.Balance > 0 and Ia.InvoiceType in (1, 2, 3, 4, 5, 6) 
) tmpInvoiceBal 
Group by SalesmanID
--select * from #tempInvoice
select salesmanId, sum(balance) balance 
Into #tempInvoiceNetBalance from 
(
    select Case when Dsost.InvoiceDocumentID Is NULL then Ia.SalesmanID Else Dsost.MappedSalesmanID End SalesmanID
    , Case when Ia.Invoicetype in (1, 2, 3) then ISNULL(Ia.Balance, 0) 
            when Ia.Invoicetype in (4, 5, 6) then (0 - ISNULL(Ia.Balance, 0)) 
      End Balance 
    from InvoiceAbstract Ia Left Outer Join tbl_mERP_DSOSTransfer Dsost on Ia.DocumentID = Dsost.InvoiceDocumentID
    where Ia.Status & 128 = 0 and Ia.Balance > 0 and Ia.InvoiceType in (1, 2, 3, 4, 5, 6) 
        and Ia.InvoiceDate between @FromDate and @ToDate 
) tmpInvoiceNetBal 
group by salesmanId
--select * from #tempInvoiceNetBalance

insert into #temp (SalesmanID, Balance, CustomerID, OnetoSeven, EighttoTen, 
EleventoFourteen, FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
select tmp.SalesmanID, tmpNetBal.Balance, '' CustomerID
    , OnetoSeven
    , EighttoTen
    , EleventoFourteen
    , FifteentoTwentyOne
    , TwentyTwotoThirty
    , LessthanThirty
    , ThirtyOnetoSixty
    , SixtyOnetoNinety
    , MorethanNinety
from #tempInvoice tmp
Join #tempInvoiceNetBalance tmpNetBal on tmp.SalesmanID = tmpNetBal.SalesmanID
--select * from #temp
 

insert into #temp (SalesmanID, Balance, CustomerID, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
SELECT ISNULL(SalesmanID, 0), 0 - sum(ISNULL(Balance, 0)), CustomerID,
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Seven And @One And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And Collections.CustomerID is Not Null and
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Ten And @Eight And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And Collections.CustomerID is Not Null and
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Fourteen And @Eleven And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And Collections.CustomerID is Not Null and
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @TwentyOne And @Fifteen And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And Collections.CustomerID is Not Null and
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Thirty And @TwentyTwo And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And Collections.CustomerID is Not Null and
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate > @Thirty And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And Collections.CustomerID is Not Null and
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Sixty And @ThirtyOne And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And Collections.CustomerID is Not Null and
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate Between @Ninety And @SixtyOne And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And Collections.CustomerID is Not Null and
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID),
(Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col
Where Col.DocumentDate < @Ninety And
IsNull(Col.Status, 0) & 128 = 0 And
Col.Balance > 0 And Collections.CustomerID is Not Null and
Col.SalesmanID = Collections.SalesmanID And
Col.CustomerID = Collections.CustomerID)
From Collections
WHERE ISNULL(Balance, 0) > 0 AND 
DocumentDate Between @FromDate AND @ToDate And
IsNull(Collections.Status, 0) & 128 = 0 
And Collections.CustomerID is Not Null 
group by Collections.SalesmanID, Collections.CustomerID

insert into #temp (SalesmanID, Balance, CustomerID, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
SELECT  ISNULL(SalesmanID, 0), 0 - sum(ISNULL(Balance, 0)), CustomerID,
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Seven And @One And
Cr.Balance > 0 And
IsNull(Cr.Status, 0) & 192 = 0 and
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Ten And @Eight And
Cr.Balance > 0 And
IsNull(Cr.Status, 0) & 192 = 0 and
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Fourteen And @Eleven And
Cr.Balance > 0 And
IsNull(Cr.Status, 0) & 192 = 0 and
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @TwentyOne And @Fifteen And
Cr.Balance > 0 And
IsNull(Cr.Status, 0) & 192 = 0 and
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Thirty And @TwentyTwo And
Cr.Balance > 0 And
IsNull(Cr.Status, 0) & 192 = 0 and
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate > @Thirty And
Cr.Balance > 0 And
IsNull(Cr.Status, 0) & 192 = 0 and
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Sixty And @ThirtyOne And
Cr.Balance > 0 And
IsNull(Cr.Status, 0) & 192 = 0 and
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate Between @Ninety And @SixtyOne And
Cr.Balance > 0 And
IsNull(Cr.Status, 0) & 192 = 0 and
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID),
(Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr
Where Cr.DocumentDate < @Ninety And
Cr.Balance > 0 And
IsNull(Cr.Status, 0) & 192 = 0 and
Cr.CustomerID = CreditNote.CustomerID And
Cr.SalesmanID = CreditNote.SalesmanID)
From CreditNote
WHERE   ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND
	CustomerID IS NOT NULL 
    And IsNull(CreditNote.Status, 0) & 192 = 0 
group by CreditNote.SalesmanID, CreditNote.CustomerID

insert into #temp (SalesmanID, Balance, CustomerID, OnetoSeven, EighttoTen, EleventoFourteen,
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty, 
SixtyOnetoNinety, MorethanNinety)
SELECT ISNULL(SalesmanID, 0), sum(ISNULL(Balance, 0)), CustomerID,
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Seven And @One And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID
And IsNull(Db.Status, 0) & 192 = 0  ),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Ten And @Eight And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID
And IsNull(Db.Status, 0) & 192 = 0  ),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Fourteen And @Eleven And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID 
And IsNull(Db.Status, 0) & 192 = 0  ),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @TwentyOne And @Fifteen And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID 
And IsNull(Db.Status, 0) & 192 = 0  ),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Thirty And @TwentyTwo And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID 
And IsNull(Db.Status, 0) & 192 = 0  ),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate > @Thirty And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID 
And IsNull(Db.Status, 0) & 192 = 0  ),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Sixty And @ThirtyOne And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID 
And IsNull(Db.Status, 0) & 192 = 0  ),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate Between @Ninety And @SixtyOne And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID
And IsNull(Db.Status, 0) & 192 = 0  ),
(Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db
Where Db.DocumentDate < @Ninety And
Db.balance > 0 And
Db.SalesmanID = DebitNote.SalesmanID And
Db.CustomerID = DebitNote.CustomerID 
And IsNull(Db.Status, 0) & 192 = 0  )
From DebitNote
WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND
IsNull(DebitNote.Status, 0) & 192 = 0  And 
CustomerID IS NOT NULL
group by DebitNote.SalesmanID, DebitNote.CustomerID

select #temp.SalesmanID, "Salesman" = IsNull(Salesman.Salesman_Name, dbo.LookupDictionaryItem('Others',Default)), 
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
from #temp
Left Outer Join Salesman On #temp.SalesmanID = Salesman.SalesmanID
Group By #temp.SalesmanID, Salesman.Salesman_Name

drop table #temp
