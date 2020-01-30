Create procedure spr_totalwise_outstanding_allCustomers(@Dummy int,@FromDate datetime,@ToDate datetime)
as

create table #temp (customerid nvarchar(15), doccount int null, value decimal(18,2)null)

insert #temp(customerid, doccount, value)  	
select "Customer Id" = InvoiceAbstract.CustomerID,
	"No of Documents" = count(InvoiceID), 
	"Outstanding Value (Rs.)" = sum( case InvoiceAbstract.InvoiceType 
	when 4 then (0 - isnull(InvoiceAbstract.Balance, 0)) 
	else isnull(InvoiceAbstract.Balance, 0) end)
from InvoiceAbstract
where InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and
	InvoiceAbstract.Balance > 0 and 
	InvoiceAbstract.InvoiceType in (1, 3, 4) and
	InvoiceAbstract.Status & 128 = 0
group by InvoiceAbstract.CustomerID

insert #temp(customerid, doccount, value)  	
select "Customer ID" = creditnote.CustomerID, 
	"No of Documents" = count(CreditID), 
	"Outstanding Value" = 0 - sum(creditnote.Balance)
from creditnote
where creditnote.CustomerID is not null and
creditnote.Balance > 0  and
creditnote.DocumentDate between @FromDate and @ToDate 
group by creditnote.CustomerID  

insert #temp(customerid, doccount, value)  	
select "Customer ID" = debitnote.CustomerID, 
	"No of Documents" = count(DebitID), 
	"Outstanding Value" = sum(Debitnote.Balance)
from debitnote
where debitnote.CustomerID is not null and
debitnote.Balance > 0  and
debitnote.DocumentDate between @FromDate and @ToDate 
group by debitnote.CustomerID  

select #temp.customerid, 
	"CustomerID" = #temp.customerid, 
	"Customer" =  Customer.Company_Name,
	"No. Of Documents" = sum(doccount), 
	"OutStanding Value (Rs)" = sum(value)
from #temp, Customer
where #temp.customerid = Customer.CustomerID
group By #temp.customerid,Customer.Company_Name
drop table #temp