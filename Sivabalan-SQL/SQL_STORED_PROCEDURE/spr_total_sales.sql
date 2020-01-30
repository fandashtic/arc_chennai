CREATE procedure spr_total_sales(@FROMDATE DATETIME, @TODATE DATETIME)  
As  
SELECT 1, "Gross Sales (%c)" = (Select sum(Amount)  
from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE  
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)),   
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
"Net Sales (%c)" = (Select sum(Amount) from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE  
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)) - (Select ISNULL(sum(Amount), 0)  
from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE  
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in(4,5,6)),  
"Roundoff Net Value (%c)" = (Select sum(NetValue + RoundOffAmount) from InvoiceAbstract  
Where invoicedate between @FROMDATE and @TODATE  
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)) - (Select ISNULL(sum(NetValue + RoundOffAmount), 0)  
from InvoiceAbstract  
where invoicedate between @FROMDATE and @TODATE  
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (4,5,6))  


