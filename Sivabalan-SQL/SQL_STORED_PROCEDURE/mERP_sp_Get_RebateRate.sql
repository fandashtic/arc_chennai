Create Procedure mERP_sp_Get_RebateRate
(
@OutletID as nvarchar(30),   
@SKUCode as nvarchar (30),                              
@SalePrice as Decimal(18,6),
@RebateID as nVarchar(2000)
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
	Declare @TotRebateRate Decimal(18,6)
	Declare @RebateDet nVarchar(2000)
	Declare @RebateRate Decimal(18,6)

	Create Table #tmpScheme(SchemeID Int,GroupID Int)
	Create Table #tmpSchProdScope(SchemeID Int,ProductScopeID Int)
	Create Table #tmpSlab(SchemeID Int,SlabID Int,Percentage Decimal(18,6))	



	Insert Into #tmpScheme(SchemeID) 
	Select * From dbo.sp_SplitIn2Rows(@RebateID,',')

	
	Update  T Set T.GroupID = SO.GroupID
	From 
		#tmpScheme T ,tbl_mERP_SchemeOutlet SO
	Where 
		SO.SchemeID = T.SchemeID And
		(SO.OutletID = @OutletID Or SO.OutletID = N'All')  And
		SO.QPS = 0 


	Select @MarKetSKU = Category_Name,@SubCategoryID = ParentID From ItemCategories Where CategoryID = 
	(Select CategoryID From Items Where Product_Code = @SKUCode)

	Select 	@SubCat = Category_Name,@CategoryID = ParentID From ItemCategories Where CategoryID = @SubCategoryID

	Select 	@Category = Category_Name  From ItemCategories Where CategoryID = @CategoryID

--	Declare @SchemeID Int
--	Declare @ScopeID Int
--	Declare Cur_SchemeID  Cursor For 
--	Select SchemeID From #tmpScheme
--	Open Cur_SchemeID
--	Fetch Next From Cur_SchemeID Into @SchemeID
--	While @@Fetch_Status = 0
--	Begin
--		Declare Cur_ScopeID Cursor For
--		Select ProductScopeID From tbl_mERP_SchemeProductScopeMap Where SchemeID = @SchemeID
--		Open Cur_ScopeID
--		Fetch Next From Cur_ScopeID Into @ScopeID
--		
--		While @@Fetch_Status = 0
--		Begin
--			Insert Into #tmpSchProdScope
--			Select @SchemeID,Cat.ProductScopeID
--			From
--				 tbl_mERP_SchCategoryScope Cat,tbl_mERP_SchSubCategoryScope SubCat,
--				 tbl_mERP_SchMarketSKUScope MarSKU,tbl_mERP_SchSKUCodeScope SKU
--			Where 
--				 Cat.ProductScopeID = SubCat.ProductScopeID And
--				 SubCat.ProductScopeID = MarSKU.ProductScopeID And
--				 MarSKU.ProductScopeID = SKU.ProductScopeID And
--				 Cat.ProductScopeID = @ScopeID And
--				 (Cat.Category = @Category Or Cat.Category = 'All') And
--				 (SubCat.SubCategory = @SubCat Or SubCat.SubCategory = 'All') And
--				 (MarSKU.MarketSKU = @MarKetSKU Or MarSKU.MarketSKU = 'All') And
--				 (SKU.SKUCode = @SKUCode Or SKU.SKUCode = 'All') 
--				
--			Fetch Next From Cur_ScopeID Into @ScopeID
--		End
--		Close Cur_ScopeID
--		Deallocate Cur_ScopeID
--		Fetch Next From Cur_SchemeID Into @SchemeID
--	End
--	Close Cur_SchemeID
--	Deallocate Cur_SchemeID


	Insert Into #tmpSchProdScope
	Select Cat.SchemeID,Cat.ProductScopeID
	From
		 tbl_mERP_SchCategoryScope Cat,tbl_mERP_SchSubCategoryScope SubCat,
		 tbl_mERP_SchMarketSKUScope MarSKU,tbl_mERP_SchSKUCodeScope SKU,#tmpScheme T
	Where 
	     Cat.SchemeID  = T.SchemeID And		
		 Cat.ProductScopeID = SubCat.ProductScopeID And
		 SubCat.ProductScopeID = MarSKU.ProductScopeID And
		 MarSKU.ProductScopeID = SKU.ProductScopeID And
		 (Cat.Category = @Category Or Cat.Category = 'All') And
		 (SubCat.SubCategory = @SubCat Or SubCat.SubCategory = 'All') And
		 (MarSKU.MarketSKU = @MarKetSKU Or MarSKU.MarketSKU = 'All') And
		 (SKU.SKUCode = @SKUCode Or SKU.SKUCode = 'All') 
	    
	

	If (Select Count(*) From #tmpSchProdScope) = 0 
		 Goto NoValidScheme

	
	Insert Into #tmpSlab
	Select Distinct
		SAbs.SchemeID,SSLAB.SLABID,isNull(SSLAB.[Value],0)
	From 
		tbl_mERP_SchemeAbstract SAbs, tbl_mERP_SchemeSlabDetail SSLAB,#tmpScheme T
	Where
		SAbs.SchemeID In(Select SchemeID From #tmpSchProdScope) And
		SAbs.SchemeID = T.SchemeID And
		SAbs.SchemeID = SSLAB.SchemeID And
		SSLAB.GroupID = T.GroupID --And
		--SSLAB.UOM IN(1) --And  ---Quantity based slab
	Order By SAbs.SchemeID
		


	Set @RebateIDS = ''
	Set @RebateDet = ''
--	Declare CurScheme Cursor For
--	Select  SchemeID,Percentage From #tmpSlab Order By SchemeID
--	Open CurScheme
--	Fetch From CurScheme Into @SchID ,@RebateRate
--	While @@Fetch_Status = 0 
--	Begin
--		If ltrim(rtrim(@RebateIDS)) = ''
--		Begin
--			Set @RebateIDS = Cast(@SchID as nVarchar)
--			Set @RebateDet = Cast(@SchID as nVarchar(1000)) + Cast('|' as nVarchar) + Cast(@RebateRate as nVarchar(50))  + Cast(Char(15) as nVarchar)
--		End
--		Else
--		Begin
--			Set @RebateIDS = Cast(@RebateIDS as nVarchar(2000)) + ',' + Cast(@SchID as nVarchar(1000))
--			Set @RebateDet = Cast(@RebateDet as nVarchar(2000)) + Cast(@SchID as nVarchar(1000)) + Cast('|' as nVarchar) + Cast(@RebateRate as nVarchar(50))  + Cast(Char(15) as nVarchar)
--		End
--		
--
--		Fetch From CurScheme Into @SchID ,@RebateRate
--	End
--	Close CurScheme
--	Deallocate CurScheme

	Select @RebateIDS = Cast(@RebateIDS as nVarchar(2000)) + ',' + Cast(SchemeID as nVarchar(1000)),
		   @RebateDet =	Cast(@RebateDet as nVarchar(2000))+  Cast(SchemeID as nVarchar(1000)) + Cast('|' as nVarchar) + Cast(Percentage as nVarchar(50))  + Cast(Char(15) as nVarchar)
	From #tmpSlab

	
	Select @RebateIDS = Substring(@RebateIDS,2,Len(@RebateIDS))
	Select @RebateDet = Substring(@RebateDet,2,Len(@RebateDet))
	

	Select @TotRebateRate =  Round(@SalePrice / (1 + (Cast(Sum(Percentage) As Decimal(18,6))/100)),2)  From #tmpSlab

NoValidScheme:		
	Select @RebateIDS ,@TotRebateRate ,@RebateDet

	Drop Table #tmpScheme
	Drop Table #tmpSchProdScope
	Drop Table #tmpSlab

End
