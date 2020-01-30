CREATE Procedure spr_Repeat_Retail_Universe (@ProductHierarchy nVarchar(255),
					 @Category nVarchar(2550),
					 @UOM nVarchar(255),
					 @RefFromDate Datetime,
					 @RefToDate Datetime,
					 @ComFromDate Datetime,
					 @ComToDate Datetime)
As
Declare @Others nVarchar(50)
set @Others = dbo.LookupdictionaryItem(N'Others',default)
Create Table #tempCategory(CategoryID int,
			   Status int)
Exec dbo.GetLeafCategories @ProductHierarchy, @Category
Create Table #temp (ChannelID int,
		    ChannelName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS Null,
		    Outlets int Null)

Insert into #temp 
 Select IsNull(Customer.ChannelType, 0), 
Case IsNull(Customer.ChannelType, 0)
When 0 Then
@Others
Else
Customer_Channel.ChannelDesc
End,
Count(Distinct InvoiceAbstract.CustomerID)
From InvoiceAbstract, InvoiceDetail, Items, Customer,Customer_Channel
Where InvoiceAbstract.InvoiceDate Between @RefFromDate And @RefToDate And
InvoiceAbstract.Status & 128 = 0 And
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
Customer_Channel.ChannelType = Customer.ChannelType And
InvoiceDetail.Product_Code = Items.Product_Code And
Items.CategoryID In (Select CategoryID From #tempCategory) And
InvoiceAbstract.CustomerID = Customer.CustomerID And
InvoiceAbstract.CustomerID in (Select Distinct InvoiceAbstract.CustomerID
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
Cast(@RefFromDate As nVarchar) + ';' + Cast(@RefToDate As nVarchar) + ';' + 
Cast(ChannelID As nVarchar), 
"Channel" = ChannelName, "No. Of Outlets" = Count(Outlets) 
From #temp 
Group By ChannelID, ChannelName
Drop Table #temp
Drop Table #tempCategory



