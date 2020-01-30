CREATE procedure spr_userwise_reports(@fromdate datetime, @todate datetime)  
as  
select Username, "User Name" = Username,   
"Total Amount" = sum(case    
WHEN InvoiceType>=4 and InvoiceType<=6 Then   
0 -(NetValue-isnull(Freight,0))   
Else   
(NetValue-isnull(Freight,0))   
END)  
from InvoiceAbstract   
where CreationTime between @fromdate and @todate  
and (status & 128=0)  
group by Username  
  


