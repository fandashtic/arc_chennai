CREATE procedure sp_ser_rpt_servicerevenueabstract
(@fromdate as datetime, @todate as datetime) as

Select 0, i.Product_Code 'Item Code', i.ProductName 'Item Name',  
Sum((Case When (d.type = 2 and IsNull(d.SpareCode,'') = '') then IsNull(d.NetValue,0) else 0 End)) 'Task Amount', 
Sum((Case When (IsNull(d.SpareCode,'') <> '') then IsNull(d.NetValue,0) else  0 End)) 'Spare Amount', 
Sum((Case When d.Type = 0 then IsNull(a.NetValue,0) else 0 End)) 'Total Amount'
from ServiceInvoiceAbstract a 
Inner Join ServiceInvoiceDetail d On a.ServiceInvoiceID = d.ServiceInvoiceID
inner Join Items i On i.Product_Code = d.Product_Code 
where ((IsNull(a.Status,0) & 192) <> 192) and (dbo.sp_ser_StripDateFromTime(a.ServiceInvoiceDate) between @fromdate and @todate)  
group by i.Product_Code, i.ProductName 

