CREATE Procedure [dbo].[spr_list_Beatwise_SalesComparison_Pidilite]  
	(      
		@RefFromDate dateTime,     
		@RefToDate dateTime,  
		@ComFromDate dateTime,     
		@ComToDate dateTime,  
		@Beats nVarchar(2550),        
		@Category nvarchar(510),  
		@UOMdesc nvarchar(50)  
	)    
AS    

	Declare @SQL nvarchar(4000)  
	Declare @ComparisonDB nvarchar(200)  
	Declare @ComOpeningDate datetime  
	Declare @RefOpeningDate datetime  
	Declare @Delimeter char(1)
	Declare @Others nvarchar(100)

	Create Table #TmpValidations  
	(  
	Flag int,  
	Status nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	CYTransDate datetime,  
	RYTransDate datetime  
	)  
	  
	Exec sp_Validate_ComparisonParameters_Pidilite @RefFromDate,@RefToDate,@ComFromDate,@ComToDate  
	  
	If (Select Flag from #TmpValidations) = 1  
	Begin  
		Set @ComparisonDB = (Select Status from #TmpValidations)  
		Set @ComOpeningDate = (Select CYTransDate from #TmpValidations)  
		Set @RefOpeningDate = (Select RYTransDate from #TmpValidations)  
		  
		Create Table #TempCategory(CategoryID int, Status int)           
		Exec GetLeafCategories '%', @Category  
		  
		Set @Delimeter = Char(15)  
		Select @Others = dbo.LookupDictionaryItem(N'Others',Default)  
		  
		Create table #TmpBeat(BeatID Int)          
		    
		if @Beats = N'%'      
		Begin      
		   Insert into #TmpBeat Select BeatID from Beat  
		   Insert into #TmpBeat (BeatID) Values (0)          
		End  
		Else          
		   Insert into #TmpBeat Select BeatID From Beat Where Description In (Select * from dbo.sp_SplitIn2Rows(@Beats, @Delimeter))    
		    
		Create Table #TmpSalesDetails 
		(
			[Beat Name] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,   
		  Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
		  CompQty Decimal(18,6) default 0,
			RefQty Decimal(18,6) default 0,  
			CompValue Decimal(18,6) default 0,
			RefValue Decimal(18,6) default 0,  
			CompCumQty Decimal(18,6) default 0,
			RefCumQty Decimal(18,6) default 0,  
			CompCumValue Decimal(18,6) default 0,
			RefCumValue Decimal(18,6) default 0
		)    
		    
		Insert into #TmpSalesDetails([Beat Name],Category,RefCumQty,RefCumValue,RefQty,RefValue)  
		Select 
			case isnull(InvoiceAbstract.BeatID, 0) when 0 then @Others else Beat.[Description] end,
									Category_Name,  
			Case @UOMDesc When N'Sales UOM' Then Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End)  
		              	When N'UOM1' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Isnull(Quantity,0)) Else (Isnull(Quantity,0)) End), Case When IsNull(max(UOM1_Conversion), 0) = 0 Then 1 Else max(UOM1_Conversion) End)    
		              	When N'UOM2' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Isnull(Quantity,0)) Else (Isnull(Quantity,0)) End), Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End)   
		              	End,  
			Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End),  
			Case @UOMDesc When N'Sales UOM' Then Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End)  
		              When N'UOM1' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Isnull(Quantity,0)) Else (Isnull(Quantity,0)) End Else 0 End),   
		              Case When IsNull(max(UOM1_Conversion),0) = 0 Then 1 Else max(UOM1_Conversion) End)    
		              When N'UOM2' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Isnull(Quantity,0)) Else (Isnull(Quantity,0)) End Else 0 End),   
		              Case When IsNull(max(UOM2_Conversion), 0) = 0 Then 1 Else max(UOM2_Conversion) End)   
		              End,  
			Sum(Case When (InvoiceDate >= @RefFromDate)   
			Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Isnull(Amount,0)) Else (Isnull(Amount,0)) End  
			Else 0   
		End)  
		From 
			InvoiceAbstract
			Inner Join InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
			Inner Join Items on InvoiceDetail.product_Code = Items.Product_Code 
			Inner Join ItemCategories on Items.CategoryID = Itemcategories.CategoryID
			Left Outer Join Beat on InvoiceAbstract.BeatID = Beat.BeatID
		Where 
			--InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
			--And InvoiceDetail.product_Code = Items.Product_Code  
			--And Items.CategoryID = Itemcategories.CategoryID  
			--And InvoiceAbstract.BeatID *= Beat.BeatID  
			--And 
			InvoiceType in (1,2,3,4,5,6)  
			And Status & 128 = 0   
			And ItemCategories.CategoryID in (Select CategoryID from #TempCategory)  
			And InvoiceAbstract.BeatID in (Select BeatID from #TmpBeat)  
			And InvoiceDate Between @RefOpeningDate and @RefToDate  
		Group By 
			InvoiceAbstract.BeatID, Beat.[Description], Category_Name, Items.Product_Code  
		
		Set @SQL = N'insert into #TmpSalesDetails ([Beat Name],Category,CompCumQty,CompCumValue,CompQty,CompValue)'  
		Set @SQL = @SQL + N'Select case isnull(' + @ComparisonDB + N'..InvoiceAbstract.BeatID, 0) when 0 then ''' + @Others  + ''' '
		Set @SQL = @SQL + N'else ' + @ComparisonDB + N'..Beat.[Description] end ,Category_Name,'  
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
		Set @SQL = @SQL + N'From ' + @ComparisonDB + '..InvoiceAbstract ' 
		Set @SQL = @SQL + 'Inner Join ' + @ComparisonDB + N'..InvoiceDetail on '  + @ComparisonDB + '..InvoiceAbstract.InvoiceID = ' + @ComparisonDB + N'..InvoiceDetail.InvoiceID '
		Set @SQL = @SQL + 'Inner Join ' + @ComparisonDB + N'..Items on '  + @ComparisonDB + N'..InvoiceDetail.product_Code = ' + @ComparisonDB + N'..Items.Product_Code '
		Set @SQL = @SQL + 'Inner Join ' + @ComparisonDB + N'..ItemCategories on '  + @ComparisonDB + N'..Items.CategoryID = ' + @ComparisonDB + '..Itemcategories.CategoryID '
		Set @SQL = @SQL + 'Left Outer Join ' + @ComparisonDB + N'..Beat on '  + 'Isnull('+ @ComparisonDB + N'..InvoiceAbstract.BeatID,0) =' + @ComparisonDB + N'..Beat.BeatID '

		--Set @SQL = @SQL + N'From ' + @ComparisonDB + '..InvoiceAbstract,' + @ComparisonDB + N'..InvoiceDetail,'  
		--Set @SQL = @SQL +  @ComparisonDB + '..ItemCategories,' + @ComparisonDB + N'..Items,' + @ComparisonDB + N'..Beat '  
		--Set @SQL = @SQL + N'Where ' + @ComparisonDB + '..InvoiceAbstract.InvoiceID = ' + @ComparisonDB + N'..InvoiceDetail.InvoiceID '  
		--Set @SQL = @SQL + N'And ' + @ComparisonDB + '..InvoiceDetail.product_Code = ' + @ComparisonDB + N'..Items.Product_Code '  
		--Set @SQL = @SQL + N'And ' + @ComparisonDB + '..Items.CategoryID = ' + @ComparisonDB + N'..Itemcategories.CategoryID '  
		--Set @SQL = @SQL + N'And ' + @ComparisonDB + '..InvoiceAbstract.BeatID *= ' + @ComparisonDB + N'..Beat.BeatID '  
		Set @SQL = @SQL + N'Where InvoiceType in (1,2,3,4,5,6) '  
		Set @SQL = @SQL + N'And Status & 128 = 0 '  
		Set @SQL = @SQL + N'And ' + @ComparisonDB + N'..ItemCategories.CategoryID in (Select CategoryID from #TempCategory) '  
		Set @SQL = @SQL + N'And ' + @ComparisonDB + N'..InvoiceAbstract.BeatID in (Select BeatID from #TmpBeat) '  
		Set @SQL = @SQL + N'And InvoiceDate Between ''' +  cast(@ComOpeningDate as nvarchar) + N'''' + N' And ' + N'''' + cast(@ComToDate as nvarchar)+ N''' '  
		Set @SQL = @SQL + N'Group By ' + @ComparisonDB + N'..InvoiceAbstract.BeatID,' + @ComparisonDB + N'..Beat.Description, Category_Name,' + @ComparisonDB + N'..Items.Product_Code '  
		  
		Exec(@SQL)  
		  
		Select [Beat Name] As BeatName, "Beat Name" = [Beat Name], "Product Category" = Category,"Sales Qty for the Comparitive Period" = Sum(CompQty),  
		"Sales Qty for the Reference Period" = Sum(RefQty),  
		"Growth(%)" = 
				Case When (Sum(CompQty) + Sum(RefQty) = 0) Then 0  
		     		 When (Sum(CompQty) = 0) Then 100  
		         Else ((Sum(RefQty) - Sum(CompQty))/ Sum(CompQty)) * 100 
				End,  
		"Sales Value for the Comparative Period (%c)" = Sum(CompValue),  
		"Sales Value for the Reference Period (%c)" = Sum(RefValue),  
		"Growth(%)" = 
				Case When (Sum(CompValue) + Sum(RefValue) = 0) Then 0  
		         When (Sum(CompValue) = 0) Then 100  
		         Else ((Sum(RefValue) - Sum(CompValue))/ Sum(CompValue)) * 100 
				End,  
		"Cumulative Sales Qty for the Comparitive Period" = Sum(CompCumQty),  
		"Cumulative Sales Qty for the Reference Period" = Sum(RefCumQty),  
		"Growth(%)" = 
				Case When (Sum(CompCumQty) + Sum(RefCumQty) = 0) Then 0  
		         When (Sum(CompCumQty) = 0) Then 100  
		         Else ((Sum(RefCumQty) - Sum(CompCumQty))/ Sum(CompCumQty)) * 100 
				End,  
		"Cummulative Sales Value for the Comparitive Period (%c)" = Sum(CompCumValue),  
		"Cummulative Sales Value for the Reference Period (%c)" = Sum(RefCumValue),  
		"Growth(%)" = 
				Case When (Sum(CompCumValue) + Sum(RefCumValue) = 0) Then 0  
		         When (Sum(CompCumValue) = 0) Then 100  
		         Else ((Sum(RefCumValue) - Sum(CompCumValue))/ Sum(CompCumValue)) * 100 
				End  
		From 
			#TmpSalesDetails 
		Group by 
			[Beat Name],Category 
		Order by 
			[Beat Name],Category  
		  
		drop table #TempCategory  
		drop table #TmpBeat  
		drop table #TmpSalesDetails  		
	End  
	  
	Else  
	Select flag,Status from #TmpValidations  
	  
	drop table #TmpValidations  
	
