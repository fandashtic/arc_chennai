CREATE PROCEDURE spr_ser_total_sales_detail(@Dummy int, @FROMDATE datetime, @TODATE datetime)
as
Create Table #TotalSalesInvoiceTemp(InvID bigint,
InvoiceID nvarchar(25)  COLLATE SQL_Latin1_General_CP1_CI_AS,
DocReference nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS, 
Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Sales NetValue] decimal(18,6),
[Service NetValue] decimal(18,6),
[Total NetValue] decimal(18,6),
[Total NetValue+Freight] decimal(18,6),
Balance Decimal(18,6),
[Roundoff NetValue] decimal(18,6))


Insert into #TotalSalesInvoiceTemp

SELECT 	InvoiceAbstract.InvoiceID, "InvoiceID" = VoucherPrefix.Prefix + CAST(DocumentID AS varchar),
	"Doc Reference"=DocReference,
	"Type" = case InvoiceType
	WHEN 4 THEN 
	Case Status & 32 
	WHEN 0 THEN
	'Sales Return Saleable'
	Else
	'Sales Return Damages'
	End
	WHEN 2 THEN 'Retail Invoice'
	WHEN 5 THEN 'Retail Sales Return Saleable'
	WHEN 6 THEN 'Retail Sales Return Damage'
	ELSE 'Invoice'
	END,
	"SalesNet Value (%c)" = case InvoiceType 
	WHEN 4 THEN 
	0 - (InvoiceAbstract.NetValue - IsNull(Freight,0))
	WHEN 5 THEN 
	0 - (InvoiceAbstract.NetValue - IsNull(Freight,0))
	WHEN 6 THEN 
	0 - (InvoiceAbstract.NetValue - IsNull(Freight,0))
	ELSE
	InvoiceAbstract.NetValue - IsNull(Freight,0)
	END,
        "ServiceNetValue" = 0,

        "TotalNetValue" = case InvoiceType 
	WHEN 4 THEN 
	0 - (InvoiceAbstract.NetValue - IsNull(Freight,0))
	WHEN 5 THEN 
	0 - (InvoiceAbstract.NetValue - IsNull(Freight,0))
	WHEN 6 THEN 
	0 - (InvoiceAbstract.NetValue - IsNull(Freight,0))
	ELSE
	InvoiceAbstract.NetValue - IsNull(Freight,0)
	END,

	"Net Value+Freight (%c)" = case InvoiceType 
	WHEN 4 THEN 
	0 - InvoiceAbstract.NetValue
	WHEN 5 THEN 
	0 - InvoiceAbstract.NetValue
	WHEN 6 THEN 
	0 - InvoiceAbstract.NetValue
	ELSE 
	InvoiceAbstract.NetValue
	END,
	"Balance (%c)" = case InvoiceType 
	WHEN 4 THEN	
	0 - IsNull(InvoiceAbstract.Balance,0)
	WHEN 5 THEN	
	0 - IsNull(InvoiceAbstract.Balance,0)
	WHEN 6 THEN	
	0 - IsNull(InvoiceAbstract.Balance,0)
	ELSE
	IsNull(InvoiceAbstract.Balance,0)
	END,
	"Roundoff Net Value" = case InvoiceType 
	WHEN 4 THEN
	0 - (InvoiceAbstract.NetValue + RoundOffAmount)
	WHEN 5 THEN
	0 - (InvoiceAbstract.NetValue + RoundOffAmount)
	WHEN 6 THEN
	0 - (InvoiceAbstract.NetValue + RoundOffAmount)
	ELSE
	InvoiceAbstract.NetValue + RoundOffAmount
	END
FROM 	InvoiceAbstract, VoucherPrefix
WHERE 	(InvoiceAbstract.Status & 128) = 0 AND
	InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND 
	VoucherPrefix.TranID = 'INVOICE'
Order By InvoiceAbstract.InvoiceType, InvoiceAbstract.DocumentID


Insert into #TotalSalesInvoiceTemp

select serviceinvoiceabstract.ServiceInvoiceID,
"InvoiceID" = VoucherPrefix.Prefix + cast (serviceInvoiceAbstract.DocumentID as varchar),  
"Doc Reference"=DocReference,
"Type" = case ServiceInvoiceType  
when 1 then  
'Service Invoice'  
else
''
end,   

--"Sales NetValue" =  sum(isnull(serviceinvoicedetail.netvalue,0)),
"Sales NetValue" = (select sum(isnull(serviceinvoicedetail.netvalue,0))
from serviceinvoiceabstract sa,serviceinvoicedetail
where sa.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  and
sa.serviceinvoicedate Between @FromDate And @ToDate
AND (sa.serviceInvoiceType = 1)                       
AND Isnull(sa.Status,0) & 192 = 0    
AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  
and sa.serviceInvoiceID = serviceInvoiceAbstract.serviceInvoiceID
group by sa.serviceinvoiceid),




"Service NetValue" = (select sum(isnull(serviceinvoicedetail.netvalue,0))
from serviceinvoiceabstract sa,serviceinvoicedetail
where sa.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  and
sa.serviceinvoicedate Between @FromDate And @ToDate
AND (sa.serviceInvoiceType = 1)                       
AND Isnull(sa.Status,0) & 192 = 0    
AND IsNull(ServiceinvoiceDetail.SpareCode, '') = ''  
and isnull(Serviceinvoicedetail.Taskid,'') <> ''  
and sa.serviceInvoiceID = serviceInvoiceAbstract.serviceInvoiceID
group by sa.serviceinvoiceid),

"Totalsales" = max(isnull(serviceinvoiceabstract.netvalue,0) - IsNull(Freight,0)),

"Net Value+Freight (%c)" = max(isnull(serviceinvoiceabstract.Netvalue,0)),


"Balance (%c)" = max(isnull(serviceinvoiceabstract.Balance,0)),

"Roundoff Net Value" = 	max(Isnull(serviceinvoiceabstract.NetValue,0) + isnull(serviceinvoiceabstract.RoundOffAmount,0))                         

from serviceinvoiceabstract,serviceinvoicedetail,VoucherPrefix
where serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  and
serviceInvoiceAbstract.serviceinvoicedate Between @FromDate And @ToDate    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0    
--AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' 
and VoucherPrefix.tranid = 'SERVICEINVOICE'   
group by VoucherPrefix.Prefix,serviceinvoiceabstract.DocumentId,serviceinvoiceabstract.DocReference,serviceinvoiceabstract.ServiceInvoiceType,
serviceinvoiceabstract.serviceinvoiceid  	

select * from #TotalSalesInvoiceTemp order by Type
drop table #TotalSalesInvoiceTemp

