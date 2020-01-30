CREATE procedure spr_channelwise_sales_pidilite(@CHANNEL nvarchar(2550),            
        @FromDate datetime,            
        @ToDate datetime)            
as            

Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)    

Create table #tmpChannel(ChannelDesc nvarchar(255))        

if @Channel = N'%'        
   Insert into #tmpChannel select ChannelDesc from customer_channel        
Else        
   Insert into #tmpChannel select * from dbo.sp_SplitIn2Rows(@Channel,@Delimeter)        

select isnull(customer.Channeltype,0),           
"Channel Type" = case isnull(customer.Channeltype,0)            
          
When 0 Then
N'Others'
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
   Customer_Channel.channelDesc In (Select channelDesc from #tmpChannel) And
   InvoiceDate BETWEEN @fromDate AND @toDate AND             
   InvoiceType in (1, 3,4) AND (Status & 128)= 0       
group by isnull(customer.channeltype,0), Customer_Channel.ChannelDesc

