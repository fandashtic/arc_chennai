
CREATE proc sp_listselectedinvoice(@customerid nvarchar(15), 
	@fromdate datetime, @todate datetime)
as
select CustomerID, InvoiceID, InvoiceDate, NetValue 
	from invoiceabstract where customerid = @customerid and invoicedate between @fromdate and @todate
	order by customerid
select max(invoiceid)+1 from invoiceabstract


