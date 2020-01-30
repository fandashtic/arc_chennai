CREATE PROCEDURE spr_ser_list_cash_credit_customers(@CREDITID int,
						@FROMDATE datetime,
						@TODATE datetime)
AS

Create Table #CredittempDetail   
(Customer nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID  nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName varchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalesNetValue Decimal(18,6),ServiceNetValue Decimal(18,6),TotalNetValue Decimal(18,6))

Insert into #CredittempDetail   

SELECT 	InvoiceAbstract.CustomerID, "Customer ID"=InvoiceAbstract.CustomerID, 
	"Customer Name"=Customer.Company_Name, 
	"SalesNetValue (%c)"=Sum(NetValue),
        "ServiceNetValue (%c)" = 0,
        "TotalNetValue (%c)" = Sum(NetValue) 
FROM 	InvoiceAbstract, Customer
WHERE 	InvoiceAbstract.CreditTerm = @CREDITID AND
	InvoiceAbstract.InvoiceType in (1, 3) AND
	(InvoiceAbstract.Status & 128) = 0 AND
	InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
	InvoiceAbstract.CustomerID = Customer.CustomerID
GROUP BY InvoiceAbstract.CustomerID, Customer.Company_Name

Insert into #CredittempDetail   

SELECT 	ServiceInvoiceAbstract.CustomerID, "Customer ID"=ServiceInvoiceAbstract.CustomerID, 
	"Customer Name"=Customer.Company_Name,
/*        "SalesNetvalue (%c)"= 0,
        "ServiceNetValue (%c)" = Sum(isnull(NetValue,0)),*/

"Sales NetValue" =  (select sum(isnull(serviceinvoicedetail.netvalue,0))
from serviceinvoiceabstract sa,serviceinvoicedetail,items,customer 
where sa.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  and
sa.CreditTerm = @CREDITID and
sa.CustomerID = Customer.CustomerID and
sa.serviceinvoicedate Between @Fromdate and @Todate
AND (sa.serviceInvoiceType = 1)                       
AND Isnull(sa.Status,0) & 192 = 0    
AND serviceInvoiceDetail.product_code = items.product_code  
AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  
and sa.serviceInvoiceID = serviceInvoiceAbstract.serviceInvoiceID
group by sa.serviceinvoiceid),


"Service NetValue" = (select sum(isnull(serviceinvoicedetail.netvalue,0))
from serviceinvoiceabstract sa,serviceinvoicedetail,items,customer 
where sa.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  and
Sa.CreditTerm = @CREDITID 
And sa.CustomerID = Customer.CustomerID and
sa.serviceinvoicedate Between @Fromdate and @Todate
AND (sa.serviceInvoiceType = 1)                       
AND Isnull(sa.Status,0) & 192 = 0    
AND serviceInvoiceDetail.product_code = items.product_code  
AND IsNull(ServiceinvoiceDetail.SpareCode, '') = ''  
and isnull(Serviceinvoicedetail.Taskid,'') <> ''  
and sa.serviceInvoiceID = serviceInvoiceAbstract.serviceInvoiceID
group by sa.serviceinvoiceid),

"ServiceNetValue" =   isnull(serviceinvoiceabstract.netvalue,0)

from serviceinvoiceabstract,serviceinvoicedetail,items,VoucherPrefix,customer
where serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  and
ServiceInvoiceAbstract.CreditTerm = @CREDITID 
And ServiceInvoiceAbstract.CustomerID = Customer.CustomerID
And serviceInvoiceAbstract.serviceinvoicedate Between @FromDate And @ToDate    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0    
--AND serviceInvoiceDetail.sparecode = items.product_code  
--AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  and
and VoucherPrefix.tranid = 'SERVICEINVOICE'   
group by VoucherPrefix.Prefix,serviceinvoiceabstract.DocumentId,serviceinvoiceabstract.DocReference,
serviceinvoiceabstract.ServiceInvoiceType,
ServiceInvoiceAbstract.CustomerID, Customer.Company_Name,
serviceinvoiceabstract.serviceinvoiceid,serviceinvoiceabstract.netvalue  	

SELECT
CustomerID,
"Customer ID" = CustomerID,
"Customer Name" = CustomerName,
"Gross Value_Sales (%c)" = Sum(SalesNetValue),    
"Gross Value_Service (%c)" = Sum(ServiceNetValue),    
"Total Gross Value (%c)" = Sum(TotalNetValue)        
From #CredittempDetail GROUP BY CustomerID,CustomerName
Drop Table #credittempDetail


