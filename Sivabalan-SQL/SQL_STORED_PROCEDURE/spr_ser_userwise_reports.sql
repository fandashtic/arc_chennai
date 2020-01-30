CREATE procedure spr_ser_userwise_reports(@fromdate datetime, @todate datetime)    
As  
  
CREATE table #TempInvoiceuser(User1 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
UserName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalesNetValue Decimal(18,6),ServiceNetValue Decimal(18,6),TotalNetValue Decimal(18,6))  
  
Insert into #TempInvoiceuser   
select Username, "User Name" = Username,     
"Total Sales Amount" = sum(case      
WHEN InvoiceType>=4 and InvoiceType<=6 Then     
0 -(NetValue-isnull(Freight,0))     
Else     
(NetValue-isnull(Freight,0))     
END),    
"Total Service Amount" = 0,  
"SalesNetValue" = sum(case      
WHEN InvoiceType>=4 and InvoiceType<=6 Then     
0 -(NetValue-isnull(Freight,0))     
Else     
(NetValue-isnull(Freight,0))     
END)  
from InvoiceAbstract     
where CreationTime between @fromdate and @todate    
and (status & 128=0)    
group by Username    
  
Insert into #TempInvoiceuser   
  
  
select Username,  
"User Name" = Username,     
  
"Total Sales Amount" = ISNULL((SELECT SUM(Isnull(serviceinvoiceDetail.Netvalue,0))                         
FROM ServiceInvoiceDetail, serviceInvoiceAbstract,items
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                 
AND serviceInvoiceDetail.sparecode = items.product_code    
AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
AND serviceInvoiceAbstract.CreationTime BETWEEN @FROMDATE AND @TODATE),0),  
  
  
"Total Service Amount" = ISNULL((SELECT SUM(Isnull(serviceinvoiceDetail.Netvalue,0))                         
FROM ServiceInvoiceDetail, serviceInvoiceAbstract,items
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                 
AND serviceInvoiceDetail.product_code = items.product_code    
and isnull(Serviceinvoicedetail.Taskid,'') <> ''  
and IsNull(ServiceinvoiceDetail.SpareCode, '') = ''   
AND serviceInvoiceAbstract.CreationTime BETWEEN @FROMDATE AND @TODATE),0),  
  
  
"Total Service Amount" = ISNULL((SELECT SUM(Isnull(serviceinvoiceDetail.Netvalue,0))                         
FROM ServiceInvoiceDetail, serviceInvoiceAbstract,items
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                 
AND serviceInvoiceDetail.sparecode = items.product_code    
AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
AND serviceInvoiceAbstract.CreationTime BETWEEN @FROMDATE AND @TODATE),0)  
  
+ ISNULL((SELECT SUM(Isnull(serviceinvoiceDetail.Netvalue,0))                         
FROM ServiceInvoiceDetail, serviceInvoiceAbstract,items
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                 
AND serviceInvoiceDetail.product_code = items.product_code    
and isnull(Serviceinvoicedetail.Taskid,'') <> ''  
and IsNull(ServiceinvoiceDetail.SpareCode, '') = ''   
AND serviceInvoiceAbstract.CreationTime BETWEEN @FROMDATE AND @TODATE),0)  
  
from serviceInvoiceAbstract, serviceinvoicedetail     
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0   
group by Username    

  
select  User1 = USerName, "User Name" = Username,  
"Sales Amount" = sum(SalesNetvalue),  
"Service Amount" = sum(ServiceNetvalue),  
"Total Amount" =  sum(SalesNetvalue)+ sum(ServiceNetValue)  
From  #TempInvoiceuser  group by username  
  
Drop table #TempInvoiceuser   


