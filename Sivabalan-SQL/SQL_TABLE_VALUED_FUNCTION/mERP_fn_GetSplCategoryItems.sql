CREATE Function mERP_fn_GetSplCategoryItems(@SchemeID Int)
Returns @tmpAllSKU table
(
SKUCode nVarchar(510)
)
As
Begin
	Declare @ScopeID Int
	Declare @tmpSubCat table(CategoryID Int)
	Declare @tmpMarketSKU table(CategoryID Int)
	Declare @tmpSKU table(SKUCode nVarchar(255))
	--Create Table #tmpAllSKU(SKUCode nVarchar(255))	
	Declare @PrdtScopeID Int

	Declare CurCSPrductGroup Cursor For  
	Select ProductScopeID From tbl_mERP_SchemeProductScopeMap Where SchemeID = @SCHEMEID
	Open CurCSPrductGroup
	Fetch From CurCSPrductGroup Into @PrdtScopeID
	While @@FETCH_STATUS = 0  
	Begin   
		--To Get All SubCategory	
		If Exists(Select * From tbl_mERP_SchCategoryScope Where Category = N'All' And ProductScopeID = @PrdtScopeID)
		Begin
			Insert Into @tmpSubCat
			Select CategoryID From ItemCategories Where ParentID In
			(Select CategoryID From ItemCategories Where Level = 2 And Active = 1)
		End
		Else
			Insert Into @tmpSubCat
			Select CategoryID From ItemCategories Where ParentID In
			(Select CategoryID From ItemCategories Where Category_Name In(
			Select Category From tbl_mERP_SchCategoryScope Where ProductScopeID = @PrdtScopeID))

		--To Get All MarketSku
		If Exists(Select * From tbl_mERP_SchSubCategoryScope Where SubCategory = N'All' And ProductScopeID = @PrdtScopeID)
		Begin
			Insert Into @tmpMarketSKU
			Select CategoryID From ItemCategories Where ParentID In(Select CategoryID From @tmpSubCat)
		End
		Else
			Insert Into @tmpMarketSKU
			Select CategoryID From ItemCategories Where ParentID In(Select CategoryID From @tmpSubCat) And
			ParentID In(Select CategoryID From ItemCategories Where Category_Name In(
			Select SubCategory From tbl_mERP_SchSubCategoryScope Where ProductScopeID = @PrdtScopeID))
		
		--To Get The Product
		If Exists(Select * From tbl_mERP_SchMarketSKUScope Where MarketSKU = N'All' And ProductScopeID = @PrdtScopeID)
		Begin
			Insert Into @tmpSKU
			Select Product_Code from Items where CategoryID In(Select CategoryID From @tmpMarketSKU)
		End
		Else
			Insert Into @tmpSKU 
			Select Product_Code from Items where CategoryID In(Select CategoryID From @tmpMarketSKU)
			And CategoryID In(Select CategoryID From ItemCategories Where Category_Name In
			(Select MarketSKU  From tbl_mERP_SchMarketSKUScope Where ProductScopeID = @PrdtScopeID))
			--Select only the fileters sku's

		If Exists(Select * From tbl_mERP_SchSKUCodeScope Where SKUCode = N'All' And ProductScopeID = @PrdtScopeID)
		Begin
			Insert into @tmpAllSKU Select * From @tmpSKU
		End
		Else
			Insert into @tmpAllSKU Select Product_Code From Items Where Product_Code in(Select SKUCode From @tmpSKU)
			And Product_Code in(Select SKUCode From tbl_mERP_SchSKUCodeScope Where 
			ProductScopeID = @PrdtScopeID)

		Delete From @tmpSubCat
		Delete From @tmpMarketSKU
		Delete From @tmpSKU
		Fetch From CurCSPrductGroup Into @PrdtScopeID    
	END  
	Close CurCSPrductGroup   
	Deallocate CurCSPrductGroup  

	--Select SKUCode From @tmpAllSKU

	Delete From @tmpSubCat
	Delete From @tmpMarketSKU
	Delete From @tmpSKU
	--Drop Table #tmpAllSKU
	Return
End
