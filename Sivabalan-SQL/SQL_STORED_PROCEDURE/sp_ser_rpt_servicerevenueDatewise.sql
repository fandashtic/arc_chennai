CREATE procedure sp_ser_rpt_servicerevenueDatewise    
(@fromdate as datetime, @todate as datetime) as    
    

select [ServiceInvoiceDate]As [Date],[ServiceInvoiceDate] As [ServiceInvoice Date],  
Sum([Tasksum])As [Task Amount],Sum([Sparesum ])As [Spare Amount],                  
Sum([Total Amount])As [Total Amount]  
From  
(SELECT 'servicedate' = CAST(DATEPART(dd, a.serviceinvoicedate) AS VARCHAR) + '/'   
+ CAST(DATEPART(mm, a.serviceinvoicedate) AS VARCHAR) + '/'      
+ SubString(CAST(DATEPART(yyyy, a.serviceinvoicedate) AS VARCHAR), 1, 4),   
serviceinvoicedate = CAST(DATEPART(dd, a.serviceinvoicedate) AS VARCHAR) + '/'   
+ CAST(DATEPART(mm, a.serviceinvoicedate) AS VARCHAR) + '/'      
+ SubString(CAST(DATEPART(yyyy, a.serviceinvoicedate) AS VARCHAR), 1, 4),   
Sum((Case When (d.type = 2 and     
IsNull(d.SpareCode,'') = '') then IsNull(d.NetValue,0) else 0 End)) 'Tasksum',     
Sum((Case When (IsNull(d.SpareCode,'') <> '') then IsNull(d.NetValue,0) else  0 End)) 'Sparesum',     
Sum((Case When d.Type = 0 then IsNull(a.NetValue,0) else 0 End)) 'Total Amount'    
from ServiceInvoiceAbstract a  
inner Join ServiceInvoiceDetail d On a.ServiceInvoiceID = d.ServiceInvoiceID    
where a.ServiceInvoiceDate between @fromdate and @ToDate
and ((IsNull(a.Status,0) & 192) <> 192)    
group by serviceinvoicedate,serviceinvoicedate ) as grt  
group by [ServiceInvoiceDate] 


