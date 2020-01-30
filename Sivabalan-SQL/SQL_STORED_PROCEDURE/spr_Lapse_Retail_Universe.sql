CREATE Procedure spr_Lapse_Retail_Universe (@ProductHierarchy nvarchar(255),
					 @Category nvarchar(2550),
					 @UOM nvarchar(255),
					 @RefFromDate Datetime,
					 @RefToDate Datetime,
					 @ComFromDate Datetime,
					 @ComToDate Datetime)
As
Create Table #tempCategory(CategoryID int,
			   Status int)
Exec dbo.GetLeafCategories @ProductHierarchy, @Category
Create Table #temp (ChannelID int,
		    ChannelName nvarchar(255) Null,
		    Outlets int Null)

Declare @OTHERS nvarchar(20) 
Select @OTHERS = dbo.LookupdictionaryItem(N'Others',Default)

Insert into #temp 
 Select IsNull(Customer.ChannelType, 0), 
Case IsNull(Customer.ChannelType, 0)
When 0 Then
@OTHERS
Else
Customer_Channel.ChannelDesc
End,
Count(Distinct InvoiceAbstract.CustomerID)
From InvoiceAbstract, InvoiceDetail, Items, Customer, Customer_Channel
Where InvoiceAbstract.InvoiceDate Between @RefFromDate And @RefToDate And
InvoiceAbstract.Status & 128 = 0 And
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
Customer_Channel.ChannelType = Customer.ChannelType And
InvoiceDetail.Product_Code = Items.Product_Code And
Items.CategoryID In (Select CategoryID From #tempCategory) And
InvoiceAbstract.CustomerID = Customer.CustomerID And
InvoiceAbstract.CustomerID Not in (Select Distinct InvoiceAbstract.CustomerID
From InvoiceAbstract, InvoiceDetail, Items, Customer
Where InvoiceAbstract.InvoiceDate Between @ComFromDate And @ComToDate And
InvoiceAbstract.Status & 128 = 0 And
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceDetail.Product_Code = Items.Product_Code And
Items.CategoryID In (Select CategoryID From #tempCategory) And
InvoiceAbstract.CustomerID = Customer.CustomerID
Group By InvoiceAbstract.CustomerID, IsNull(Customer.ChannelType, 0))
Group By InvoiceAbstract.CustomerID, IsNull(Customer.ChannelType, 0),Customer_Channel.ChannelDesc

Select @ProductHierarchy + ';' + @Category + ';' + @UOM + ';' +
Cast(@RefFromDate As nvarchar) + ';' + Cast(@RefToDate As nvarchar) + ';' 
+ Cast(ChannelID As nvarchar), 
"Channel" = ChannelName, "No. Of Outlets" = Count(Outlets) 
From #temp 
Group By ChannelID, ChannelName
Drop Table #temp
Drop Table #tempCategory


