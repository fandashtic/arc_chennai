
-------------------------------------------------------------------------------------------------------------------------------------------------------------- 
CREATE PROC sprc_get_customer_from_beat
		(
		@Categoryid int,
		@Beatid int,
		@FromDate datetime,
		@ToDate datetime
		)
as
	create table #tempbeat (Customerid nvarchar(15), CompanyName nvarchar(255) , TotalValue decimal(18,2)) 
	insert into #tempbeat

	select customer.customerid , customer.company_name, "TotalValue" = isnull(sum(invoicedetail.Amount),0)	
	
	from invoiceabstract, invoicedetail, Customer, items
	where
	invoiceabstract.invoiceid = invoicedetail.invoiceid and
	invoiceabstract.invoicetype in (1, 3) and
	invoiceabstract.invoicedate between @fromdate and @todate and
	(invoiceabstract.status & 128) = 0 and
	invoiceabstract.beatid = @beatid and
	invoicedetail.product_code = items.product_code and	
	items.categoryid = @categoryid and
	invoiceabstract.Customerid = Customer.Customerid
group by
	Customer.Customerid, Customer.Company_Name

	insert into #tempbeat

	select customer.customerid , customer.company_name, "TotalValue" = (0 - isnull(sum(InvoiceDetail.Amount),0))
	from invoiceabstract, invoicedetail, Customer, items
	where
	invoiceabstract.invoiceid = invoicedetail.invoiceid and
	invoiceabstract.invoicetype = 4 and
	invoiceabstract.invoicedate between @fromdate and @todate and
	(invoiceabstract.status & 128) = 0 and
	invoiceabstract.beatid = @beatid and
	invoicedetail.product_code = items.product_code and	
	items.categoryid = @categoryid and
	invoiceabstract.Customerid = Customer.Customerid
group by
	Customer.Customerid, Customer.Company_Name

	select  "Beatid" = #tempbeat.Customerid , 
	"BeatDescrition" = #tempbeat.CompanyName,
	"TotalValue" = isnull(sum(#tempbeat.TotalValue),0)
	from #tempbeat 
	group by #tempbeat.Customerid, #tempbeat.companyname
	drop table #tempbeat



