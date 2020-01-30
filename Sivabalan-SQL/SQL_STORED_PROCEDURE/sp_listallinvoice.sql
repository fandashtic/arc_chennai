
CREATE proc sp_listallinvoice(@fromdate datetime,@todate datetime, @CUSTOMER nvarchar(15) = '%')
as
select CustomerID, InvoiceID, InvoiceDate, NetValue, DocumentID, InvoiceType
from invoiceabstract 
where   invoicedate between @fromdate and @todate and invoicetype <> 4
	and invoicetype <> 2 and CustomerID like @CUSTOMER and
	Status & 128 = 0
order by customerid
select DocumentID from DocumentNumbers WHERE DocType = 4

