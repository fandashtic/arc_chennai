Create Procedure dbo.mERP_SP_ListApplicableITemScheme_VAN
(@SKUCode as nvarchar (30),                              
 @ServerDate as datetime, 
 @CreationDate as nvarchar(30) = ''
 )
As
Begin
	Declare @CustChannel As nVarchar(255)
	Declare @SubChannel  As nVarchar(255)
	Declare @MarKetSKU as nVarchar(255)
	Declare @SubCat as nVarchar(255)
	Declare @Category as nVarchar(255)
	Declare @CategoryID as Int
	Declare @SubCategoryID as Int

	If (@CreationDate ='')
		Set @CreationDate = getdate()
	Else
		Select @CreationDate = Convert(Datetime, @CreationDate)

	
	Create Table #tmpScheme(SchemeID Int)
	Create Table #tmpSchProdScope(SchemeID Int,ProductScopeID Int)

	Select @MarKetSKU = Category_Name,@SubCategoryID = ParentID From ItemCategories Where CategoryID = 
	(Select CategoryID From Items Where Product_Code = @SKUCode)

	Select 	@SubCat = Category_Name,@CategoryID = ParentID From ItemCategories Where CategoryID = @SubCategoryID

	Select 	@Category = Category_Name  From ItemCategories Where CategoryID = @CategoryID

	
	Insert Into #tmpScheme
	Select Distinct S.SchemeID
	From 
		tbl_mERP_SchemeAbstract S
	Where 
		(dbo.stripTimeFromDate(@ServerDate) Between dbo.stripTimeFromDate(ActiveFrom) And dbo.stripTimeFromDate(ActiveTo)) And
		(dbo.stripTimeFromDate(@CreationDate) Between dbo.stripTimeFromDate(ActiveFrom) And dbo.stripTimeFromDate(ExpiryDate)) And
		Active = 1 And
		S.ApplicableOn = 1 And --1  means ItemBased Scheme
		S.ItemGroup in (1) and
		s.SchemeType in (1,2)

		Declare @SchemeID Int
		Declare @ScopeID Int
		Declare Cur_SchemeID  Cursor For 
		Select SchemeID From #tmpScheme
		Open Cur_SchemeID
		Fetch Next From Cur_SchemeID Into @SchemeID
		While @@Fetch_Status = 0
		Begin
			Declare Cur_ScopeID Cursor For
			Select ProductScopeID From tbl_mERP_SchemeProductScopeMap Where SchemeID = @SchemeID
			Open Cur_ScopeID
			Fetch Next From Cur_ScopeID Into @ScopeID
			While @@Fetch_Status = 0
			Begin
				Insert Into #tmpSchProdScope
				Select @SchemeID,Cat.ProductScopeID
				From
					 tbl_mERP_SchCategoryScope Cat,tbl_mERP_SchSubCategoryScope SubCat,
					 tbl_mERP_SchMarketSKUScope MarSKU,tbl_mERP_SchSKUCodeScope SKU
				Where 
					 Cat.ProductScopeID = SubCat.ProductScopeID And
					 SubCat.ProductScopeID = MarSKU.ProductScopeID And
					 MarSKU.ProductScopeID = SKU.ProductScopeID And
					 Cat.ProductScopeID = @ScopeID And
					 (Cat.Category = @Category Or Cat.Category = 'All') And
					 (SubCat.SubCategory = @SubCat Or SubCat.SubCategory = 'All') And
					 (MarSKU.MarketSKU = @MarKetSKU Or MarSKU.MarketSKU = 'All') And
					 (SKU.SKUCode = @SKUCode Or SKU.SKUCode = 'All') 

				Fetch Next From Cur_ScopeID Into @ScopeID
			End
			Close Cur_ScopeID
			Deallocate Cur_ScopeID
			Fetch Next From Cur_SchemeID Into @SchemeID
		End
		Close Cur_SchemeID
		Deallocate Cur_SchemeID


	Select SABS.SchemeID,CS_RecSchID,ActivityCode,Description,ActiveFrom, ActiveTo,CSAppType.ApplicableOn,
	CSIGrp.ItemGroup, -1 As 'GroupID', SABS.ApplicableOn, SABS.ItemGroup
    --case when SchemeType=1 then 'SP' when SchemeType=2 then 'CP' else '' end,
	--case when ApplicableOn=1 Then 'Line' when ApplicableOn=2 then 'Invoice' else '' end,
    --ActiveFrom,ActiveTo,-1 As 'GroupID'
	From tbl_mERP_schemeAbstract SABS,
	tbl_mERP_SchemeItemGroup CSIGrp, tbl_mERP_SchemeApplicableType CSAppType
	Where SABS.SchemeID in (select distinct SchemeID from #tmpSchProdScope) And
    SABS.ItemGroup = CSIGrp.ID And 
    SABS.ApplicableOn = CSAppType.ID

	Drop Table #tmpScheme
	Drop Table #tmpSchProdScope
	
End
