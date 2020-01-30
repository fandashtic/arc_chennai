CREATE procedure spr_ser_total_sales(@FROMDATE DATETIME, @TODATE DATETIME)  
As  
SELECT 1, "Gross Revenue (%c)" = isnull((select sum(isnull(Amount,0))  
from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)),0)

+ ISNULL((SELECT SUM(Isnull(serviceinvoicedetail.NetValue,0))                       
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                       
AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE and @TODATE),0),


"Sales Return Damages(%c)" = (Select ISNULL(sum(Amount),0) from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE  
And InvoiceAbstract.Status&128=0   
and ((InvoiceAbstract.Status&32 <>0  
and InvoiceAbstract.InvoiceType=4) or (InvoiceAbstract.InvoiceType=6))),   
"Sales Return Saleable(%c)" = (Select ISNULL(sum(Amount),0) from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE  
And InvoiceAbstract.Status&128=0   
and ((InvoiceAbstract.Status&32=0  
and InvoiceAbstract.InvoiceType =4) or (InvoiceAbstract.InvoiceType =5))),

"Net Sales Revenue (%c)" = isnull((select sum(isnull(Amount,0))  
from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE 
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)),0) - isnull((select sum(isnull(Amount,0))  
from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (4,5,6)),0)


+ ISNULL((SELECT SUM(Isnull(serviceinvoicedetail.NetValue,0))                       
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                       
AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),


"Net Service Revenue (%c)" = ISNULL((SELECT SUM(Isnull(serviceinvoiceDetail.Netvalue,0))                         
FROM ServiceInvoiceDetail, serviceInvoiceAbstract
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                 
and isnull(Serviceinvoicedetail.Taskid,'') <> '' 
and IsNull(ServiceinvoiceDetail.SpareCode, '') = ''   
AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),


"Total Net Revenue (%c)" = isnull((select sum(isnull(Amount,0)) 
from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)),0) - isnull((select sum(isnull(Amount,0))  
from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (4,5,6)),0)

+ ISNULL((SELECT SUM(Isnull(serviceinvoicedetail.NetValue,0))                       
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                       
AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),



"Roundoff Net Value (%c)" = ISNULL((Select sum(NetValue + RoundOffAmount) from InvoiceAbstract  
Where invoicedate between @FROMDATE and @TODATE  
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)),0) - ISNULL((Select ISNULL(sum(NetValue + RoundOffAmount), 0)  
from InvoiceAbstract  
where invoicedate between @FROMDATE and @TODATE  
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (4,5,6)),0)  

+ ISNULL((SELECT SUM(Isnull(NetValue,0) + isnull(RoundOffAmount,0))                         
FROM serviceInvoiceAbstract
WHERE (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                 
AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)  


















