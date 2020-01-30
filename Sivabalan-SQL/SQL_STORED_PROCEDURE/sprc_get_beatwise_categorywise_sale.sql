CREATE PROC [dbo].[sprc_get_beatwise_categorywise_sale]
		(
		@Categoryid int,
		@FromDate datetime,
		@ToDate datetime
		)
as
DECLARE @InvoiceId int
Declare @Others nVarchar(50)
set @Others = dbo.LookupDictionaryItem('Others',default)
	create table #tempbeat (Beatid int, BeatDescription nvarchar(100) , TotalValue decimal(18,2)) 
	insert into #tempbeat

	select ISNULL(beat.beatid,0) , ISNULL(beat.description, @others) ,  "TotalValue" = isnull(sum(invoicedetail.Amount),0)
	from invoiceabstract, invoicedetail, beat, items
	where
	invoiceabstract.invoiceid = invoicedetail.invoiceid and
	invoiceabstract.invoicetype in (1, 3) and
	invoiceabstract.invoicedate between @fromdate and @todate and
	(invoiceabstract.status & 128) = 0 and
	invoiceabstract.beatid *= beat.beatid and
	invoicedetail.product_code = items.product_code and
	items.categoryid = @categoryid
group by
	beat.beatid , beat.description
	insert into #tempbeat
	select ISNULL(beat.beatid,0) , ISNULL(beat.description, @others) ,  "TotalValue" = (0 - isnull(sum(InvoiceDetail.Amount),0))
	from invoiceabstract, invoicedetail, beat, items
	where
	invoiceabstract.invoiceid = invoicedetail.invoiceid and
	invoiceabstract.invoicetype = 4 and
	invoiceabstract.invoicedate between @fromdate and @todate and
	(invoiceabstract.status & 128) = 0 and
	invoiceabstract.beatid *= beat.beatid and
	invoicedetail.product_code = items.product_code and
	items.categoryid = @categoryid
group by
	beat.beatid , beat.description
	select  "Beatid" = #tempbeat.Beatid , 
	"BeatDescrition" = #tempbeat.BeatDescription,
	"TotalValue" = isnull(sum(#tempbeat.TotalValue),0)
	from #tempbeat 
	group by #tempbeat.Beatid, #tempbeat.BeatDescription
	drop table #tempbeat
