CREATE procedure spr_ser_channelwise_sales(            
        @FromDate datetime,            
        @ToDate datetime)            
as            

Create table #TempChannel(ch int,ChannelType nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
NetValue Decimal(18,6))

Insert into #TempChannel 

select  "CT" = isnull(customer.Channeltype,0),           
"Channel Type" = case isnull(customer.Channeltype,0)            
          
When 0 Then
'Others'
Else
Customer_Channel.ChannelDesc
End,            
"Total Sales (%c)" = isnull(sum(      
case invoicetype      
when 4 then      
 0-(NetValue-isnull(freight,0))      
else       
 NetValue-isnull(freight,0)  
end),0)      
from InvoiceAbstract,customer,Customer_Channel           
WHERE invoiceabstract.CustomerID = Customer.CustomerID AND  
Customer_Channel.ChannelType = Customer.ChannelType And           
InvoiceDate BETWEEN @fromDate AND @toDate AND     
InvoiceType in (1, 3,4) AND (Status & 128)= 0       
group by isnull(customer.channeltype,0),Customer_Channel.ChannelDesc

Insert into #TempChannel 

select "CT" = isnull(customer.Channeltype,0),           
"Channel Type" = case isnull(customer.Channeltype,0)            
      
When 0 Then
'Others'
Else
Customer_Channel.ChannelDesc
End,            
"Total Sales (%c)" = sum(Isnull(Serviceinvoicedetail.NetValue,0))
from serviceInvoiceAbstract,Serviceinvoicedetail,customer,Customer_Channel,items           
WHERE Serviceinvoiceabstract.CustomerID = Customer.CustomerID AND  
Customer_Channel.ChannelType = Customer.ChannelType And           
ServiceInvoiceDate BETWEEN @fromDate AND @toDate AND  
Serviceinvoiceabstract.serviceinvoiceid  = serviceinvoicedetail.serviceinvoiceid
And Isnull(serviceinvoicedetail.sparecode,'') <> '' And
Serviceinvoicedetail.sparecode = items.product_code And
ServiceInvoiceType in (1) AND Isnull(Status,0) & 192= 0       
group by isnull(customer.channeltype,0), Customer_Channel.ChannelDesc

select "CT" = isnull(Channeltype,0),           
"Channel Type" =isnull(Channeltype,0),            
"Total Sales " = sum(Netvalue)
From  #TempChannel
group by isnull(channeltype,0)
Drop table #TempChannel 





