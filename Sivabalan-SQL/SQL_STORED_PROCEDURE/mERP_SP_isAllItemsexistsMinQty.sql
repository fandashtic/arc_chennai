Create Procedure mERP_SP_isAllItemsexistsMinQty
@SchemeID int, @AllProdwithUOM nvarchar(max)
AS
BEGIN
	Create Table #InvoiceProdAndUOM(Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemValue Decimal(18,6),Qty decimal(18,6),
	UOM1Qty decimal(18,6),UOM2Qty decimal(18,6))

	Create Table #ConsolidatedTable(Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemValue Decimal(18,6),Qty decimal(18,6),
	UOM1Qty decimal(18,6),UOM2Qty decimal(18,6),Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	MarketSKU nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Create Table #InvoiceItems(ProductAndUOM nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Create Table #TempMinSKU(SchemeID int,Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Min_Range decimal(18,6),UOM int,Category nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,CATEGORY_LEVEL int,isSalesmade int not null default 0)
	
	If (Select isnull(isminqty,0) from tbl_merp_schemeabstract where schemeid=@SchemeID)=1
	Begin
		Declare @Final Table (Result int)
		
		Insert into #InvoiceItems(ProductAndUOM) Select * From dbo.sp_splitIn2Rows(@AllProdwithUOM,'|')

		Declare @PDetails nvarchar(4000)
		Declare AllProd Cursor For Select ProductAndUOM from #InvoiceItems
		Open AllProd 
		Fetch From AllProd into @PDetails
		While @@Fetch_status=0
		Begin
			Insert into #InvoiceProdAndUOM(Product_code,ItemValue,Qty,UOM1Qty,UOM2Qty)
			Select FirstValue,cast(ThirdValue as decimal(18,6)),cast(SecondValue as decimal(18,6)),cast(SecondValue as decimal(18,6)) / (Select IsNull(UOM1_Conversion,1) From Items Where Product_Code = T.FirstValue),
			cast(SecondValue as decimal(18,6)) / (Select IsNull(UOM2_Conversion,1) From Items Where Product_Code = T.FirstValue)	 
			from dbo.fn_splitintocolumns(@PDetails) T
			Fetch Next From AllProd into @PDetails
		End
		Close AllProd
		Deallocate AllProd

		Insert into #ConsolidatedTable(Product_code, ItemValue,Qty,UOM1Qty,UOM2Qty)
		Select Product_code,sum(ItemValue),sum(Qty),sum(UOM1Qty),sum(UOM2Qty)
		From #InvoiceProdAndUOM Group by Product_code

		/* To update Category Level Details*/
		Update Temp set Division=IC3.Category_Name, SubCategory=IC2.Category_Name, MarketSKU=IC1.Category_Name
		From ItemCategories IC1, ItemCategories IC2, ItemCategories IC3,
		Items I,#ConsolidatedTable Temp
		Where IC3.CategoryID = IC2.ParentID 
		And IC2.CategoryID = IC1.ParentID 
		And IC1.CategoryID = I.CategoryID
		And I.Product_code=Temp.Product_code

		/* Data from SchMinQty Table */
		Insert into #TempMinSKU(SchemeID,Product_code,Min_Range,UOM,Category,CATEGORY_LEVEL)
		Select @SchemeID,Product_code,Min_Range,UOM,Category,CATEGORY_LEVEL from dbo.mERP_fn_Get_CSProductminrange(@SchemeID)
--		where Product_code in (select distinct Product_code from #ConsolidatedTable)
		
		update #TempMinSKU set isSalesmade=1 where product_code in (Select product_code from #ConsolidatedTable)

		Declare @Product_code nvarchar(255)
		Declare @Min_Range Decimal(18,6)
		Declare @UOM Int
		Declare @Category nvarchar(255)
		Declare @CATEGORY_LEVEL Int



		Declare AllMinSKU cursor For Select Product_code,Min_Range,UOM,Category,CATEGORY_LEVEL from #TempMinSKU where SchemeID= @SchemeID and isSalesmade=1 Order by CATEGORY_LEVEL
		Open AllMinSKU
		Fetch from AllMinSKU into @Product_code,@Min_Range,@UOM,@Category,@CATEGORY_LEVEL
		While @@Fetch_status=0
		Begin
			--Even If one single entry is invalid, exit from the loop and dont allow scheme to apply
			IF (Select count(*) from  @Final)>=1 
			Break
			--Division
			If @CATEGORY_LEVEL = 2
			Begin
				--Base UOM
				If @UOM=1
				Begin
					If (Select sum(Qty) from #ConsolidatedTable where Division=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--UOM1
				Else If @UOM=2
				Begin
					If (Select sum(UOM1Qty) from #ConsolidatedTable where Division=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--UOM2
				Else If @UOM=3
				Begin
					If (Select sum(UOM2Qty) from #ConsolidatedTable where Division=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--Value
				If @UOM=4
				Begin
					If (Select sum(ItemValue) from #ConsolidatedTable where Division=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
			End
			--Sub Category
			Else If @CATEGORY_LEVEL = 3
			Begin	
				--Base UOM
				If @UOM=1
				Begin

					If (Select sum(Qty) from #ConsolidatedTable where SubCategory=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--UOM1
				Else If @UOM=2
				Begin
					If (Select sum(UOM1Qty) from #ConsolidatedTable where SubCategory=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--UOM2
				Else If @UOM=3
				Begin
					If (Select sum(UOM2Qty) from #ConsolidatedTable where SubCategory=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--Value
				If @UOM=4
				Begin
					If (Select sum(ItemValue) from #ConsolidatedTable where SubCategory=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
			End
			--Market SKU
			Else If @CATEGORY_LEVEL = 4
			Begin
				--Base UOM
				If @UOM=1
				Begin
					If (Select sum(Qty) from #ConsolidatedTable where MarketSKU=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--UOM1
				Else If @UOM=2
				Begin
					If (Select sum(UOM1Qty) from #ConsolidatedTable where MarketSKU=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--UOM2
				Else If @UOM=3
				Begin
					If (Select sum(UOM2Qty) from #ConsolidatedTable where MarketSKU=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--Value
				If @UOM=4
				Begin
					If (Select sum(ItemValue) from #ConsolidatedTable where MarketSKU=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Category=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
			End
			--System SKU
			Else If @CATEGORY_LEVEL = 5
			Begin
				--Base UOM
				If @UOM=1
				Begin
					If (Select sum(Qty) from #ConsolidatedTable where Product_code=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Product_code=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--UOM1
				Else If @UOM=2
				Begin
					If (Select sum(UOM1Qty) from #ConsolidatedTable where Product_code=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Product_code=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--UOM2
				Else If @UOM=3
				Begin
					If (Select sum(UOM2Qty) from #ConsolidatedTable where Product_code=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Product_code=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
				--Value
				If @UOM=4
				Begin
					If (Select sum(ItemValue) from #ConsolidatedTable where Product_code=@Category) <(Select Max(isnull(@Min_Range,0)) from #TempMinSKU where Product_code=@Category and isSalesmade=1)
						Insert into @Final Select 0
				End
			End
			Fetch Next from AllMinSKU into @Product_code,@Min_Range,@UOM,@Category,@CATEGORY_LEVEL
		End
		Close AllMinSKU
		Deallocate AllMinSKU
		/* @Final Table will have invalid entries.
			If it has a row, dont allow to apply scheme*/		
		IF (Select count(*) from  @Final)>=1 
			Select 0
		Else
		Begin
			/* If items are present in SchMinQty table but not invoiced then dont allow that */
			If exists (Select 'x' from dbo.mERP_fn_Get_CSProductminrange(@SchemeID)
			where Category_LEVEL=5 and Product_Code not in (select Product_Code from #ConsolidatedTable))
			Begin
				Select 0
			End
			Else
				Delete from @Final
				/* To check whether all categories mentioned in SchMinQty are available in invoice*/
				Declare @Cat nvarchar(255)
				Declare @CatLevel int
				Declare AllMin Cursor For Select Category,Category_level from SchMinQty where schemeid=@SchemeID and Category_level<>5
				Open AllMin
				Fetch from AllMin into @Cat,@CatLevel
				While @@Fetch_status=0
				Begin
					--Even If one single entry is invalid, exit from the loop and dont allow scheme to apply
					IF (Select count(*) from  @Final)>=1 
					break
					If (Select count(*) from #TempMinSKU where Category=@Cat and issalesmade=1)=0
					Insert into @Final Select 0
					Fetch next from AllMin into @Cat,@CatLevel
				End
				Close AllMin
				Deallocate Allmin
				IF (Select count(*) from  @Final)>=1 
					Select 0
				Else
					Select 1
		End
	End
	Else
		Select 1

Drop Table #ConsolidatedTable
Drop Table #TempMinSKU
Drop Table #InvoiceItems
Drop Table #InvoiceProdAndUOM
END
