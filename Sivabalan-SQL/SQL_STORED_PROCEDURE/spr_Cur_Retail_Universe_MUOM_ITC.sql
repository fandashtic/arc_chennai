
Create Procedure spr_Cur_Retail_Universe_MUOM_ITC (@ProductHierarchy nvarchar(2550),  
      @Category nvarchar(2550),  
      @UOM nvarchar(255),  
      @FromDate Datetime,  
      @ToDate Datetime)  
As  
Declare @OTHERS NVarchar(50)  
Set @OTHERS=dbo.LookupDictionaryItem(N'Others', Default)  
Create Table #tempCategory(CategoryID int,  Status int)  

Exec dbo.GetLeafCategories @ProductHierarchy, @Category  
Create Table #temp (ChannelID int,  
      ChannelName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS Null,  
      Outlets int Null)  
  
Insert into #temp   
Select IsNull(Customer.ChannelType, 0),   
Case IsNull(Customer.ChannelType, 0)  
When 0 Then  
@OTHERS  
Else  
Customer_Channel.ChannelDesc  
End,  
(Select Count(Customer.CustomerId) From Customer 
Where ChannelType = (Select ChannelType From Customer 
Where CustomerId = InvoiceAbstract.CustomerId))
From InvoiceAbstract, InvoiceDetail, Items, Customer,Customer_Channel  
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
InvoiceAbstract.Status & 128 = 0 And  
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
Customer_Channel.ChannelType = Customer.ChannelType And  
InvoiceDetail.Product_Code = Items.Product_Code And  
Items.CategoryID In (Select CategoryID From #tempCategory) And  
InvoiceAbstract.CustomerID = Customer.CustomerID  
Group By InvoiceAbstract.CustomerID, IsNull(Customer.ChannelType, 0),Customer_Channel.ChannelDesc  
  
Select @ProductHierarchy + ';' + @Category + ';' + @UOM + ';' + Cast(ChannelID As nvarchar),   
"Channel" = ChannelName, "No. Of Outlets" = Outlets   
From #temp   
Group By ChannelID, ChannelName, Outlets 

Drop Table #temp  
Drop Table #tempCategory  
  
  
