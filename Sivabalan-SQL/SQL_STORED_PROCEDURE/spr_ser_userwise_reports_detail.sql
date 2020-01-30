CREATE procedure [dbo].[spr_ser_userwise_reports_detail](@username nvarchar(50),   
      @fromDate datetime,   
      @toDate datetime)    
as    

CREATE Table #UserInvoiceTemp( InvoiceID bigint,DocumentID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
InvoiceType varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Date] datetime,[CustomerName] nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Sales NetValue] decimal(18,6),[Service NetValue] decimal(18,6))

Insert into #UserInvoiceTemp
 
	select  InvoiceID,   
	"DocumentID" = VoucherPrefix.Prefix + cast (InvoiceAbstract.DocumentID as varchar),  
	"InvoiceType" = case InvoiceType  
	when 1 then  
	'Invoice'  
	when 2 then  
	'Retail Invoice'  
	when 3 then  
	'Invoice Amendment'  
	when 4 then  
	'Sales Return'   
	when 5 then  
	'Retail SalesReturn Salable'   
	when 6 then  
	'Retail SalesReturn Damage'   
	else
	''
	end,   
	"Date" = InvoiceDate,  
	"Customer Name" = ISNULL(Customer.Company_Name, 'No Customer'),  
	"NetValue" = case    
	WHEN InvoiceType>=4 and InvoiceType<=6 Then   
	0 - (NetValue-isnull(Freight,0))   
	Else      
	NetValue-isnull(Freight,0)   
	END,
        "ServiceNetValue" = 0
	FROM InvoiceAbstract, VoucherPrefix, Customer 
	WHERE (InvoiceAbstract.Status & 128) = 0 and   
	Username = @username and   
	InvoiceAbstract.CustomerID *= Customer.CustomerID And  
	invoiceabstract.creationtime Between @FromDate And @ToDate and   
	VoucherPrefix.tranid = 'INVOICE'   

Insert into #UserInvoiceTemp

select serviceinvoiceabstract.ServiceInvoiceID,
"DocumentID" = VoucherPrefix.Prefix + cast (serviceInvoiceAbstract.DocumentID as varchar),  
"InvoiceType" = case ServiceInvoiceType  
when 1 then  
'Service Invoice'  
else
''
end,   
"Date" = serviceInvoiceDate,  
"Customer Name" = ISNULL(Customer.Company_Name, 'No Customer'),  
--"Total Sales Amount" =  sum(isnull(serviceinvoicedetail.netvalue,0)),
"Total Sales Amount" = (select sum(isnull(serviceinvoicedetail.netvalue,0)) 
from serviceinvoiceabstract sa,serviceinvoicedetail,items 
where sa.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  and
sa.creationtime Between @FromDate And @ToDate
AND (sa.serviceInvoiceType = 1)                       
AND Isnull(sa.Status,0) & 192 = 0    
AND serviceInvoiceDetail.product_code = items.product_code  
AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  
and sa.Username = @username 
and sa.serviceInvoiceID = serviceInvoiceAbstract.serviceInvoiceID
group by sa.serviceinvoiceid),

"Net Service Value" = (select sum(isnull(serviceinvoicedetail.netvalue,0)) 
from serviceinvoiceabstract sa,serviceinvoicedetail,items 
where sa.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  and
sa.creationtime Between @FromDate And @ToDate
AND (sa.serviceInvoiceType = 1)                       
AND Isnull(sa.Status,0) & 192 = 0    
AND serviceInvoiceDetail.product_code = items.product_code  
AND IsNull(ServiceinvoiceDetail.SpareCode, '') = ''  
And isnull(Serviceinvoicedetail.Taskid,'') <> ''  
and sa.Username = @username 
and sa.serviceInvoiceID = serviceInvoiceAbstract.serviceInvoiceID
group by sa.serviceinvoiceid) 

from serviceinvoiceabstract,serviceinvoicedetail,items,VoucherPrefix,customer 
where serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  and
serviceInvoiceAbstract.creationtime Between @FromDate And @ToDate    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0    
--AND serviceInvoiceDetail.sparecode = items.product_code  
--AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  
--And Type in(2,3)
And serviceinvoiceabstract.Username = @username
and ServiceInvoiceAbstract.CustomerID *= Customer.CustomerID And  
VoucherPrefix.tranid = 'SERVICEINVOICE'   
group by VoucherPrefix.Prefix,serviceinvoiceabstract.DocumentId,serviceinvoiceabstract.ServiceInvoiceType,
serviceinvoiceabstract.ServiceInvoiceDate,
customer.Company_Name,
serviceinvoiceabstract.serviceinvoiceid  	

select * from #UserInvoiceTemp order by [date]
drop table #UserInvoiceTemp
