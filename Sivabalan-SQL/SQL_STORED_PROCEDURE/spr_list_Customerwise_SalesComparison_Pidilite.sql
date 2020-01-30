CREATE Procedure [dbo].[spr_list_Customerwise_SalesComparison_Pidilite]
(    
@RefFromDate dateTime,   
@RefToDate dateTime,
@ComFromDate dateTime,   
@ComToDate dateTime,
@Customer nvarchar(2550),     
@Category nvarchar(510),
@UOMdesc nvarchar(50)
)  
AS  

Declare @SQL nvarchar(4000)
Declare @ComparisonDB nvarchar(200)
Declare @ComOpeningDate datetime
Declare @RefOpeningDate datetime
Declare @Delimeter char(1)

Create Table #tmpValidations
(
Flag int,
Status nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CYTransDate datetime,
RYTransDate datetime
)

exec sp_Validate_ComparisonParameters_Pidilite @RefFromDate,@RefToDate,@ComFromDate,@ComToDate

If (select Flag from #tmpValidations) = 1
Begin
Set @ComparisonDB = (select Status from #tmpValidations)
Set @ComOpeningDate = (select CYTransDate from #tmpValidations)
Set @RefOpeningDate = (select RYTransDate from #tmpValidations)

Create Table #tempCategory(CategoryID int, Status int)         
Exec GetLeafCategories '%', @Category

Set @Delimeter = Char(15)

create table #tmpCust(customerid nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @Customer=N'%'    
   insert into #tmpCust select customerid from customer    
else    
   insert into #tmpCust select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)

Create Table #tmpSalesDetails ([Customer Name] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                               Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
			       CompQty Decimal(18,6) default 0,RefQty Decimal(18,6) default 0,
			       CompValue Decimal(18,6) default 0,RefValue Decimal(18,6) default 0,
			       CompCumQty Decimal(18,6) default 0,RefCumQty Decimal(18,6) default 0,
			       CompCumValue Decimal(18,6) default 0 ,RefCumValue Decimal(18,6) default 0)  

insert into #tmpSalesDetails([Customer Name],Category,RefCumQty,RefCumValue,RefQty,RefValue)
select Company_Name,Category_Name,
Case @UOMDesc When 'Sales UOM' Then Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End)
              When 'UOM1' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End)  
              When 'UOM2' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End) 
              End,
Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End),
Case @UOMDesc When 'Sales UOM' Then Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End)
              When 'UOM1' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), 
              Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End)  
              When 'UOM2' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), 
              Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End) 
              End,
Sum(Case When (InvoiceDate >= @RefFromDate) 
Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End
Else 0 
End)
From InvoiceAbstract,InvoiceDetail,ItemCategories,Items,Customer
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
And InvoiceDetail.product_Code = Items.Product_Code
And Items.CategoryID = Itemcategories.CategoryID
And InvoiceAbstract.CustomerID = Customer.CustomerID
And InvoiceType in (1,2,3,4,5,6)
And Status & 128 = 0 
And ItemCategories.CategoryID in (select CategoryID from #tempCategory)
And InvoiceAbstract.CustomerID in (select customerID from #tmpCust)
And InvoiceDate Between @RefOpeningDate and @RefToDate
Group By Company_Name, Category_Name, Items.Product_Code

Set @SQL = N'insert into #tmpSalesDetails ([Customer Name],Category,CompCumQty,CompCumValue,CompQty,CompValue)'
Set @SQL = @SQL + N'select Company_Name,Category_Name, '
Set @SQL = @SQL + N'Case ''' + @UOMdesc + N''' ' 
Set @SQL = @SQL + N'When ''Sales UOM'' Then Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End) '   
Set @SQL = @SQL + N'When ''UOM1'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End) '               
Set @SQL = @SQL + N'When ''UOM2'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End) End,'
Set @SQL = @SQL + N'Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End),'
Set @SQL = @SQL + N'Case ''' + @UOMDesc + N''' '
Set @SQL = @SQL + N'When ''Sales UOM'' Then Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End) '
Set @SQL = @SQL + N'When ''UOM1'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), ' 
Set @SQL = @SQL + N'Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End) '  
Set @SQL = @SQL + N'When ''UOM2'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), ' 
Set @SQL = @SQL + N'Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End)End,'
Set @SQL = @SQL + N'Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End Else 0 End) '
Set @SQL = @SQL + N'From ' + @ComparisonDB + N'..InvoiceAbstract,' + @ComparisonDB + N'..InvoiceDetail,'
Set @SQL = @SQL +  @ComparisonDB + N'..ItemCategories,' + @ComparisonDB + N'..Items,' + @ComparisonDB + N'..Customer '
Set @SQL = @SQL + N'Where ' + @ComparisonDB + N'..InvoiceAbstract.InvoiceID = ' + @ComparisonDB + N'..InvoiceDetail.InvoiceID '
Set @SQL = @SQL + N'And ' + @ComparisonDB + N'..InvoiceDetail.product_Code = ' + @ComparisonDB + N'..Items.Product_Code '
Set @SQL = @SQL + N'And ' + @ComparisonDB + N'..Items.CategoryID = ' + @ComparisonDB + N'..Itemcategories.CategoryID '
Set @SQL = @SQL + N'And ' + @ComparisonDB + N'..InvoiceAbstract.CustomerID = ' + @ComparisonDB + N'..Customer.CustomerID '
Set @SQL = @SQL + N'And InvoiceType in (1,2,3,4,5,6) '
Set @SQL = @SQL + N'And Status & 128 = 0 '
Set @SQL = @SQL + N'And ' + @ComparisonDB + N'..ItemCategories.CategoryID in (select CategoryID from #tempCategory) '
Set @SQL = @SQL + N'And ' + @ComparisonDB + N'..InvoiceAbstract.CustomerID in (select customerID from #tmpCust) '
Set @SQL = @SQL + N'And InvoiceDate Between ''' +  cast(@ComOpeningDate as nvarchar) + N'''' + N' And ' + N'''' + cast(@ComToDate as nvarchar)+ N''' '
Set @SQL = @SQL + N'Group By Company_Name, Category_Name,' + @ComparisonDB + N'..Items.Product_Code '

exec(@SQL)


select [Customer Name] As customerName, "Customer Name" = [Customer Name], "Product Category" = Category,"Sales Qty for the Comparitive Period" = Sum(CompQty),
"Sales Qty for the Reference Period" = Sum(RefQty),
"Growth(%)" = Case When (Sum(CompQty) + Sum(RefQty) = 0) Then 0
		   When (Sum(CompQty) = 0) Then 100
	           Else ((Sum(RefQty) - Sum(CompQty))/ Sum(CompQty)) * 100 End,
"Sales Value for the Comparative Period" = Sum(CompValue),
"Sales Value for the Reference Period" = Sum(RefValue),
"Growth(%)" = Case When (Sum(CompValue) + Sum(RefValue) = 0) Then 0
		   When (Sum(CompValue) = 0) Then 100
	           Else ((Sum(RefValue) - Sum(CompValue))/ Sum(CompValue)) * 100 End,
"Cumulative Sales Qty for the Comparitive Period" = Sum(CompCumQty),
"Cumulative Sales Qty for the Reference Period" = Sum(RefCumQty),
"Growth(%)" = Case When (Sum(CompCumQty) + Sum(RefCumQty) = 0) Then 0
		   When (Sum(CompCumQty) = 0) Then 100
	           Else ((Sum(RefCumQty) - Sum(CompCumQty))/ Sum(CompCumQty)) * 100 End,
"Cummulative Sales Value for the Comparitive Period" = Sum(CompCumValue),
"Cummulative Sales Value for the Reference Period" = Sum(RefCumValue),
"Growth(%)" = Case When (Sum(CompCumValue) + Sum(RefCumValue) = 0) Then 0
		   When (Sum(CompCumValue) = 0) Then 100
	           Else ((Sum(RefCumValue) - Sum(CompCumValue))/ Sum(CompCumValue)) * 100 End
from #tmpSalesDetails group by [Customer Name],Category Order by [Customer Name],Category

drop table #tempCategory
drop table #tmpCust
drop table #tmpSalesDetails

End

Else
select flag,status from #tmpValidations

drop table #tmpValidations
