--Create Procedure Sp_GetGGDRProductList(@TmpProdDefnID As Nvarchar(4000))
Create Procedure Sp_GetGGDRProductList(@TmpProdDefnID As Integer)
As
Begin
	Set DateFormat DMY

	Declare @ProdDefnIDList as table (ProdDefnID Int)
	Declare @TmpItems As Table (ProdDefnID Int,Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Sales Decimal(18,6),C_Actual Decimal(18,6))
	Declare @TmpExItems As Table (ProdDefnID Int,Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Declare @Product as Nvarchar(4000)
	Declare @Level As Int
	Declare @ProdDefnID As Int

	Insert Into @ProdDefnIDList (ProdDefnID)
	Select ItemValue from sp_SplitIn2Rows(@TmpProdDefnID,',')

	Declare @TmpGGDRProductList as table (
			[ProdDefnID] Int,
			[Products] Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[Level] Int,
			[IsExcluded] Int)

	Insert Into @TmpGGDRProductList 
	Select ProdDefnID,Products,ProdCatLevel,IsExcluded From GGDRProduct Where ProdDefnID in (select Distinct ProdDefnID From @ProdDefnIDList)

	Delete From TmpGGDRSKUDetails Where ProdDefnID In (select Distinct ProdDefnID From @ProdDefnIDList)
	Create Table #tmpProd(Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)
	/* For Exculded Items */

		Declare Cur_ExItems Cursor for
		Select ProdDefnID,Products,Level From @TmpGGDRProductList Where Isnull(IsExcluded,0) = 1
		Open Cur_ExItems
		Fetch from Cur_ExItems into @ProdDefnID,@Product,@level
		While @@fetch_status =0
			Begin
				Insert Into @TmpExItems(ProdDefnID,Product_Code)
				Select @ProdDefnID,Product_Code From dbo.Fn_GetLeastLevelSKU(@Product,@level)

				Fetch Next from Cur_ExItems into @ProdDefnID,@Product,@level
			End
		Close Cur_ExItems
		Deallocate Cur_ExItems

	/* For Inculded Items */

		Declare Cur_Items Cursor for
		Select  ProdDefnID,Products,Level From @TmpGGDRProductList Where Isnull(IsExcluded,0) = 0
		Open Cur_Items
		Fetch from Cur_Items into @ProdDefnID,@Product,@level
		While @@fetch_status =0
			Begin

				If @Product <> 'All'
				Begin
					Delete From @TmpItems
					Insert Into @TmpItems(ProdDefnID,Product_Code)
					Select @ProdDefnID,Product_Code From dbo.Fn_GetLeastLevelSKU(@Product,@level)
				End
				Else
				Begin
					Delete From @TmpItems
					
					If (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 0
					Begin
						Insert Into @TmpItems(ProdDefnID,Product_Code)
						Select Distinct @ProdDefnID,I.Product_code
						from items I ,tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 where
						IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
						and IC2.Category_Name = GR.Division
					End
					Else
					Begin
						Insert Into @TmpItems(ProdDefnID,Product_Code)
						Select Distinct @ProdDefnID,O.SystemSKU from OCGItemMaster O,Items I
						Where I.Product_Code = O.SystemSKU
						And O.Exclusion = 0
					End			 
				End

				Delete From @TmpItems where Product_Code in (select Distinct Product_Code From @TmpExItems Where ProdDefnID = @ProdDefnID)

				Truncate Table #tmpProd
				Insert into #tmpProd
				select Distinct Product_Code From TmpGGDRSKUDetails Where ProdDefnID = @ProdDefnID
				Insert Into TmpGGDRSKUDetails (ProdDefnID,Product_Code)
				Select @ProdDefnID,Product_Code From @TmpItems Where Product_Code Not in (select Product_Code From #tmpProd)

				Fetch Next from Cur_Items into @ProdDefnID,@Product,@level
			End
		Close Cur_Items
		Deallocate Cur_Items

		If (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 0
		Begin
			Update T Set T.Division = T1.Division,
						 T.SubCategory = T1.SubCategory,
						 T.MarketSKU = T1.MarketSKU,
						 T.CategoryGroup = T1.GroupName
			From TmpGGDRSKUDetails T,
			(Select Distinct I.Product_code,IC2.Category_Name Division,IC3.Category_Name SubCategory,IC4.Category_Name MarketSKU,GR.CategoryGroup GroupName
			from items I ,tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 where
			IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
			and IC2.Category_Name = GR.Division) T1
			Where T.Product_Code = T1.Product_Code
			And ProdDefnID In (Select Distinct ProdDefnID From @ProdDefnIDList)
		End
		Else
		Begin
			Update T Set T.Division = T1.Division,
						 T.SubCategory = T1.SubCategory,
						 T.MarketSKU = T1.MarketSKU,
						 T.CategoryGroup = T1.GroupName
			From TmpGGDRSKUDetails T,
			(Select Distinct O.SystemSKU,O.GroupName,O.Division,O.SubCategory,O.MarketSKU from OCGItemMaster O,Items I
			Where I.Product_Code = O.SystemSKU
			And O.Exclusion = 0) T1
			Where T.Product_Code = T1.SystemSKU	
			And ProdDefnID In (Select Distinct ProdDefnID From @ProdDefnIDList)
		End	
Drop Table #tmpProd
End  
