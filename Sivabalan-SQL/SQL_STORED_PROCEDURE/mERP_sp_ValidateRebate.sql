Create Procedure mERP_sp_ValidateRebate
(
@OutletID as nvarchar(30),   
@SKUCode as nvarchar (30),                              
@ItemRebateID as nVarchar(2000),
@ItemRebateRate as Decimal(18,6),
@AllRebateID as nVarchar(2000)
)  
As
Begin

	Declare @MarKetSKU as nVarchar(255)
	Declare @SubCat as nVarchar(255)
	Declare @Category as nVarchar(255)
	Declare @CategoryID as Int
	Declare @SubCategoryID as Int
	Declare @SchID Int
	Declare @RebateIDS nVarchar(2000)
	Declare @RebateRate Decimal(18,6)
	Declare @RebateExists Int


	Create Table #tmpScheme(SchemeID Int,GroupID Int)
	Create Table #tmpCustScheme(SchemeID Int)
	Create Table #tmpSchProdScope(SchemeID Int,ProductScopeID Int,GroupID Int)
	Create Table #tmpSlab(SchemeID Int,SlabID Int,Percentage Decimal(18,6))	


	Set @RebateExists = 1

	Insert Into #tmpScheme(SchemeID) 
	Select * From dbo.sp_SplitIn2Rows(@ItemRebateID,',')

	Insert Into #tmpCustScheme(SchemeID) 
	Select * From dbo.sp_SplitIn2Rows(@AllRebateID,',')

	iF Exists(Select * From #tmpScheme Where SchemeID Not In(Select SchemeID From #tmpCustScheme))
	Begin
		Set @RebateExists	 = 0
		GoTo OvernOut
	End 

	
--	Update  T Set T.GroupID = SO.GroupID
--	From 
--		#tmpScheme T ,tbl_mERP_SchemeOutlet SO
--	Where 
--		SO.SchemeID = T.SchemeID And
--		(SO.OutletID = @OutletID Or SO.OutletID = N'All')  And
--		SO.QPS = 0 



	
	Select @MarKetSKU = Category_Name,@SubCategoryID = ParentID From ItemCategories Where CategoryID = 
	(Select CategoryID From Items Where Product_Code = @SKUCode)

	Select 	@SubCat = Category_Name,@CategoryID = ParentID From ItemCategories Where CategoryID = @SubCategoryID

	Select 	@Category = Category_Name  From ItemCategories Where CategoryID = @CategoryID

	/* To improve Performance below cursor is avoided*/

--	Declare @SchemeID Int
	Declare @ScopeID Int
--	Declare Cur_SchemeID  Cursor For 
--	Select SchemeID From #tmpCustScheme
--	Open Cur_SchemeID
--	Fetch Next From Cur_SchemeID Into @SchemeID
--	While @@Fetch_Status = 0
--	Begin
		Declare Cur_ScopeID Cursor For
		Select ProductScopeID From tbl_mERP_SchemeProductScopeMap Where --SchemeID = @SchemeID
		Schemeid in (select distinct SchemeID From #tmpCustScheme)
		Open Cur_ScopeID
		Fetch Next From Cur_ScopeID Into @ScopeID
		
		While @@Fetch_Status = 0
		Begin
			Insert Into #tmpSchProdScope(SchemeID ,ProductScopeID)
			Select distinct cat.SchemeID,Cat.ProductScopeID
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
--		Fetch Next From Cur_SchemeID Into @SchemeID
--	End
--	Close Cur_SchemeID
--	Deallocate Cur_SchemeID
	    


	Update  T Set T.GroupID = SO.GroupID
	From 
		#tmpSchProdScope T ,tbl_mERP_SchemeOutlet SO
	Where 
		SO.SchemeID = T.SchemeID And
	   (SO.OutletID = @OutletID Or SO.OutletID = N'All')  And
		SO.QPS = 0 

	
	--Only SlabType = 2 Percentage - For Rebate Scheme
	Insert Into #tmpSlab
	Select Distinct
		SAbs.SchemeID,SSLAB.SLABID,isNull(SSLAB.[Value],0)
	From 
		tbl_mERP_SchemeAbstract SAbs, tbl_mERP_SchemeSlabDetail SSLAB,#tmpSchProdScope T
	Where
		--SAbs.SchemeID In (Select SchemeID From #tmpSchProdScope)
		SAbs.SchemeID = T.SchemeID And
		SAbs.SchemeID = SSLAB.SchemeID And
		SSLAB.GroupID = T.GroupID --And
		--SSLAB.UOM IN(1) 
		

	If Exists(Select * From #tmpScheme Where SchemeID Not In(Select SchemeID From #tmpSlab))
		Set @RebateExists	 = 0

	If Exists(Select * From #tmpSlab Where SchemeID Not In(Select SchemeID From #tmpScheme))
		Set @RebateExists	 = 0

	

OvernOut:		
	Select @RebateExists

	Drop Table #tmpScheme
	Drop Table #tmpCustScheme
	Drop Table #tmpSchProdScope
	Drop Table #tmpSlab

End
