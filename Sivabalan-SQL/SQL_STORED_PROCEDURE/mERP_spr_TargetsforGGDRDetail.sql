Create Procedure mERP_spr_TargetsforGGDRDetail(@Dtldata Nvarchar(Max))
As
Begin
	Set DateFormat DMY

	Declare @Params as Table (ID Int,ItemValue Nvarchar(256))
	Declare @MonthEnddate as DateTime

	Create Table #TmpItems (Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Sales Decimal(18,6))
	Create Table #TmpExItems (Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

	CREATE TABLE #TmpOut(
		[ProductCode] Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Product Description] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ProductLevel] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Target] Decimal(18, 6) NULL Default 0,
		[TargetUOM] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsExcluded] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Actual] Decimal(18, 6) NULL Default 0,
		FromDate dateTime Null,
		Todate dateTime Null)

		Declare @DSID As int
		Declare @DSType As Nvarchar(255)
		Declare @D_FromDate As Nvarchar(255)
		Declare @D_Todate As Nvarchar(255)
		Declare @CategoryGroup As Nvarchar(50)
		Declare @CustomerID As nvarchar(255)
		Declare @ProdDefnID As Int
		Declare @DSTypeId as Int
		Declare @TmpCatGroup as Table (GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

		Delete From @Params
		Insert Into @Params (ID,ItemValue)
		Select RowID,ItemValue from sp_SplitIn2Rows_WithID(@Dtldata,',')

		Set @DSID = (Select Cast(ItemValue as Int) From @Params Where ID = 1)
		Set @DSType = (Select ItemValue From @Params Where ID = 2)
		Set @D_FromDate = (Select ItemValue From @Params Where ID = 3)
		Set @D_Todate = (Select ItemValue From @Params Where ID = 4)
		Set @CategoryGroup = (Select ItemValue From @Params Where ID = 5)
		Set @CustomerID = (Select ItemValue From @Params Where ID = 6)
		Set @ProdDefnID = (Select Cast(ItemValue as Int) From @Params Where ID = 7)

		Set @D_FromDate = Cast(@D_FromDate as DateTime)
		Set @D_Todate = Cast(@D_Todate as DateTime)

		Set @MonthEnddate = (Select DateAdd(d,-1,dateAdd(m,1,@D_Todate)))
		Set @DSTypeId = (Select Top 1 DSTypeId From DSType_Master Where DSTypeValue = @DSType)

		If @CategoryGroup <> 'All'
		Begin
			Delete From @TmpCatGroup
			Insert Into @TmpCatGroup(GroupName) 
			Select @CategoryGroup 
		End
		Else
		Begin
			If (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 0
			Begin
				Delete From @TmpCatGroup
				Insert Into @TmpCatGroup(GroupName) 
				Select Distinct GroupName From ProductCategoryGroupAbstract Where GroupId in (
				Select Distinct GroupId from tbl_mERP_DSTypeCGMapping Where DSTypeId = @DSTypeId And isnull(Active,0) = 1)
				And Isnull(OCGType,0) = 0
			End
			Else
			Begin
				Delete From @TmpCatGroup
				Insert Into @TmpCatGroup(GroupName) 
				Select Distinct GroupName From ProductCategoryGroupAbstract Where GroupId in (
				Select Distinct GroupId from tbl_mERP_DSTypeCGMapping Where DSTypeId = @DSTypeId And isnull(Active,0) = 1)
				And Isnull(OCGType,0) = 1
			End
		End

	Insert Into #TmpOut
	select Products,Null,Isnull(ProdCatLevel,0),Target,
	(Case 
		When Isnull(TargetUOM,0) = 1 Then 'Base UOM'
		When Isnull(TargetUOM,0) = 2 Then 'UOM1'
		When Isnull(TargetUOM,0) = 3 Then 'UOM2'
		When Isnull(TargetUOM,0) = 4 Then 'Value' Else Null End),
	isnull(IsExcluded,0),
	Null,
	@D_FromDate,@D_Todate	
	From GGDRProduct 
	Where ProdDefnID = @ProdDefnID

	Update T Set T.[Product Description] = IC.Description from #TmpOut T,Itemcategories IC
	Where IC.Category_Name = T.ProductCode 
	And Isnull(T.ProductLevel,0) in (2,3,4)

	Update T Set T.[Product Description] = I.ProductName from #TmpOut T,Items I
	Where I.Product_Code = T.ProductCode 
	And Isnull(T.ProductLevel,0) in (5)

	Update #TmpOut Set [Product Description] = Null Where ProductCode = 'All'
	Truncate Table #TmpExItems
	Declare @Product as Nvarchar(4000)
	Declare @Level As Int
	Declare @UOM as Nvarchar(255)
	Declare @Actual as Decimal(18,6)
	Declare @A_Fromdate as dateTime
	Declare @A_Todate as dateTime
	Declare @Tmp as table (Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

--	If Not Exists(Select 'X' From Beat_Salesman Where CustomerId = @CustomerID And SalesManID = @DSID)
--	GoTo OUT

/* For Inculede Items */

	Declare Cur_Items Cursor for
	Select  ProductCode,ProductLevel,TargetUOM,FromDate,Todate From #TmpOut Where Isnull(IsExcluded,0) = 0
	Open Cur_Items
	Fetch from Cur_Items into @Product,@level,@UOM,@A_Fromdate,@A_ToDate
	While @@fetch_status =0
		Begin

			If @Product = 'All'
			Begin
				Truncate table #TmpItems
				Insert Into #TmpItems(Product_Code)
				Select Product_Code From TmpGGDRSKUDetails where ProdDefnID = @ProdDefnID  And CategoryGroup in (Select Distinct GroupName From @TmpCatGroup)
			End
			Else If @Product <> 'All'
			Begin
				If @level = 2
				Begin
					Delete From #TmpItems
					Insert Into #TmpItems(Product_Code)
					Select Product_Code From TmpGGDRSKUDetails where ProdDefnID = @ProdDefnID And Division = @Product
				End
				Else If @level = 3
				Begin
					Delete From #TmpItems
					Insert Into #TmpItems(Product_Code)
					Select Product_Code From TmpGGDRSKUDetails where ProdDefnID = @ProdDefnID And SubCategory = @Product
				End
				Else If @level = 4
				Begin
					Delete From #TmpItems
					Insert Into #TmpItems(Product_Code)
					Select Product_Code From TmpGGDRSKUDetails where ProdDefnID = @ProdDefnID And MarketSKU = @Product
				End
				Else If @level = 5
				Begin
					Delete From #TmpItems
					Insert Into #TmpItems(Product_Code)
					Select Product_Code From TmpGGDRSKUDetails where ProdDefnID = @ProdDefnID And Product_Code = @Product
				End
			End

			Insert Into @Tmp (Product_Code)
			Select Distinct Product_Code From #TmpItems
			Truncate Table #TmpItems
			Insert Into #TmpItems (Product_Code)
			Select Distinct Product_Code From @Tmp
			Delete From @Tmp

    		Update T Set Sales = T1.Actual From #TmpItems T,
			(Select  G.SystemSKU,
					Cast((Sum(Case 
						When @UOM = 'UOM1' Then (G.SalesVolume / Isnull(I.UOM1_Conversion,1))
						When @UOM = 'UOM2' Then (G.SalesVolume / Isnull(I.UOM2_Conversion,1))
						When @UOM = 'Base UOM' Then (G.SalesVolume)
						When @UOM = 'Value' Then (G.Salesvalue) 
					End)) as Decimal(18,6)) Actual
			from GGDRData G, #TmpItems TI,Items I	
			Where I.Product_Code = G.SystemSKU And TI.Product_Code = I.Product_Code 
			And InvoiceDate Between @A_Fromdate And @A_ToDate
			And RetailerCode = @CustomerID
			And DSID = @DSID
			And DSType = @DSType
			And G.ProdDefnId=@ProdDefnID
			Group By G.SystemSKU) T1
			Where T.Product_Code = T1.SystemSKU
			
			Set @Actual = (select Sum(Isnull(Sales,0)) from #TmpItems)

			Update #TmpOut Set Actual = @Actual 
			Where ProductCode = @Product And ProductLevel = @level And Isnull(IsExcluded,0) = 0

			Set @Actual = 0

			Fetch Next from Cur_Items into @Product,@level,@UOM,@A_Fromdate,@A_ToDate
		End
	Close Cur_Items
	Deallocate Cur_Items

	OUT:

	Select 	[ProductCode],[ProductCode],[Product Description],
		(Case
			When Isnull(ProductLevel,0) = 2 Then 'Division'
			When Isnull(ProductLevel,0) = 3 Then 'Sub Category'
			When Isnull(ProductLevel,0) = 4 Then 'MarketSKU'
			When Isnull(ProductLevel,0) = 5 Then 'SKU'
	 		When Isnull(ProductLevel,0) = 0 Then 'Overall' End ) [ProductLevel],
		[Target] ,
		[TargetUOM],
		(Case When isnull(IsExcluded,0) = 1 Then 'Yes' End)	[IsExcluded],
		isnull([Actual],0) as [Actual] from #TmpOut

	Drop Table #TmpOut
	Drop Table #TmpItems
	Drop Table #TmpExItems

End
