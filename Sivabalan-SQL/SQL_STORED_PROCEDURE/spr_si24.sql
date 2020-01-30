CREATE procedure [dbo].[spr_si24](@Hier nvarchar(50), @Category nvarchar(100) , @UOM nvarchar(50)  , @FROMDATE datetime, @TODATE datetime)
AS  
DECLARE @BeatID int  
DECLARE @Sales nvarchar(255)  
DECLARE @ITEM_NAME nvarchar(50)  
DECLARE @DynamicSQL nvarchar(256) 
DECLARE @str1 nvarchar(255)  
DECLARE @DynamicOutlet nvarchar(4000)  
declare @Outlet_Count int
-- to find the level of the passed hierarchy
declare @level int  
Declare @MLOthers NVarchar(50)
Declare @MLOutletCount NVarchar(50)
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)
Set @MLOutletCount = dbo.LookupDictionaryItem(N'Outlet Count', Default)

if @Category like N'%' 
begin
	select @Level = HierarchyId from ItemHierarchy where HierarchyName like @Hier 
end
else
begin
	select @Level = HierarchyId from ItemHierarchy where HierarchyName like @Category
end
-- to get the cat rec in a #table 
Create Table #Cattemp (CategoryID int, Category_Name nvarchar(255),Status int)    
Declare @Continue int    
Declare @CategoryID int    
Set @Continue = 1    
-- insert the first category in this level
Insert into #Cattemp  select CategoryID,Category_Name,0 From ItemCategories
	where Category_Name in (select category_name from Itemcategories 
								where [level] = @Level and Category_name like @Category)
While @Continue > 0    
Begin
	Declare Parent Cursor Static For    
	Select CategoryID From #Cattemp Where Status = 0    
	Open Parent    
	Fetch From Parent Into @CategoryID    
	While @@Fetch_Status = 0    
	Begin    
		Insert into #Cattemp  Select CategoryID, Category_Name, 0 From ItemCategories 
			Where ParentID = @CategoryID    
		Update #Cattemp  Set Status = 1 Where CategoryID = @CategoryID    
		Fetch Next From Parent Into @CategoryID    
	End    
	Close Parent    
	DeAllocate Parent    
	Select @Continue = Count(*) From #Cattemp Where Status = 0    
End 
-- all the cate have been dumped
-- now the actual proc

create table #temp(BeatID int, Beat nvarchar(128), ItemName nvarchar(50), Sales Decimal(18,6), CustomerID nvarchar(15), Hier int, NetValue Decimal(18,6))  

create table #PivotTable(BeatID int primary key clustered, Beat nvarchar(128), OutletCount int, BeatwiseOutlet Integer, ValueTurnover Decimal(18,6)) 
IF @UOM = N'Sales Value'  
BEGIN  
insert into #temp  
Select  "BeatID" = IsNull(InvoiceAbstract.BeatID,0), 
	"Beat" = IsNull(Beat.Description, @MLOthers),   
	"Item Name" = Items.ProductName, 
	"Sales Value" = Sum(case InvoiceType When 4 Then 0 - Amount Else Amount End),  
	"Outlet Count" = CustomerID  , 
	dbo.getBrandID(Items.Product_Code, @Level)  
From  InvoiceAbstract, Beat, Items, InvoiceDetail  
	,ItemCategories
Where  (InvoiceAbstract.Status & 128) = 0 And InvoiceAbstract.BeatID *= Beat.BeatID And  
	 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
	 InvoiceDetail.Product_Code = Items.Product_Code And  
	 InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE  
	 and Items.Categoryid = ItemCategories.Categoryid and ItemCategories.Categoryid in (select Categoryid from #CatTemp)
Group By InvoiceAbstract.BeatID, Beat.Description, Items.ProductName, CustomerID  
	, Items.Product_Code
--	, dbo.getBrandID(Items.Product_Code, @Level)  
Order By Beat.Description  
END  
ELSE IF @UOM = N'Sales UOM' or @UOM = N'Reporting UOM'
BEGIN  
insert into #temp  
Select  "BeatID" = IsNull(InvoiceAbstract.BeatID,0), 
	"Beat" = IsNull(Beat.Description, @MLOthers),   
	"Item Name" = Items.ProductName, 
	"Sales Value" = Sum(case InvoiceType When 4 Then 0 - InvoiceDetail.Quantity 
										 Else InvoiceDetail.Quantity End),  
	"Outlet Count" = CustomerID  ,
	dbo.getBrandID(Items.Product_Code, @Level),
	"Net Value" = Sum(NetValue)
From  InvoiceAbstract, Beat, Items, InvoiceDetail  
	,ItemCategories
Where  (InvoiceAbstract.Status & 128) = 0 
	And InvoiceAbstract.BeatID *= Beat.BeatID And  
	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
	InvoiceDetail.Product_Code = Items.Product_Code And  
	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE  
	and Items.Categoryid = ItemCategories.Categoryid 
	and ItemCategories.Categoryid in (select Categoryid from #CatTemp)
Group By InvoiceAbstract.BeatID, Beat.Description, Items.ProductName, CustomerID  
	, Items.Product_Code
--	, dbo.getBrandID(Items.Product_Code, @Level)  
Order By Beat.Description  
END  
ELSE IF @UOM = N'Conversion Factor'  
BEGIN  
insert into #temp  
Select  "BeatID" = IsNull(InvoiceAbstract.BeatID,0), "Beat" = IsNull(Beat.Description, @MLOthers),   
	"Item Name" = Items.ProductName, 
	"Sales Value" = Sum(case InvoiceType When 4 Then 0 - (InvoiceDetail.Quantity * IsNull(Items.ConversionFactor,1)) 
						Else (InvoiceDetail.Quantity * IsNull(Items.ConversionFactor,1)) End),  
	"Outlet Count" = CustomerID  ,
	dbo.getBrandID(Items.Product_Code, @Level),
	"Net Value" = Sum(NetValue)  
From  InvoiceAbstract, Beat, Items, InvoiceDetail  
	,ItemCategories
Where  (InvoiceAbstract.Status & 128) = 0 
	And InvoiceAbstract.BeatID *= Beat.BeatID And  
	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
	InvoiceDetail.Product_Code = Items.Product_Code And  
	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE  
	and Items.Categoryid = ItemCategories.Categoryid and ItemCategories.Categoryid in (select Categoryid from #CatTemp)
Group By InvoiceAbstract.BeatID, Beat.Description, Items.ProductName, CustomerID  
	, Items.Product_Code
--     , dbo.getBrandID(Items.Product_Code, @Level)  
Order By Beat.Description  
END  
 
-- now since all details is in the #temp table, filter it  
DECLARE AddItemsAsColumns CURSOR STATIC FOR  -- dec a cursor to handle item wise
Select Distinct ItemName From #temp  
  
Open AddItemsAsColumns  
FETCH FROM AddItemsAsColumns Into @ITEM_NAME  
While @@FETCH_STATUS = 0  -- generating cols in the name of each item
BEGIN  
	If @UOM <> N'Reporting UOM'
	SET @DynamicSQL = N'ALTER TABLE #PivotTable Add [' + @ITEM_NAME + N'] Decimal(18,6) Null'   
	Else
	SET @DynamicSQL = N'ALTER TABLE #PivotTable Add [' + @ITEM_NAME + N'] nvarchar(255) Null'   
	exec sp_executesql @DynamicSQL  
	FETCH NEXT FROM AddItemsAsColumns Into @ITEM_NAME  
END  
Close AddItemsAsColumns  
DeAllocate AddItemsAsColumns  
-- select @DynamicOutlet 
insert into #PivotTable (BeatID, Beat, OutletCount, BeatwiseOutlet, ValueTurnover) values(-1,@MLOutletCount, 0, 0, 0)
insert into #PivotTable(BeatID, Beat, OutletCount, BeatwiseOutlet, ValueTurnover) Select BeatID, Beat, Count(Distinct CustomerID), Count(CustomerID), Sum(NetValue) From #temp Group By BeatID, Beat
--select * from #temp  order by beatid , ItemName
Declare UpdateSalesValue CURSOR STATIC FOR  
Select BeatID, ItemName, Sum(Sales) From #temp  Group By BeatID, ItemName
Open UpdateSalesValue  
FETCH FROM UpdateSalesValue Into @BeatID, @ITEM_NAME, @Sales  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	-- get the outlet count
	select 	@Outlet_Count = count(distinct customerid) 
	from 	invoiceabstract, invoicedetail
	where 	
		invoiceabstract.invoiceid = invoicedetail.invoiceid
		and invoicedetail.product_code = (select product_code from items where productname like @ITEM_NAME)
		And InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE  
		and (InvoiceAbstract.Status & 128) = 0 
	SET @DynamicSQL = N'Update #PivotTable Set [' + @ITEM_NAME + N'] = ' 
				+ cast(@Outlet_Count as nvarchar) + N' Where BeatID = -1 and OutletCount = 0' 

	exec sp_executesql @DynamicSQL  
	set @DynamicSQL = N''
	-- to dynamically generate the Table

	If @UOM <> N'Reporting UOM'
	SET @DynamicSQL = N'Update #PivotTable Set [' + @ITEM_NAME + N'] = ' 
				+ cast(@Sales as nvarchar) + N' + IsNull([' + @ITEM_NAME + N'],0) Where BeatID = ' 
				+ cast(@BeatID as nvarchar)
	Else
	Begin
	Set @str1 =  (Select dbo.sp_Get_ReportingUOMQty((select product_code from items where productname like  @ITEM_NAME) ,cast(@Sales as nvarchar)))
	SET @DynamicSQL = N'Update #PivotTable Set [' + @ITEM_NAME + N'] = ''' 
				+  @str1 +  ''' Where BeatID = ' 
				+ cast(@BeatID as nvarchar)  

	End
	exec sp_executesql @DynamicSQL  
	FETCH NEXT FROM UpdateSalesValue Into @BeatID, @ITEM_NAME, @Sales  
END  
Close UpdateSalesValue  
DeAllocate UpdateSalesValue  
  
Select * From #PivotTable  
drop table #PivotTable  
drop table #temp
drop table #Cattemp
