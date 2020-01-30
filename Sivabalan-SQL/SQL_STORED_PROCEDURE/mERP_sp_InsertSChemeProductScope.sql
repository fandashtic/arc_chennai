Create Procedure mERP_sp_InsertSChemeProductScope (@SchID int, @RecdSchID int)  
AS  
Begin  
	Declare @ScopeID Int  
	Declare @CatList nVarchar(4000)  
	Declare @SCatList nVarchar(4000)  
	Declare @MarketSKU nVarchar(4000)  
	Declare @SKUList nVarchar(4000)  
	Create Table #List (Scopes nVarChar(4000))  
	  
	Declare @SchemeType nVarchar(255)
	Select @SchemeType  = CS_Type from tbl_mERP_RecdSchAbstract where CS_SchemeID = @RecdSchID

	If (Upper(@SchemeType) <> 'DISPLAY')  
	Begin
		Declare ProdScope Cursor For   
		Select CS_Category, CS_SubCategory, CS_MarketSKU, CS_SKUCode  
		From tbl_mERP_RecdSchProductScope Where CS_SChemeID = @RecdSchID  
	  
		Open ProdScope  
	  
		Fetch From ProdScope InTo @CatList, @SCatList, @MarketSKU, @SKUList  
	  
		While @@Fetch_Status = 0  
		Begin  
	  
			Insert Into tbl_mERP_SchemeProductScopeMap (SchemeID) Values (@SchID)  
			Select @ScopeID = @@Identity  
			  
			Truncate Table #List  
			Insert Into #List Select * from dbo.sp_SplitIn2Rows(@CatList, '|')  
			  
			Insert Into tbl_mERP_SchCategoryScope (SchemeID, ProductScopeID, Category)  
			Select @SchID, @ScopeID , LTrim(Scopes) From #List  
			  
			Truncate Table #List  
			Insert Into #List Select * from dbo.sp_SplitIn2Rows(@SCatList, '|')  
			  
			Insert Into tbl_mERP_SchSubCategoryScope (SchemeID, ProductScopeID, SubCategory)  
			Select @SchID, @ScopeID , LTrim(Scopes) From #List  
			  
			Truncate Table #List  
			Insert Into #List Select * from dbo.sp_SplitIn2Rows(@MarketSKU, '|')  
			  
			Insert Into tbl_mERP_SchMarketSKUScope (SchemeID, ProductScopeID, MarketSKU)  
			Select @SchID, @ScopeID , LTrim(Scopes) From #List  
			  
			Truncate Table #List  
			Insert Into #List Select * from dbo.sp_SplitIn2Rows(@SKUList, '|')  
			  
			Insert Into tbl_mERP_SchSKUCodeScope (SchemeID, ProductScopeID, SKUCode)  
			Select @SchID, @ScopeID , LTrim(Scopes) From #List  
			  
			Fetch From ProdScope InTo @CatList, @SCatList, @MarketSKU, @SKUList  
		End  
	  
		Close ProdScope  
		Deallocate ProdScope  
	  
		Insert into SchMinQty(SchemeID,Category,CATEGORY_LEVEL,MIN_RANGE,UOM)
		Select @SchID,Category,CATEGORY_LEVEL,MIN_RANGE,UOM from RecdSchMinQty where CS_SchemeID=@RecdSchID
		If exists(Select 'X' from SchMinQty where SchemeID=@SchID)
			update tbl_merp_schemeabstract set IsMinqty=1 where SchemeID=@SchID

		Select 1,'Done'  
	End  
End -- End of Display check

Select 1,'Done'  
