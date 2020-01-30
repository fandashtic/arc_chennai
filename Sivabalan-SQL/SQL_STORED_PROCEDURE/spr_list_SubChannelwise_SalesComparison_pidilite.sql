CREATE Procedure [dbo].[spr_list_SubChannelwise_SalesComparison_pidilite]
	(    
		@RefFromDate DateTime,   
		@RefToDate DateTime,
		@ComFromDate DateTime,   
		@ComToDate DateTime,
		@Channel nVarchar(2550),           
		@SubChannel nVarchar(2550),  
		@Category nVarchar(510),
		@UOMdesc nVarchar(50)
	)  
AS  

	Declare @SQL nVarchar(4000)
	Declare @ComparisonDB nVarchar(200)
	Declare @ComOpeningDate Datetime
	Declare @RefOpeningDate Datetime
	Declare @Delimeter Char(1)
	Declare @Others nVarchar(100)

	Create Table #TmpValidations
	(
		Flag Int,
		Status nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
		CYTransDate Datetime,
		RYTransDate Datetime
	)

	-- Validate Comparative and Reference Dates 
	Exec sp_Validate_ComparisonParameters_Pidilite @RefFromDate,@RefToDate,@ComFromDate,@ComToDate
	
	If (Select Flag From #TmpValidations) = 1
	Begin
		Set @ComparisonDB = (Select Status From #TmpValidations)
		Set @ComOpeningDate = (Select CYTransDate From #TmpValidations)
		Set @RefOpeningDate = (Select RYTransDate From #TmpValidations)

		Create Table #TempCategory(CategoryID Int, Status Int)         
		Exec GetLeafCategories N'%', @Category

		Set @Delimeter = Char(15)
		Select @Others = dbo.LookupDictionaryItem(N'Others',Default)  
	
		Create table #TmpChannel(ChannelType Int)        
		Create table #TmpSubChannel(SubChannelID Int) 

		If @Channel = N'%'             
		Begin
		   Insert into #TmpChannel select ChannelType from customer_channel  
		   Insert into #TmpChannel (ChannelType) Values (0)        
		End
		Else        
		   Insert into #TmpChannel Select ChannelType from customer_Channel
			 where ChannelDesc in (select * from dbo.sp_SplitIn2Rows(@Channel,@Delimeter))  

		If @SubChannel = N'%'
		Begin
  		 Insert into #TmpSubChannel select SubChannelID from subchannel          
		   Insert into #TmpSubChannel (SubChannelID) Values (0)
		End
		Else        
  		 Insert into #TmpSubChannel Select SubChannelID from subchannel
			 where [Description] in (select * from dbo.sp_SplitIn2Rows(@SubChannel,@Delimeter)) 
    
		Create Table #TmpSalesDetails 
		(
 			[SubChannel Name] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	 		Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 			CompQty Decimal(18,6) Default 0,
 			RefQty Decimal(18,6) Default 0,
	 		CompValue Decimal(18,6) Default 0,
 			RefValue Decimal(18,6) Default 0,
 			CompCumQty Decimal(18,6) Default 0,
	 		RefCumQty Decimal(18,6) Default 0,
 			CompCumValue Decimal(18,6) Default 0 ,
 			RefCumValue Decimal(18,6) Default 0
		)  

		Insert Into #TmpSalesDetails([SubChannel Name],Category,RefCumQty,RefCumValue,RefQty,RefValue)
		Select Case IsNull(Customer.SubChannelID, 0) When 0 Then @Others Else SubChannel.[Description] End,Category_Name,
		Case @UOMDesc 
			When N'Sales UOM' Then Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End)
	    When N'UOM1' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(Max(UOM1_Conversion), 0) = 0 Then 1 Else Max(UOM1_Conversion) End)  
  	  When N'UOM2' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(Max(UOM2_Conversion), 0) = 0 Then 1 Else Max(UOM2_Conversion) End) 
	  End,
		Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End),
		Case @UOMDesc 
			When N'Sales UOM' Then Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End)
    	When N'UOM1' 
      Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), 
	  															 Case When IsNull(Max(UOM1_Conversion), 0) = 0 Then 1 Else Max(UOM1_Conversion) End)  
    	When N'UOM2' 
			Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), 
	  															Case When IsNull(Max(UOM2_Conversion), 0) = 0 Then 1 Else Max(UOM2_Conversion) End) End,
		Sum(Case When (InvoiceDate >= @RefFromDate) Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End Else 0 End)
		From 
				InvoiceAbstract
				Inner Join InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
				Inner Join Items on InvoiceDetail.product_Code = Items.Product_Code
				Inner Join ItemCategories on Items.CategoryID = Itemcategories.CategoryID
				Inner Join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID
				left Outer Join Customer_Channel on Isnull(Customer.ChannelType,0) = Customer_Channel.ChannelType
				Left Outer Join SubChannel on Isnull(Customer.SubChannelID,0) = SubChannel.SubChannelID
		Where 
				--InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
				--And InvoiceDetail.product_Code = Items.Product_Code
				--And Items.CategoryID = Itemcategories.CategoryID
				--And InvoiceAbstract.CustomerID = Customer.CustomerID
				--And Isnull(Customer.ChannelType,0) *= Customer_Channel.ChannelType
				--And Isnull(Customer.SubChannelID,0) *= SubChannel.SubChannelID
				--And 
				InvoiceType in (1,2,3,4,5,6)
				And Status & 128 = 0 
				And Isnull(Customer.ChannelType,0) in (select ChannelType from #TmpChannel)
				And Isnull(Customer.SubChannelID,0) in (select SubChannelID from #TmpSubChannel) 
				And ItemCategories.CategoryID in (select CategoryID from #TempCategory)
				And InvoiceDate Between @RefOpeningDate and @RefToDate
		Group By 
				Customer.SubChannelID,SubChannel.[Description],Category_Name,Items.Product_Code

		Set @SQL = N'insert into #TmpSalesDetails ([SubChannel Name],Category,CompCumQty,CompCumValue,CompQty,CompValue)'
		Set @SQL = @SQL + N'select case isnull(' + @ComparisonDB + N'..Customer.SubChannelID, 0) when 0 then ''' + @Others + ''' '  
		Set @SQL = @SQL + N'else ' + @ComparisonDB + N'..SubChannel.[Description] end, Category_Name,'
		Set @SQL = @SQL + N'Case ''' + @UOMdesc + N''' ' 
		Set @SQL = @SQL + N'When N''Sales UOM'' Then Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End) '   
		Set @SQL = @SQL + N'When N''UOM1'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(Max(UOM1_Conversion), 0) = 0 Then 1 Else Max(UOM1_Conversion) End) '               
		Set @SQL = @SQL + N'When N''UOM2'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End), Case When IsNull(Max(UOM2_Conversion), 0) = 0 Then 1 Else Max(UOM2_Conversion) End) End,'
		Set @SQL = @SQL + N'Sum(Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End),'
		Set @SQL = @SQL + N'Case ''' + @UOMDesc + ''' '
		Set @SQL = @SQL + N'When N''Sales UOM'' Then Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End) '
		Set @SQL = @SQL + N'When N''UOM1'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), ' 
		Set @SQL = @SQL + N'Case When IsNull(Max(UOM1_Conversion), 0) = 0 Then 1 Else Max(UOM1_Conversion) End) '  
		Set @SQL = @SQL + N'When N''UOM2'' Then dbo.sp_Get_ReportingQty(Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Quantity) Else (Quantity) End Else 0 End), ' 
		Set @SQL = @SQL + N'Case When IsNull(Max(UOM2_Conversion), 0) = 0 Then 1 Else Max(UOM2_Conversion) End)End,'
		Set @SQL = @SQL + N'Sum(Case When (InvoiceDate >=''' + Cast(@ComFromDate as nvarchar) + N''') Then Case When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Amount) Else (Amount) End Else 0 End) '
		Set @SQL = @SQL + N'From ' + @ComparisonDB + '..InvoiceAbstract ' 
		Set @SQL = @SQL + 'Inner Join ' + @ComparisonDB + N'..InvoiceDetail on '  + @ComparisonDB + '..InvoiceAbstract.InvoiceID = ' + @ComparisonDB + N'..InvoiceDetail.InvoiceID '
		Set @SQL = @SQL + 'Inner Join ' + @ComparisonDB + N'..Items on '  + @ComparisonDB + N'..InvoiceDetail.product_Code = ' + @ComparisonDB + N'..Items.Product_Code '
		Set @SQL = @SQL + 'Inner Join ' + @ComparisonDB + N'..ItemCategories on '  + @ComparisonDB + N'..Items.CategoryID = ' + @ComparisonDB + '..Itemcategories.CategoryID '
		Set @SQL = @SQL + 'Inner Join ' + @ComparisonDB + N'..Customer on '  + ''+ @ComparisonDB + N'..InvoiceAbstract.CustomerID =' + @ComparisonDB + N'..Customer.CustomerID '
		Set @SQL = @SQL + 'Left Outer Join ' + @ComparisonDB + N'..Customer_Channel on '  + 'Isnull('+ @ComparisonDB + N'..Customer.ChannelType,0) =' + @ComparisonDB + N'..Customer_Channel.ChannelType '
		Set @SQL = @SQL + 'Left Outer Join ' + @ComparisonDB + N'..SubChannel on '  + 'Isnull('+ @ComparisonDB + N'..Customer.SubChannelID,0) =' + @ComparisonDB + N'..SubChannel.SubChannelID '

		--Set @SQL = @SQL + N'From ' + @ComparisonDB + N'..InvoiceAbstract,' + @ComparisonDB + N'..InvoiceDetail,'
		--Set @SQL = @SQL +  @ComparisonDB + N'..ItemCategories,' + @ComparisonDB + N'..Items,' + @ComparisonDB + N'..Customer,' 
		--Set @SQL = @SQL +  @ComparisonDB + N'..Customer_Channel,' + @ComparisonDB + N'..SubChannel ' 
		--Set @SQL = @SQL + N'Where ' + @ComparisonDB + '..InvoiceAbstract.InvoiceID = ' + @ComparisonDB + N'..InvoiceDetail.InvoiceID '
		--Set @SQL = @SQL + N'And ' + @ComparisonDB + '..InvoiceDetail.product_Code = ' + @ComparisonDB + N'..Items.Product_Code '
		--Set @SQL = @SQL + N'And ' + @ComparisonDB + '..Items.CategoryID = ' + @ComparisonDB + N'..Itemcategories.CategoryID '
		--Set @SQL = @SQL + N'And ' + @ComparisonDB + '..InvoiceAbstract.CustomerID = ' + @ComparisonDB + N'..Customer.CustomerID '
		--Set @SQL = @SQL + N'And Isnull(' + @ComparisonDB + '..Customer.ChannelType,0) *= ' + @ComparisonDB + N'..Customer_Channel.ChannelType '
		--Set @SQL = @SQL + N'And Isnull(' + @ComparisonDB + N'..Customer.SubChannelID,0) *= ' + @ComparisonDB + N'..SubChannel.SubChannelID '
		Set @SQL = @SQL + N'Where InvoiceType in (1,2,3,4,5,6) '
		Set @SQL = @SQL + N'And Status & 128 = 0 '
		Set @SQL = @SQL + N'And Isnull(' + @ComparisonDB + N'..Customer.ChannelType,0) in (select ChannelType from #TmpChannel) '
		Set @SQL = @SQL + N'And Isnull(' + @ComparisonDB + N'..Customer.SubChannelID,0) in (select SubChannelID from #TmpSubChannel) ' 
		Set @SQL = @SQL + N'And ' + @ComparisonDB + '..ItemCategories.CategoryID in (select CategoryID from #TempCategory) '
		Set @SQL = @SQL + N'And InvoiceDate Between ''' +  cast(@ComOpeningDate as nvarchar) + '''' + N' And ' + N'''' + cast(@ComToDate as nvarchar)+ N''' '
		Set @SQL = @SQL + N'Group By ' + @ComparisonDB + N'..Customer.[SubChannelID],' + @ComparisonDB + N'..SubChannel.[Description],Category_Name,' + @ComparisonDB + N'..Items.Product_Code '

		Print @SQL

		exec(@SQL)

		select [SubChannel Name] As SubChannelName, [SubChannel Name], "Product Category" = Category,"Sales Qty for the Comparitive Period" = Sum(CompQty),
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
				[SubChannel Name],Category 
		Order by 
				[SubChannel Name],Category

		Drop table #TempCategory
		Drop table #TmpChannel
		Drop table #TmpSubChannel
		Drop table #tmpSalesDetails

	End

	Else
	Select flag,Status from #TmpValidations

	Drop table #TmpValidations
