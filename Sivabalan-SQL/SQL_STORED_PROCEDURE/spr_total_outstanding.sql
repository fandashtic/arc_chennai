CREATE procedure spr_total_outstanding(@fromdate datetime,@todate datetime)
as
declare @invoice Decimal(18,6)
declare @credit Decimal(18,6)
declare @debit Decimal(18,6)
declare @total Decimal(18,6)
Declare @Advance Decimal(18,6)
Declare @OnetoSeven Decimal(18,6)
Declare @EighttoTen Decimal(18,6)
Declare @EleventoFourteen Decimal(18,6)
Declare @FifteentoTwentyOne Decimal(18,6)
Declare @TwentyTwotoThirty Decimal(18,6)
Declare @LessthanThirty Decimal(18,6)
Declare @ThirtyOnetoSixty Decimal(18,6)
Declare @SixtyOnetoNinety Decimal(18,6)
Declare @MorethanNinety Decimal(18,6)

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

Set @One = Cast(Datepart(dd, GetDate()) As nvarchar) + N'/' +
Cast(Datepart(mm, GetDate()) As nvarchar) + N'/' +
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

select @invoice = sum(case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where 
	InvoiceAbstract.InvoiceDate between @FromDate and @ToDate  and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0
select @credit = isnull(sum(CreditNote.Balance),0) from CreditNote 
where creditnote.CustomerID is not null and
	creditnote.DocumentDate between @FromDate and @ToDate 
select @debit = isnull(sum(DebitNote.Balance),0) from DebitNote
where debitnote.CustomerID is not null and
	debitnote.DocumentDate between @FromDate and @ToDate 
Select @Advance = IsNull(Sum(Balance), 0) From Collections 
Where IsNull(Balance, 0) > 0 And (IsNull(Status, 0) & 64) = 0 And
DocumentDate Between @FromDate And @ToDate

select @total = IsNull(@invoice, 0) + IsNull(@debit, 0) - IsNull(@credit, 0) - IsNull(@Advance, 0)

Select @OnetoSeven = IsNull((select sum(case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where 	InvoiceAbstract.InvoiceDate between @Seven and @One and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0), 0) + 
Isnull((select isnull(sum(DebitNote.Balance),0) from DebitNote
where debitnote.CustomerID is not null and
	debitnote.DocumentDate between @Seven and @One and
	debitNote.customerid <> N''), 0) -
IsNull((select isnull(sum(CreditNote.Balance),0) from CreditNote 
where creditnote.CustomerID is not null and
	creditnote.DocumentDate between @Seven and @One and
	CreditNote.CustomerID <> N''), 0) - 
IsNull((Select IsNull(Sum(Balance), 0) From Collections 
Where IsNull(Balance, 0) > 0 And (IsNull(Status, 0) & 64) = 0 And
DocumentDate between @Seven and @One), 0)

Select @EighttoTen = IsNull((select sum(case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where 	InvoiceAbstract.InvoiceDate between @Ten and @Eight and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0), 0) + 
Isnull((select isnull(sum(DebitNote.Balance),0) from DebitNote
where debitnote.CustomerID is not null and
	debitnote.DocumentDate between @Ten and @Eight and
	debitNote.customerid <> N''), 0) -
IsNull((select isnull(sum(CreditNote.Balance),0) from CreditNote 
where creditnote.CustomerID is not null and
	creditnote.DocumentDate between @Ten and @Eight and
	CreditNote.CustomerID <> N''), 0) - 
IsNull((Select IsNull(Sum(Balance), 0) From Collections 
Where IsNull(Balance, 0) > 0 And (IsNull(Status, 0) & 64) = 0 And
DocumentDate between @Ten and @Eight), 0)

Select @EleventoFourteen = IsNull((select sum(case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where 	InvoiceAbstract.InvoiceDate between @Fourteen and @Eleven and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0), 0) + 
Isnull((select isnull(sum(DebitNote.Balance),0) from DebitNote
where debitnote.CustomerID is not null and
	debitnote.DocumentDate between @Fourteen and @Eleven and
	debitNote.customerid <> N''), 0) -
IsNull((select isnull(sum(CreditNote.Balance),0) from CreditNote 
where creditnote.CustomerID is not null and
	creditnote.DocumentDate between @Fourteen and @Eleven and
	CreditNote.CustomerID <> N''), 0) - 
IsNull((Select IsNull(Sum(Balance), 0) From Collections 
Where IsNull(Balance, 0) > 0 And (IsNull(Status, 0) & 64) = 0 And
DocumentDate between @Fourteen and @Eleven), 0)

Select @FifteentoTwentyOne = IsNull((select sum(case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where 	InvoiceAbstract.InvoiceDate between @TwentyOne and @Fifteen and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0), 0) + 
Isnull((select isnull(sum(DebitNote.Balance),0) from DebitNote
where debitnote.CustomerID is not null and
	debitnote.DocumentDate between @TwentyOne and @Fifteen and
	debitNote.customerid <> N''), 0) -
IsNull((select isnull(sum(CreditNote.Balance),0) from CreditNote 
where creditnote.CustomerID is not null and
	creditnote.DocumentDate between @TwentyOne and @Fifteen and
	CreditNote.CustomerID <> N''), 0) - 
IsNull((Select IsNull(Sum(Balance), 0) From Collections 
Where IsNull(Balance, 0) > 0 And (IsNull(Status, 0) & 64) = 0 And
DocumentDate between @TwentyOne and @Fifteen), 0)

Select @TwentyTwotoThirty = IsNull((select sum(case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where 	InvoiceAbstract.InvoiceDate between @Thirty and @TwentyTwo and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0), 0) + 
Isnull((select isnull(sum(DebitNote.Balance),0) from DebitNote
where debitnote.CustomerID is not null and
	debitnote.DocumentDate between @Thirty and @TwentyTwo and
	debitNote.customerid <> N''), 0) -
IsNull((select isnull(sum(CreditNote.Balance),0) from CreditNote 
where creditnote.CustomerID is not null and
	creditnote.DocumentDate between @Thirty and @TwentyTwo and
	CreditNote.CustomerID <> N''), 0) - 
IsNull((Select IsNull(Sum(Balance), 0) From Collections 
Where IsNull(Balance, 0) > 0 And (IsNull(Status, 0) & 64) = 0 And
DocumentDate between @Thirty and @TwentyTwo), 0)

Select @LessthanThirty = IsNull((select sum(case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where 	InvoiceAbstract.InvoiceDate > @Thirty and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0), 0) + 
Isnull((select isnull(sum(DebitNote.Balance),0) from DebitNote
where debitnote.CustomerID is not null and
	debitnote.DocumentDate > @Thirty and
	debitNote.customerid <> N''), 0) -
IsNull((select isnull(sum(CreditNote.Balance),0) from CreditNote 
where creditnote.CustomerID is not null and
	creditnote.DocumentDate > @Thirty and
	CreditNote.CustomerID <> N''), 0) - 
IsNull((Select IsNull(Sum(Balance), 0) From Collections 
Where IsNull(Balance, 0) > 0 And (IsNull(Status, 0) & 64) = 0 And
DocumentDate < @Thirty), 0)

Select @ThirtyOnetoSixty = IsNull((select sum(case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where 	InvoiceAbstract.InvoiceDate between @Sixty And @ThirtyOne and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0), 0) + 
Isnull((select isnull(sum(DebitNote.Balance),0) from DebitNote
where debitnote.CustomerID is not null and
	debitnote.DocumentDate between @Sixty And @ThirtyOne and
	debitNote.customerid <> N''), 0) -
IsNull((select isnull(sum(CreditNote.Balance),0) from CreditNote 
where creditnote.CustomerID is not null and
	creditnote.DocumentDate between @Sixty And @ThirtyOne and
	CreditNote.CustomerID <> N''), 0) - 
IsNull((Select IsNull(Sum(Balance), 0) From Collections 
Where IsNull(Balance, 0) > 0 And (IsNull(Status, 0) & 64) = 0 And
DocumentDate between @Sixty And @ThirtyOne), 0)

Select @SixtyOnetoNinety = IsNull((select sum(case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where 	InvoiceAbstract.InvoiceDate between @Ninety And @SixtyOne and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0), 0) + 
Isnull((select isnull(sum(DebitNote.Balance),0) from DebitNote
where debitnote.CustomerID is not null and
	debitnote.DocumentDate between @Ninety And @SixtyOne and
	debitNote.customerid <> N''), 0) -
IsNull((select isnull(sum(CreditNote.Balance),0) from CreditNote 
where creditnote.CustomerID is not null and
	creditnote.DocumentDate between @Ninety And @SixtyOne and
	CreditNote.CustomerID <> N''), 0) - 
IsNull((Select IsNull(Sum(Balance), 0) From Collections 
Where IsNull(Balance, 0) > 0 And (IsNull(Status, 0) & 64) = 0 And
DocumentDate between @Ninety And @SixtyOne), 0)

Select @MorethanNinety = IsNull((select sum(case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where 	InvoiceAbstract.InvoiceDate < @Ninety and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0), 0) + 
Isnull((select isnull(sum(DebitNote.Balance),0) from DebitNote
where debitnote.CustomerID is not null and
	debitnote.DocumentDate < @Ninety and
	debitNote.customerid <> N''), 0) -
IsNull((select isnull(sum(CreditNote.Balance),0) from CreditNote 
where creditnote.CustomerID is not null and
	creditnote.DocumentDate < @Ninety and
	CreditNote.CustomerID <> N''), 0) - 
IsNull((Select IsNull(Sum(Balance), 0) From Collections 
Where IsNull(Balance, 0) > 0 And (IsNull(Status, 0) & 64) = 0 And
DocumentDate < @Ninety), 0)

select 0, "Total OutStanding (%c)" = @total, "1-7 Days" = @OnetoSeven,
"8-10 Days" = @EighttoTen, "11-14 Days" = @EleventoFourteen,
"15-21 Days" = @FifteentoTwentyOne, "22-30 Days" = @TwentyTwotoThirty,
"<30 Days" = @LessthanThirty, 
"31-60 Days" = @ThirtyOnetoSixty,
"61-90 Days" = @SixtyOnetoNinety,
">90 Days" = @MorethanNinety
