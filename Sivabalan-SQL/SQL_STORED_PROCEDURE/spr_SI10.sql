CREATE procedure [dbo].[spr_SI10](@FROMDATE datetime, @TODATE datetime)  
AS  
DECLARE @CategoryID int  
DECLARE @Retailer nvarchar(255)  
DECLARE @CategoryName nvarchar(128)  
DECLARE @Beat nvarchar(255)  
DECLARE @TurnOver Decimal(18,6)  
DECLARE @YesNo nvarchar(3)  
DECLARE @DynSQL nvarchar(4000)  
DECLARE @LevelC int  
DECLARE @LevelV int  
Declare @MLOthers NVarchar(50)
Declare @MLYes NVarchar(50)
Declare @MLNo NVarchar(50)
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)
Set @MLYes = dbo.LookupDictionaryItem(N'Yes', Default)
Set @MLNo = dbo.LookupDictionaryItem(N'No', Default)
  
Select @LevelC = IsNull(HierarchyId, 1) From ItemHierarchy Where HierarchyName = dbo.LookupDictionaryItem(N'Category', Default)
Select @LevelV = IsNull(HierarchyId, 1) From ItemHierarchy Where HierarchyName = dbo.LookupDictionaryItem(N'Variant', Default)
CREATE TABLE #temp(Retailer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Beat nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS, Channel nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemCode nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, Quantity Decimal(18,6), Amount Decimal(18,6), CategoryL3 int, CategoryL2 int)  
CREATE TABLE #temp2(ID int identity not null, Retailer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS not null, Channel nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS, Beat nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS not null)  
ALTER TABLE #temp2 WITH NOCHECK ADD CONSTRAINT [PK_Test] PRIMARY KEY  CLUSTERED ([Retailer],[Beat])
insert into #temp  
select "Retailer Name" = customer.company_name,"Beat Name" = IsNull(Beat.Description, @MLOthers),  
"Channel" = Case isnull(Customer.ChannelType,0)
When 0 Then
@MLOthers
Else
Customer_Channel.ChannelDesc
End,
"Code" = invoicedetail.product_code,  
"Qty" = SUM(case invoicetype when 4 then 0-Quantity else Quantity End),  
"Amount" = SUM(case invoicetype when 4 then 0-Amount else Amount End),
"Category L3" = dbo.GetBrandID(Invoicedetail.product_code, IsNull(@LevelV, 1)),  
"Category L2" = dbo.GetBrandID(Invoicedetail.product_code, IsNull(@LevelC, 1))  
from invoiceabstract,customer,beat,invoicedetail,Customer_Channel   
where invoiceabstract.customerid = customer.customerid and  
Customer_Channel.ChannelType = Customer.ChannelType And
invoiceabstract.beatid *= beat.beatid and   
invoiceabstract.invoiceid = invoicedetail.invoiceid and  
(InvoiceAbstract.InvoiceType in (1,3) or ((InvoiceAbstract.Status & 32) = 0 and InvoiceType = 4)) and   
(InvoiceAbstract.Status & 128) = 0 and  
InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE and 
IsNull(InvoiceDetail.Product_Code, N'') <> N''
Group By Customer.Company_Name, Beat.Description, InvoiceDetail.Product_Code, Customer.ChannelType, Customer_Channel.ChannelDesc  

insert into #temp2(Retailer, Channel, Beat)  
select Retailer, Channel, Beat From #temp Group By Retailer, Channel, Beat  
  
Declare CreateCategoriesAndVariants CURSOR FOR  
Select Distinct CategoryL2, Category_Name From #temp, ItemCategories  
Where #temp.CategoryL2 = ItemCategories.CategoryID  
  
Open CreateCategoriesAndVariants  
Fetch From CreateCategoriesAndVariants Into @CategoryID, @CategoryName  
While @@FETCH_STATUS = 0  
Begin  
 Set @DynSQL = N'Alter Table #temp2 ADD [' + @CategoryName + N'] Decimal(18,6) null'  
 exec sp_executesql @DynSQL  
 Declare CreateVariants CURSOR FOR  
 Select Distinct Category_Name From #temp, ItemCategories  
 Where #temp.CategoryL3 = ItemCategories.CategoryID And #temp.CategoryL2 = @CategoryID  
 Open CreateVariants  
 Fetch From CreateVariants Into @CategoryName  
 While @@FETCH_STATUS = 0  
 Begin  
  Set @DynSQL = N'Alter Table #temp2 ADD [' + @CategoryName + N'] nvarchar(3) null'  
  exec sp_executesql @DynSQL  
  Set @DynSQL = N'Update #temp2 Set [' + @CategoryName + N'] = ''No'''  
  exec sp_executesql @DynSQL  
  Fetch Next From CreateVariants Into @CategoryName  
 End  
 Close CreateVariants  
 DeAllocate CreateVariants  
 Fetch Next From CreateCategoriesAndVariants Into @CategoryID, @CategoryName  
End  
Close CreateCategoriesAndVariants  
DeAllocate CreateCategoriesAndVariants  

DECLARE UpdateCategoryData CURSOR FOR  
Select Retailer, Beat, Category_Name, Sum(Amount) From #temp, ItemCategories  
Where #temp.CategoryL2 = ItemCategories.CategoryID  
Group By Retailer, Beat, Category_Name  
  
Open UpdateCategoryData  
Fetch From UpdateCategoryData Into @Retailer, @Beat, @CategoryName, @TurnOver  
While @@FETCH_STATUS = 0  
Begin  
 Set @DynSQL = N'Update #temp2 Set [' + @CategoryName + '] = ' + Cast(@TurnOver as nvarchar) + N' Where Retailer = N''' + Replace(@Retailer, '''', '''''')  + ''' and Beat = N'''  + Replace(@Beat, '''', '''''') + ''''
 exec sp_executesql @DynSQL  
 Fetch Next From UpdateCategoryData Into @Retailer, @Beat, @CategoryName, @TurnOver  
End  
Close UpdateCategoryData  
DeAllocate UpdateCategoryData  
  
DECLARE UpdateVariantData CURSOR FOR  
Select Retailer, Category_Name, Case When Sum(Quantity) > 0 Then @MLYes Else @MLNo End  
From #temp, ItemCategories  
Where #temp.CategoryL3 = ItemCategories.CategoryID  
Group By Retailer, Category_Name  
  
Open UpdateVariantData  
Fetch From UpdateVariantData Into @Retailer, @CategoryName, @YesNo  
While @@FETCH_STATUS = 0  
Begin  
 Set @DynSQL = N'Update #temp2 Set [' + @CategoryName + '] = N''' + @YesNo + ''' Where Retailer = N''' + Replace(@Retailer, '''', '''''') + ''''  
 exec sp_executesql @DynSQL  
 Fetch Next From UpdateVariantData Into @Retailer, @CategoryName, @YesNo  
End  
Close UpdateVariantData  
DeAllocate UpdateVariantData  
  
Select * from #temp2  
drop table #temp  
drop table #temp2
