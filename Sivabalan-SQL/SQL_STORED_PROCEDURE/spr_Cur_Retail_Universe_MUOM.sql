CREATE Procedure spr_Cur_Retail_Universe_MUOM (@ProductHierarchy nvarchar(2550),
					 @Category nvarchar(2550),
					 @UOM nvarchar(255),
					 @FromDate Datetime,
					 @ToDate Datetime)
As
Declare @OTHERS NVarchar(50)
Set @OTHERS=dbo.LookupDictionaryItem(N'Others', Default)
Create Table #tempCategory(CategoryID int,
			   Status int)
-- Declare @Continue int
-- Declare @CategoryID int
-- Set @Continue = 1
-- Insert into #tempCategory select CategoryID, 0 
-- From ItemCategories, ItemHierarchy
-- Where ItemCategories.Category_Name like @Category And 
-- ItemCategories.Level =  ItemHierarchy.HierarchyID And
-- ItemHierarchy.HierarchyName like @ProductHierarchy
-- 
-- While @Continue > 0
-- Begin
-- 	Declare Parent Cursor Keyset For
-- 	Select CategoryID From #tempCategory Where Status = 0
-- 	Open Parent
-- 	Fetch From Parent Into @CategoryID
-- 	While @@Fetch_Status = 0
-- 	Begin
-- 		Insert into #tempCategory 
-- 		Select CategoryID, 0 From ItemCategories 
-- 		Where ParentID = @CategoryID
-- 		If @@RowCount > 0 
-- 			Update #tempCategory Set Status = 1 Where CategoryID = @CategoryID
-- 		Else
-- 			Update #tempCategory Set Status = 2 Where CategoryID = @CategoryID
-- 		Fetch Next From Parent Into @CategoryID
-- 	End
-- 	Close Parent
-- 	DeAllocate Parent
-- 	Select @Continue = Count(*) From #tempCategory Where Status = 0
-- End
-- Delete #tempcategory Where Status not in  (0, 2)
Exec dbo.GetLeafCategories @ProductHierarchy, @Category

Declare @temp Table(ChannelID int, ChannelName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS Null, Outlets int Null)

Insert into @temp 
Select IsNull(Customer.ChannelType, 0), 
Case IsNull(Customer.ChannelType, 0)
When 0 Then
@OTHERS
Else
Customer_Channel.ChannelDesc
End,
Count(Distinct InvoiceAbstract.CustomerID)
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
"Customer Type" = ChannelName, "No. Of Outlets" = Count(Outlets) 
From @temp 
Group By ChannelID, ChannelName
Drop Table #tempCategory




