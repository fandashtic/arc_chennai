CREATE Procedure spr_list_Itemwise_SalesComparison_pidilite  
(    
	@RefFromDate dateTime,   
	@RefToDate dateTime,
	@ComFromDate dateTime,   
	@ComToDate dateTime,
	@Product_Code nvarchar(2550),         
	@UOMdesc nvarchar(50)
)  
AS  

Declare @SQL nvarchar(4000)
Declare @ComparisonDB nvarchar(200)
Declare @ComOpeningDate datetime
Declare @RefOpeningDate datetime
Declare @Delimeter as char(1)

Create Table #tmpValidations
(
	Flag int,
	Status nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CYTransDate datetime,
	RYTransDate datetime
)

Exec sp_Validate_ComparisonParameters_Pidilite @RefFromDate,@RefToDate,@ComFromDate,@ComToDate

If (select Flag from #tmpValidations) = 1
	Begin
		Set @ComparisonDB = (select Status from #tmpValidations)
		Set @ComOpeningDate = (select CYTransDate from #tmpValidations)
		Set @RefOpeningDate = (select RYTransDate from #tmpValidations)

		Create table #tmpItem(ProductCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)   

		Set @Delimeter = Char(15)

		if @Product_Code=N'%'          
  		Insert into #tmpItem select product_code from Items          
		Else          
   Insert into #tmpItem select * from dbo.sp_SplitIn2Rows(@Product_Code,@Delimeter)          
              
		Create Table #tmpSalesDetails (ProductName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, 
			       CompQty Decimal(18,6) default 0,RefQty Decimal(18,6) default 0,
			       CompValue Decimal(18,6) default 0,RefValue Decimal(18,6) default 0,
			       CompCumQty Decimal(18,6) default 0,RefCumQty Decimal(18,6) default 0,
			       CompCumValue Decimal(18,6) default 0 ,RefCumValue Decimal(18,6) default 0)  

		insert into #tmpSalesDetails(ProductName,RefCumQty,RefCumValue,RefQty,RefValue)
		select ProductName,
		Case @UOMDesc When N'Sales UOM' Then Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End)
  		            When N'UOM1' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End)  
    		          When N'UOM2' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End) 
      		        End,
		Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End),
Case @UOMDesc When N'Sales UOM' Then Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End)
              When N'UOM1' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), 
              Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End)  
              When N'UOM2' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), 
              Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End) 
              End,
Sum(Case When (InvoiceDate >= @RefFromDate) 
Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End
Else 0 
End)
From InvoiceAbstract,InvoiceDetail,Items
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
And InvoiceDetail.Product_Code = Items.Product_Code
And InvoiceType in (1,2,3,4,5,6)
And Status & 128 = 0 
And InvoiceDetail.Product_Code in (select Productcode from #tmpItem)
And InvoiceDate Between @RefOpeningDate and @RefToDate
Group By ProductName 				
				

Set @SQL = N'insert into #tmpSalesDetails (ProductName,CompCumQty,CompCumValue,CompQty,CompValue)'
Set @SQL = @SQL + N'select ProductName,'
Set @SQL = @SQL + N'Case ''' + @UOMdesc + N''' ' 
Set @SQL = @SQL + N'When N''Sales UOM'' Then Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End) '   
Set @SQL = @SQL + N'When N''UOM1'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End) '               
Set @SQL = @SQL + N'When N''UOM2'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End) End,'
Set @SQL = @SQL + N'Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End),'
Set @SQL = @SQL + N'Case ''' + @UOMDesc + N''' '
Set @SQL = @SQL + N'When N''Sales UOM'' Then Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End) '
Set @SQL = @SQL + N'When N''UOM1'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), ' 
Set @SQL = @SQL + N'Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End) '  
Set @SQL = @SQL + N'When N''UOM2'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), ' 
Set @SQL = @SQL + N'Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End)End,'
Set @SQL = @SQL + N'Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End Else 0 End) '
Set @SQL = @SQL + N'From ' + @ComparisonDB + '..InvoiceAbstract,' + @ComparisonDB + N'..InvoiceDetail,'
Set @SQL = @SQL +  @ComparisonDB +N'..Items '
Set @SQL = @SQL + N'Where ' + @ComparisonDB + '..InvoiceAbstract.InvoiceID = ' + @ComparisonDB + N'..InvoiceDetail.InvoiceID '
Set @SQL = @SQL + N'and ' + @ComparisonDB + N'..InvoiceDetail.product_Code = ' + @ComparisonDB + N'..Items.Product_Code '
Set @SQL = @SQL + N'and InvoiceType in (1,2,3,4,5,6) '
Set @SQL = @SQL + N'and Status & 128 = 0 '
Set @SQL = @SQL + N'and ' + @ComparisonDB + N'..InvoiceDetail.Product_Code in (select Productcode from #tmpItem) '
Set @SQL = @SQL + N'and InvoiceDate Between ''' +  cast(@ComOpeningDate as nvarchar) + N'''' + ' and ' + N'''' + cast(@ComToDate as nvarchar)+ ''' '
Set @SQL = @SQL + N'Group By ProductName' 

exec(@SQL)

select ProductName, "Item Name" = ProductName, "Sales Qty for the Comparitive Period" = Sum(CompQty),
"Sales Qty for the Reference Period" = Sum(RefQty),
"Growth(%)" = Case When (Sum(CompQty) + Sum(RefQty) = 0) Then 0
		   														When (Sum(CompQty) = 0) Then 100
								           Else ((Sum(RefQty) - Sum(CompQty))/ Sum(CompQty)) * 100 End,
"Sales Value for the Comparative Period (%c)" = Sum(CompValue),
"Sales Value for the Reference Period (%c)" = Sum(RefValue),
"Growth(%)" = Case When (Sum(CompValue) + Sum(RefValue) = 0) Then 0
																   When (Sum(CompValue) = 0) Then 100
									          Else ((Sum(RefValue) - Sum(CompValue))/ Sum(CompValue)) * 100 End,
"Cumulative Sales Qty for the Comparitive Period " = Sum(CompCumQty),
"Cumulative Sales Qty for the Reference Period " = Sum(RefCumQty),
"Growth(%)" = Case When (Sum(CompCumQty) + Sum(RefCumQty) = 0) Then 0
																   When (Sum(CompCumQty) = 0) Then 100
								           Else ((Sum(RefCumQty) - Sum(CompCumQty))/ Sum(CompCumQty)) * 100 End,
"Cummulative Sales Value for the Comparitive Period (%c)" = Sum(CompCumValue),
"Cummulative Sales Value for the Reference Period (%c)" = Sum(RefCumValue),
"Growth(%)" = Case When (Sum(CompCumValue) + Sum(RefCumValue) = 0) Then 0
		   														When (Sum(CompCumValue) = 0) Then 100
	           							Else ((Sum(RefCumValue) - Sum(CompCumValue))/ Sum(CompCumValue)) * 100 End

from #tmpSalesDetails group by ProductName Order by ProductName

drop table #tmpItem
drop table #tmpSalesDetails

End

Else
select flag,Status from #tmpValidations

drop table #tmpValidations

