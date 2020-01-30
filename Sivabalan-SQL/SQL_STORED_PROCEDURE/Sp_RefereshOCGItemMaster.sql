Create Procedure Sp_RefereshOCGItemMaster
As
BEGIN

/*To make all categories with proper product hierarchy level */
exec sp_update_categories

	Create table #tmpOUT (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		ProductName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		CategoryID Int,GroupID Int)

	Create table #Group (GroupID Int
		,GroupName Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
		,GroupCode Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Create table #tmpSKU (
		GroupID Int,
		CategoryID Int,
		DSType Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		OCGName Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		SKU Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Exclusion Int)

	Create table #FinalSKU (
		GroupID Int,
		CategoryID Int,
		DSType Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		OCGName Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		SKU Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Exclusion Int)


	Create table #tmpData (
		GroupID Int,
		OCGCode Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		ProductCategoryName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Level Int,
		Exclusion Int )

	Insert Into #Group (GroupID,GroupName,GroupCode)
	Select Distinct GroupID,GroupName,GroupCode from ProductCategoryGroupAbstract 
	Where --Isnull(OCGType,0) = 1 And
	Active = 1			

	Insert Into #tmpData
	Select G.GroupID,P.OCGCode,P.ProductCategoryName,P.Level,P.Exclusion 
	From OCG_Product P, #Group G
	Where P.OCGCode = G.GroupName

	Declare @DSType as Nvarchar(50)
	Declare @OCGCode as Nvarchar(50)
	Declare @OCG as Nvarchar(50)
	Declare @ProductCategoryName as Nvarchar(255)
	Declare @Level as Int
	Declare @GroupID as Int
	Declare @Exclusion as Int


	Declare @Cur_OCG Cursor 
	Set @Cur_OCG = Cursor for
	select Distinct OCGCode from #tmpData
	Open @Cur_OCG
	Fetch Next from @Cur_OCG into @OCG
	While @@fetch_status =0
		Begin
			Declare @Cur_SKU Cursor 
			Set @Cur_SKU = Cursor for
			select GroupID,OCGCode,ProductCategoryName,Level,Exclusion from #tmpData Where OCGCode = @OCG Order By Level Asc
			Open @Cur_SKU
			Fetch Next from @Cur_SKU into @GroupID,@OCGCode,@ProductCategoryName,@Level,@Exclusion
			While @@fetch_status =0
				Begin
	
					If @Level = 5
						Begin
							IF Not Exists(Select * from Items Where Product_Code = @ProductCategoryName)
							Begin
								Goto SkipROW
							End
							If Exists(select * from #tmpSKU Where SKU = @ProductCategoryName And OCGName = @OCG)
							Begin
								Update #tmpSKU set Exclusion = @Exclusion Where SKU = @ProductCategoryName And OCGName = @OCG
							End
							Else
							Begin
								Insert Into #tmpSKU (GroupID,OCGName,SKU,Exclusion)
								Select @GroupID,@OCGCode,@ProductCategoryName,@Exclusion
							End
						End

					If @Level = 4
						Begin
							IF Not Exists(Select * from ItemCategories Where Category_Name = @ProductCategoryName And level = 4)
							Begin
								Goto SkipROW
							End
							Update T set T.Exclusion = T1.Exclusion From #tmpSKU T,
							(select Distinct I.Product_code,@Exclusion Exclusion
							from items I ,ItemCategories IC4 where
							IC4.categoryid = i.categoryid 
							And IC4.Category_Name = @ProductCategoryName) T1
							Where T.SKU = T1.Product_code
							And T.OCGName = @OCG

							Insert Into #tmpSKU (GroupID,OCGName,SKU,Exclusion)
							select Distinct @GroupID,@OCGCode,I.Product_code,@Exclusion
							from items I ,ItemCategories IC4 where
							IC4.categoryid = i.categoryid 
							And IC4.Category_Name = @ProductCategoryName
							And I.Product_code Not in (Select Distinct SKU From #tmpSKU Where OCGName = @OCG)
						End

					If @Level = 3
						Begin
							IF Not Exists(Select * from ItemCategories Where Category_Name = @ProductCategoryName And level = 3)
							Begin
								Goto SkipROW
							End
							Update T set T.Exclusion = T1.Exclusion,GroupID = @GroupID From #tmpSKU T,
							(select Distinct I.Product_code,@Exclusion Exclusion
							from items I ,ItemCategories IC4,ItemCategories IC3 where
							IC4.categoryid = i.categoryid 
							And IC4.Parentid = IC3.categoryid 
							And IC3.Category_Name = @ProductCategoryName) T1
							Where T.SKU = T1.Product_code
							And T.OCGName = @OCG

							Insert Into #tmpSKU (GroupID,OCGName,SKU,Exclusion)
							select Distinct @GroupID,@OCGCode,I.Product_code,@Exclusion
							from items I ,ItemCategories IC4,ItemCategories IC3 where
							IC4.categoryid = i.categoryid 
							And IC4.Parentid = IC3.categoryid 
							And IC3.Category_Name = @ProductCategoryName
							And I.Product_code Not in (Select Distinct SKU From #tmpSKU Where OCGName = @OCG)
						End

					If @Level = 2
						Begin
							IF Not Exists(Select * from ItemCategories Where Category_Name = @ProductCategoryName And level = 2)
							Begin
								Goto SkipROW
							End
							Update T set T.Exclusion = T1.Exclusion,GroupID = @GroupID From #tmpSKU T,
							(select Distinct I.Product_code,@Exclusion Exclusion
							from items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 where
							IC4.categoryid = i.categoryid 
							And IC4.Parentid = IC3.categoryid 
							And IC3.Parentid = IC2.categoryid 
							And IC2.Category_Name = @ProductCategoryName) T1
							Where T.SKU = T1.Product_code
							And T.OCGName = @OCG

							Insert Into #tmpSKU (GroupID,OCGName,SKU,Exclusion)
							select Distinct @GroupID,@OCGCode,I.Product_code,@Exclusion
							from items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 where
							IC4.categoryid = i.categoryid 
							And IC4.Parentid = IC3.categoryid 
							And IC3.Parentid = IC2.categoryid 
							And IC2.Category_Name = @ProductCategoryName
							And I.Product_code Not in (Select Distinct SKU From #tmpSKU Where OCGName = @OCG)
						End
SkipROW:
				Fetch Next from @Cur_SKU into @GroupID,@OCGCode,@ProductCategoryName,@Level,@Exclusion
				End
			Close @Cur_SKU
			Deallocate @Cur_SKU

		Fetch Next from @Cur_OCG into @OCG
		End
	Close @Cur_OCG
	Deallocate @Cur_OCG

	Insert into #FinalSKU
	Select Distinct * from #tmpSKU

	Truncate Table OCGItemMaster
	Insert Into OCGItemMaster (GroupName,Division,SubCategory,MarketSKU,SystemSKU,Exclusion)
	Select Distinct T.OCGName, IC2.Category_Name,IC3.Category_Name,IC4.Category_Name,T.SKU,T.Exclusion 
	From #FinalSKU T,ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2,Items I
	Where T.SKU = I.Product_code 
	And IC4.categoryid = I.categoryid 
	And IC4.ParentId = IC3.categoryid 
	And IC3.ParentId = IC2.categoryid
	Order By T.OCGName, IC2.Category_Name,IC3.Category_Name,IC4.Category_Name,T.SKU,T.Exclusion
	
	Drop Table #tmpOUT
	Drop Table #tmpSKU
	Drop Table #FinalSKU
	Drop Table #tmpData
	Drop Table #Group

	--DSType Category Mapping Dataposting
	Exec sp_DSTypeWiseSKU_DataPost
	
End
