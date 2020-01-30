Create procedure spr_channelwise_sales(
        @MerchandiseType nVarchar(2000),                
        @FromDate datetime,                
        @ToDate datetime)  
as    
Declare @OTHERS As NVarchar(50)    
Declare @Delimeter Char(1)  
Set @Delimeter=Char(15)    
Create Table #tmpMerchandiseType (ID Integer Identity(1,1), MerchandiseType nvarchar (255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
If @MerchandiseType <> N'%'    
Begin      
  Insert into #tmpMerchandiseType select * from dbo.sp_SplitIn2Rows(@MerchandiseType,@Delimeter)         
End    
  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)    
  
IF @MerchandiseType = N'%'  
 select (Cast(isnull(customer.Channeltype,0) as nVarchar(100)) + Char(15) + @MerchandiseType),                 
 "Channel Type" = case isnull(customer.Channeltype,0)                  
 When 0 Then      
  @OTHERS      
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
 group by   
 (Cast(isnull(customer.Channeltype,0) as nVarchar(100)) + Char(15) + @MerchandiseType),  
 isnull(customer.Channeltype,0), Customer_Channel.ChannelDesc      
Else  
 select (Cast(isnull(customer.Channeltype,0) as nVarchar(100)) + Char(15) + @MerchandiseType),                 
 "Channel Type" = case isnull(customer.Channeltype,0)                  
                
 When 0 Then      
  @OTHERS      
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
   Customer.CustomerID in (Select Distinct CustMrc.CustomerID From CustMerchandise CustMrc, Merchandise Mrc Where   
          CustMrc.MerchandiseID = Mrc.MerchandiseID And   
          Mrc.Merchandise in (Select MerchandiseType From #tmpMerchandiseType)) And   
   Customer_Channel.ChannelType = Customer.ChannelType And                 
   InvoiceDate BETWEEN @fromDate AND @toDate AND                   
   InvoiceType in (1, 3,4) AND (Status & 128)= 0             
 group by   
 (Cast(isnull(customer.Channeltype,0) as nVarchar(100)) + Char(15) + @MerchandiseType),  
 isnull(customer.Channeltype,0), Customer_Channel.ChannelDesc  
Drop table #tmpMerchandiseType  
