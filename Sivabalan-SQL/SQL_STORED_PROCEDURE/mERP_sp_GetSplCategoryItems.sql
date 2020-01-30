CREATE Procedure mERP_sp_GetSplCategoryItems(@SchemeID Int)
As
Begin
	Declare @ScopeID Int
	Create Table #tmpSubCat(CategoryID Int)
	Create Table #tmpMarketSKU(CategoryID Int)
	Create Table #tmpSKU(SKUCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpAllSKU(SKUCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)	
	Declare @PrdtScopeID Int

	Declare CurCSPrductGroup Cursor For  
	Select ProductScopeID From tbl_mERP_SchemeProductScopeMap Where SchemeID = @SCHEMEID
	Open CurCSPrductGroup
	Fetch From CurCSPrductGroup Into @PrdtScopeID
	While @@FETCH_STATUS = 0  
	Begin   
		--To Get All SubCategory	
		--Performance Tuning
		If (Select count(*) From tbl_mERP_SchCategoryScope Where Category = N'All' And ProductScopeID = @PrdtScopeID)<>0
		Begin
			Insert Into #tmpSubCat
			Select A.CategoryID From ItemCategories A Inner Join ItemCategories B
			On A.ParentID=B.CategoryID
			Where B.Level=2 and B.Active=1	
/*
			Select CategoryID From ItemCategories Where ParentID In
			(Select CategoryID From ItemCategories Where Level = 2 And Active = 1)
*/
		End
		Else
			Begin
			Insert Into #tmpSubCat 
			select A.CategoryID from ItemCategories A Inner Join ItemCategories B 
			On A.ParentID=B.CategoryID Inner Join tbl_Merp_SchCategoryScope C 
			On B.Category_Name = C.Category 
			Where C.ProductScopeID= @PrdtScopeID
			End
/*
			Select CategoryID From ItemCategories Where ParentID In
			(Select CategoryID From ItemCategories Where Category_Name In(
			Select Category From tbl_mERP_SchCategoryScope Where ProductScopeID = 707))
*/


		--To Get All MarketSku
		--Performance Tuning
		If (Select count(*) From tbl_mERP_SchSubCategoryScope Where SubCategory = N'All' And ProductScopeID = @PrdtScopeID)<>0
		Begin
			Insert Into #tmpMarketSKU
			Select A.CategoryID From ItemCategories A Inner Join #tmpSubCat B  On A.ParentID = B.CategoryID 
			--Select CategoryID From ItemCategories Where ParentID In(Select CategoryID From #tmpSubCat)
		End
		Else
			Insert Into #tmpMarketSKU
			Select A.CategoryID From ItemCategories A Inner Join #tmpSubCat B 
			On A.ParentID=B.CategoryID  Join ItemCategories C 
			On A.ParentID=C.CategoryID Join tbl_mERP_SchSubCategoryScope D 
			On C.Category_Name = D.SubCategory 	
			Where D.ProductScopeID = @PrdtScopeID
			
/*
			Select CategoryID From ItemCategories Where ParentID In(Select CategoryID From #tmpSubCat) And
			ParentID In(Select CategoryID From ItemCategories Where Category_Name In(
			Select SubCategory From tbl_mERP_SchSubCategoryScope Where ProductScopeID = @PrdtScopeID))
*/	

		--To Get The Product
		--Performance Tuning
		If (Select count(*) From tbl_mERP_SchMarketSKUScope Where MarketSKU = N'All' And ProductScopeID = @PrdtScopeID)<>0
		Begin
			Insert Into #tmpSKU
			Select A.Product_Code from Items A Inner Join #tmpMarketSKU B on A.CategoryID=B.CategoryID	
			--Select Product_Code from Items where CategoryID In(Select CategoryID From #tmpMarketSKU)
		End
		Else
			Insert Into #tmpSKU 
			Select A.Product_Code from Items A Inner Join #tmpMarketSKU B 
			On A.CategoryID = B.CategoryID Join ItemCategories C
			On A.CategoryID = C.CategoryID Join tbl_Merp_SchMarketSKUScope D
			on C.Category_Name = D.MarketSKU 
			Where D.ProductScopeID = @PrdtScopeID
/*

			Select Product_Code from Items where CategoryID In(Select CategoryID From #tmpMarketSKU)
			And CategoryID In(Select CategoryID From ItemCategories Where Category_Name In
			(Select MarketSKU  From tbl_mERP_SchMarketSKUScope Where ProductScopeID = @PrdtScopeID))
*/
			--Select only the fileters sku's
		--Performance Tuning
		If (Select count(*) From tbl_mERP_SchSKUCodeScope Where SKUCode = N'All' And ProductScopeID = @PrdtScopeID)<>0
		Begin
			Insert into #tmpAllSKU Select * From #tmpSKU
		End
		Else
			Insert into #tmpAllSKU 
			Select A.Product_Code from Items A Inner Join #tmpSKU B
			On A.Product_Code = B.SKUCode Inner Join tbl_mERP_SchSKUCodeScope C
			On A.Product_Code = C.SKUCode
			Where B.SKUCODE <> '' and C.ProductScopeID=@PrdtScopeID
			
/*			
			Select Product_Code From Items Where Product_Code in(Select SKUCode From #tmpSKU)
			And Product_Code in(Select SKUCode From tbl_mERP_SchSKUCodeScope Where 
			ProductScopeID = @PrdtScopeID)
*/
		Delete From #tmpSubCat
		Delete From #tmpMarketSKU
		Delete From #tmpSKU
		Fetch From CurCSPrductGroup Into @PrdtScopeID    
	END  
	Close CurCSPrductGroup   
	Deallocate CurCSPrductGroup  

	Select SKUCode From #tmpAllSKU

	Drop Table #tmpSubCat
	Drop Table #tmpMarketSKU
	Drop Table #tmpSKU
	Drop Table #tmpAllSKU
End
