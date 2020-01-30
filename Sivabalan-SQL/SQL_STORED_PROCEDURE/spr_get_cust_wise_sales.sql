
CREATE proc spr_get_cust_wise_sales (@Fromdate datetime, @Todate datetime)
as 
SELECT InvoiceAbstract.CustomerID, "CustomerID" = InvoiceAbstract.CustomerID, "Customer Name" = Customer.Company_Name, 
"Net Value (%c)" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END)
from invoiceabstract, invoicedetail, customer
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and 
	(InvoiceAbstract.Status & 128) = 0 And 
	InvoiceAbstract.InvoiceDate Between @Fromdate and @Todate And 
	InvoiceAbstract.CustomerID = Customer.CustomerID And
	InvoiceAbstract.InvoiceType in (1,3,4)
Group By InvoiceAbstract.CustomerID, Customer.Company_Name

