
CREATE proc spr_get_customer_from_beat
		(
		@Categoryid int,
		@Beatid int,
		@FromDate datetime,
		@ToDate datetime
		)
as
	select customer.customerid , customer.company_name, sum(invoicedetail.amount)   
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




