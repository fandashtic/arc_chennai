Create Function mERP_fn_CheckSchemeSKU(@SchemeID Int, @SKUCode nVarchar(255), @Category nVarchar(255),
				@SubCategory  nVarchar(255), @MarketSKU nVarchar(255))
Returns Int
As
Begin

	Declare @IsExists Int
	Declare @ScopeID Int

	Set @IsExists = 0

	Declare SKUScope Cursor For
		Select ProductScopeID From tbl_mERP_SchemeProductScopeMap Where SchemeID = @SchemeID
	Open SKUScope
	Fetch Next From SKUScope Into @ScopeID
	While @@Fetch_Status = 0
	Begin
		If Exists(Select Cat.ProductScopeID
			From tbl_mERP_SchCategoryScope Cat,tbl_mERP_SchSubCategoryScope SubCat,
				tbl_mERP_SchMarketSKUScope MarSKU,tbl_mERP_SchSKUCodeScope SKU
			Where Cat.ProductScopeID = SubCat.ProductScopeID And
			SubCat.ProductScopeID = MarSKU.ProductScopeID And
			MarSKU.ProductScopeID = SKU.ProductScopeID And
			Cat.ProductScopeID = @ScopeID And
			(Cat.Category = @Category Or Cat.Category = 'All') And
			(SubCat.SubCategory = @SubCategory Or SubCat.SubCategory = 'All') And
			(MarSKU.MarketSKU = @MarKetSKU Or MarSKU.MarketSKU = 'All') And
			(SKU.SKUCode = @SKUCode Or SKU.SKUCode = 'All'))
			Begin
				Set @IsExists = 1
				Goto Skip	
			End
		Else If Exists(Select * From tbl_mERP_SchemeFreeSKU Where SlabID In 
						(Select SlabID From tbl_mERP_SchemeSlabDetail Where SchemeID = @SchemeID)
						And SKUCode = @SKUCode )
			Begin
				Set @IsExists = 1
				Goto Skip	
			End
		
		Fetch Next From SKUScope Into @ScopeID
	End

Skip:
	Close SKUScope
	Deallocate SKUScope
	Return @IsExists
End

