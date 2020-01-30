
Create Procedure mERP_sp_Find_SKUSchemeID_Van
(@SKUCode as nvarchar (30),                              
 @ServerDate as datetime,                              
 @Quantity as Decimal(18,6),                            
 @Amount as Decimal(18,6)=0                    
 )  
As
Begin

	set dateFormat dmy
    Set @ServerDate = dbo.stripTimeFromDate(@ServerDate)
	Declare @CustChannel As nVarchar(255)
	Declare @SubChannel  As nVarchar(255)
	Declare @MarKetSKU as nVarchar(255)
	Declare @SubCat as nVarchar(255)
	Declare @Category as nVarchar(255)
	Declare @CategoryID as Int
	Declare @SubCategoryID as Int
	Declare @UOM1_Conversion as Decimal(18,6)           
	Declare @UOM2_Conversion as Decimal(18,6)
    Declare @ChkExpiryDate As Datetime
    Set @ChkExpiryDate = dbo.stripTimeFromDate(GetDate())


	Create Table #tmpScheme(SchemeID Int)
	Create Table #tmpSchProdScope(SchemeID Int,ProductScopeID Int)
	Create Table #tmpSlab(SchemeID Int,RecSchemeID Int ,
	Description nVarchar(500) Collate SQL_Latin1_General_CP1_CI_AS,SlabType Int,
	SlabID Int,UOM Int,SlabStart Decimal(18,6))	
	Create Table #tmpOutput(SchemeID Int,SchemeCode nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	Description nVarchar(500) Collate SQL_Latin1_General_CP1_CI_AS,SlabType Int,
	SlabID Int)												 


	Select @MarKetSKU = Category_Name,@SubCategoryID = ParentID From ItemCategories Where CategoryID = 
	(Select CategoryID From Items Where Product_Code = @SKUCode)

	Select 	@SubCat = Category_Name,@CategoryID = ParentID From ItemCategories Where CategoryID = @SubCategoryID

	Select 	@Category = Category_Name  From ItemCategories Where CategoryID = @CategoryID

	
	Select @UOM1_Conversion = IsNull(UOM1_Conversion,1), @UOM2_Conversion = IsNull(UOM2_Conversion,1) From Items Where Product_code = @SKUCode          

	Insert Into #tmpScheme
	Select Distinct SchemeID
	From 
		tbl_mERP_SchemeAbstract 
	Where 
		(@ServerDate Between ActiveFrom And ActiveTo) And
        (@ChkExpiryDate Between ActiveFrom and ExpiryDate) And
		Active = 1 And
		ApplicableOn = 1 And --1  means ItemBased Scheme
		ItemGroup = 1

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

	If (Select Count(*) From #tmpSchProdScope) = 0 
		 Goto NoValidScheme

	--SlabType 0 - ItemBased Amount,1 - ItemBased Pecentage, 2 - ItemBased FreeItem
	Insert Into #tmpSlab
	Select Distinct
		SAbs.SchemeID,SAbs.CS_RecSchID,Description,SlabType,SSLAB.SLABID,SSLAB.UOM,SSLAB.SlabStart
	From 
		tbl_mERP_SchemeAbstract SAbs, tbl_mERP_SchemeSlabDetail SSLAB
	Where
		SAbs.SchemeID In(Select SchemeID From #tmpSchProdScope) And
		SAbs.SchemeID = SSLAB.SchemeID And
		SSLAB.UOM IN(1,2,3) And  ---Quantity based slab
		 (@Quantity between           
				  (Case IsNull(SSLAB.UOM,0)           
				  When 1 then SSLAB.SlabStart           
				  When 2 then SSLAB.SlabStart* @UOM1_Conversion          
				  When 3 then SSLAB.SlabStart* @UOM2_Conversion 
				  End) and           
				  (Case IsNull(SSLAB.UOM,0)           
				  When 1 then SSLAB.SlabEnd           
				  When 2 then SSLAB.SlabEnd * @UOM1_Conversion          
				  When 3 then SSLAB.SlabEnd * @UOM2_Conversion End
				  )
		   )   And
		@Quantity >= (Case IsNull(SSLAB.Onward,0) When 0 Then 0 Else (Case IsNull(SSLAB.UOM,0)
			      When 1 then SSLAB.Onward           
				  When 2 then SSLAB.Onward* @UOM1_Conversion          
				  When 3 then SSLAB.Onward* @UOM2_Conversion 
				  End)	End)   
	--Order By Uom
			
	Insert Into #tmpSlab
	Select Distinct
		SAbs.SchemeID,SAbs.CS_RecSchID,Description,SlabType,SSLAB.SLABID,SSLAB.UOM,SSLAB.SlabStart
	From 
		tbl_mERP_SchemeAbstract SAbs, tbl_mERP_SchemeSlabDetail SSLAB
	Where
		SAbs.SchemeID In(Select SchemeID From #tmpSchProdScope) And
		SAbs.SchemeID = SSLAB.SchemeID And
		SSLAB.UOM = 4 And	--Value Based slab
		@Amount between SSLAB.SlabStart and SSLAB.SlabEnd And
		@Amount >= isNull(SSLAB.Onward,0)

	--Select * From #tmpSlab

	/*Check For Overlapping slabs */

	--Insert Schemes With Single Slab first
	  Insert Into #tmpOutput
	  Select SchemeID,RecSchemeID,Description,SlabType,SlabID from #tmpSlab Where SchemeID In
	 (Select SchemeID From #tmpSlab Group By SchemeID Having Count(SchemeID) = 1)
	
	--For schemes Which satisfies multiple slab then the first 
	--first satisfying Slab will be applied.
	Insert Into #tmpOutput
	Select  SchemeID,RecSchemeID,Description,SlabType,Min(SlabID) from #tmpSlab Where SchemeID In
	(Select SchemeID From #tmpSlab Group By SchemeID Having Count(SchemeID) > 1)
	Group By SchemeID,RecSchemeID,Description,SlabType
	--Order By Uom,SlabStart,SlabID

NoValidScheme:		
	Select SchemeID,SchemeCode,Description,SlabType,SlabID From #tmpOutput 
	Drop Table #tmpScheme
	Drop Table #tmpSchProdScope
	Drop Table #tmpOutput
End
