CREATE Procedure spr_Cash_Parties_MUOM (@FromDate Datetime,  
       @ToDate Datetime, @UOMDesc nvarchar(50))  
As  

Declare @OTHERS As NVarchar(50)

Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)

Select IsNull(Customer.ChannelType, 0),  
"Customer Type" = Case IsNull(Customer.ChannelType, 0)  
When 0 Then  
@OTHERS
Else  
Customer_Channel.ChannelDesc  
End,  
"No. Of Outlet" = Count(Distinct InvoiceAbstract.CustomerID)  
From InvoiceAbstract, Customer, Customer_Channel  
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
InvoiceAbstract.Status & 128 = 0 And  
InvoiceAbstract.CustomerID = Customer.CustomerID And  
Customer_Channel.ChannelType = Customer.ChannelType And  
InvoiceAbstract.PaymentMode = 1 And  
InvoiceAbstract.InvoiceType in (1, 3)  
Group By IsNull(Customer.ChannelType, 0),Customer_Channel.ChannelDesc  
  


