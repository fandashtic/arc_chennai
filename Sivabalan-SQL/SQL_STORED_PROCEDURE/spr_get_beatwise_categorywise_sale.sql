
CREATE proc spr_get_beatwise_categorywise_sale
		(
		@Categoryid int,
		@FromDate datetime,
		@ToDate datetime
		)
as
	select beat.beatid , beat.description , sum(invoicedetail.amount)   
	from invoiceabstract, invoicedetail, beat, items
	where
	invoiceabstract.invoiceid = invoicedetail.invoiceid and
	invoiceabstract.invoicetype in (1, 3) and
	invoiceabstract.invoicedate between @fromdate and @todate and
	(invoiceabstract.status & 128) = 0 and
	invoiceabstract.beatid = beat.beatid and
	invoicedetail.product_code = items.product_code and
	items.categoryid = @categoryid
group by
	beat.beatid , beat.description




