Create procedure spr_totalwise_outstanding(@fromdate datetime,@todate datetime)
as
declare @invoice float
declare @credit float
declare @debit float
declare @total float
select @invoice = sum(case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where 
	InvoiceAbstract.InvoiceDate between @FromDate and @ToDate  and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0
select @credit = sum(CreditNote.Balance) from CreditNote 
where creditnote.CustomerID is not null and
	creditnote.DocumentDate between @FromDate and @ToDate 
select @debit = sum(DebitNote.Balance) from DebitNote
where debitnote.CustomerID is not null and
	debitnote.DocumentDate between @FromDate and @ToDate 
select @total = @invoice + @debit - @credit
select  @total