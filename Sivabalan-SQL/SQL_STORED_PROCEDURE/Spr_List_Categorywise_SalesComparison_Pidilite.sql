CREATE Procedure Spr_List_Categorywise_SalesComparison_Pidilite  
(    
	@RefFromDate DateTime,   
	@RefToDate DateTime,
	@ComFromDate DateTime,   
	@ComToDate DateTime,
	@ProductHierarchy nVarChar(256),   
	@Category nVarChar(510),
	@UOMdesc nVarChar(50)
)  
As  

Declare @SQL nVarChar(4000)
Declare @ComparisonDB nVarChar(200)
Declare @ComOpenIngDate DateTime
Declare @RefOpenIngDate DateTime

Create Table #TmpValidations
(
	Flag Int,
	Status nVarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CYTransDate DateTime,
	RYTransDate DateTime
)


Exec sp_Validate_ComparisonParameters_Pidilite @RefFromDate,@RefToDate,@ComFromDate,@ComToDate

If (Select Flag From #TmpValidations) = 1
	Begin
		Set @ComparisonDB = (Select Status From #TmpValidations)
		Set @ComOpenIngDate = (Select CYTransDate From #TmpValidations)
		Set @RefOpenIngDate = (Select RYTransDate From #TmpValidations)
		
		Create Table #TempCategory(CategoryID Int, Status Int)         
		Exec GetLeafCategories @ProductHierarchy, @Category
		
		Create Table #TmpSalesDetails
		(
		 Category nVarChar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
		 CompQty Decimal(18,6) Default 0,
		 RefQty Decimal(18,6) Default 0,
		 CompValue Decimal(18,6) Default 0,
		 RefValue Decimal(18,6) Default 0,
		 CompCumQty Decimal(18,6) Default 0,RefCumQty Decimal(18,6) Default 0,
		 CompCumValue Decimal(18,6) Default 0 ,RefCumValue Decimal(18,6) Default 0
		)  
		
		Insert InTo #TmpSalesDetails(Category,RefCumQty,RefCumValue,RefQty,RefValue)
		Select
		 Category_Name,
			Case @UOMDesc
			 When N'Sales UOM' Then Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End)
		  When N'UOM1' Then dbo.sp_Get_ReportIngQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End)  
		  When N'UOM2' Then dbo.sp_Get_ReportIngQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End) 
		 End,
			Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End),
			Case @UOMDesc
				When N'Sales UOM' Then Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End)
				When N'UOM1' Then 
					dbo.sp_Get_ReportIngQty
						(
							Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End),
							Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End
						)  
				When N'UOM2' Then
				 dbo.sp_Get_ReportIngQty
						(
							Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End),
							Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End) 
			End,
			Sum
			(
				Case 
					When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End
					Else 0 
				End
			)
		From
		 InvoiceAbstract,InvoiceDetail,ItemCategories,Items
		Where
		 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
			And InvoiceDetail.product_Code = Items.Product_Code
			And Items.CategoryID = ItemCategories.CategoryID
			And InvoiceAbstract.InvoiceType In (1,2,3,4,5,6)
			And InvoiceAbstract.Status & 128 = 0 
			And ItemCategories.CategoryID In (Select CategoryID From #TempCategory)
			And InvoiceDate Between @RefOpenIngDate And @RefToDate
		Group By
		 Category_Name,Items.Product_Code
		Order By
		 Category_Name
		
		Set @SQL = N'Insert InTo #TmpSalesDetails (Category,CompCumQty,CompCumValue,CompQty,CompValue)'
		Set @SQL = @SQL + N'Select Category_Name,'
		Set @SQL = @SQL + N'Case ''' + @UOMdesc + ''' ' 
		Set @SQL = @SQL + N'When N''Sales UOM'' Then Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End) '   
		Set @SQL = @SQL + N'When N''UOM1'' Then dbo.sp_Get_ReportIngQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End) '               
		Set @SQL = @SQL + N'When N''UOM2'' Then dbo.sp_Get_ReportIngQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End) End,'
		Set @SQL = @SQL + N'Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End),'
		Set @SQL = @SQL + N'Case ''' + @UOMDesc + N''' '
		Set @SQL = @SQL + N'When N''Sales UOM'' Then Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nVarChar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End) '
		Set @SQL = @SQL + N'When N''UOM1'' Then dbo.sp_Get_ReportIngQty(Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nVarChar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), ' 
		Set @SQL = @SQL + N'Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End) '  
		Set @SQL = @SQL + N'When N''UOM2'' Then dbo.sp_Get_ReportIngQty(Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nVarChar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), ' 
		Set @SQL = @SQL + N'Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End)End,'
		Set @SQL = @SQL + N'Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nVarChar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End Else 0 End) '
		Set @SQL = @SQL + N'From ' + @ComparisonDB + '..InvoiceAbstract,' + @ComparisonDB + N'..InvoiceDetail,'
		Set @SQL = @SQL +  @ComparisonDB + N'..ItemCategories,' + @ComparisonDB + N'..Items '
		Set @SQL = @SQL + N'Where ' + @ComparisonDB + N'..InvoiceAbstract.InvoiceID = ' + @ComparisonDB +N'..InvoiceDetail.InvoiceID '
		Set @SQL = @SQL + N'And ' + @ComparisonDB + N'..InvoiceDetail.product_Code = ' + @ComparisonDB + N'..Items.Product_Code '
		Set @SQL = @SQL + N'And ' + @ComparisonDB + N'..Items.CategoryID = ' + @ComparisonDB + N'..ItemCategories.CategoryID '
		Set @SQL = @SQL + N'And InvoiceType In (1,2,3,4,5,6) '
		Set @SQL = @SQL + N'And InvoiceDate Between ''' +  cast(@ComOpenIngDate as nVarChar) + N'''' + N' And ' + N'''' + cast(@ComToDate as nVarChar)+ ''' '
		Set @SQL = @SQL + N'And Status & 128 = 0 '
		Set @SQL = @SQL + N'And ' + @ComparisonDB + N'..ItemCategories.CategoryID In (Select CategoryID From #TempCategory) '
		Set @SQL = @SQL + N'Group By Category_Name,' + @ComparisonDB + N'..Items.Product_Code '
		Set @SQL = @SQL + N'Order By Category_Name'
		
		Exec(@SQL)
		
		Select 
			1,"Product Category" = Category,
			"Sales Qty for the Comparitive Period" = Sum(CompQty),
			"Sales Qty for the Reference Period" = Sum(RefQty),
			"Growth(%)" = 
				Case
				 When (Sum(CompQty) + Sum(RefQty) = 0) Then 0
				 When (Sum(CompQty) = 0) Then 100
			  Else ((Sum(RefQty) - Sum(CompQty))/ Sum(CompQty)) * 100
				End,
			"Sales Value for the Comparative Period (%c)" = Sum(CompValue),
			"Sales Value for the Reference Period (%c)" = Sum(RefValue),
			"Growth(%)" = 
				Case
				 When (Sum(CompValue) + Sum(RefValue) = 0) Then 0
				 When (Sum(CompValue) = 0) Then 100
			  Else ((Sum(RefValue) - Sum(CompValue))/ Sum(CompValue)) * 100
			 End,
			"Cumulative Sales Qty for the Comparitive Period" = Sum(CompCumQty),
			"Cumulative Sales Qty for the Reference Period" = Sum(RefCumQty),
			"Growth(%)" =
				Case
				 When (Sum(CompCumQty) + Sum(RefCumQty) = 0) Then 0
				 When (Sum(CompCumQty) = 0) Then 100
			  Else ((Sum(RefCumQty) - Sum(CompCumQty))/ Sum(CompCumQty)) * 100 
				End,
			"Cummulative Sales Value for the Comparitive Period (%c)" = Sum(CompCumValue),
			"Cummulative Sales Value for the Reference Period (%c)" = Sum(RefCumValue),
			"Growth(%)" = 
				Case
				 When (Sum(CompCumValue) + Sum(RefCumValue) = 0) Then 0
				 When (Sum(CompCumValue) = 0) Then 100
		   Else ((Sum(RefCumValue) - Sum(CompCumValue))/ Sum(CompCumValue)) * 100
			 End
		From
			#TmpSalesDetails
		Group By
		 Category
	 Order By
		 Category
	Drop Table #TmpSalesDetails
	Drop Table #TempCategory
	End
Else
	Select Flag,Status From #TmpValidations

	Drop Table #TmpValidations

