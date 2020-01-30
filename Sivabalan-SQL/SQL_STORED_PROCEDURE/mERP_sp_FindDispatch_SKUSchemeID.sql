Create Procedure mERP_sp_FindDispatch_SKUSchemeID 
(@SKUCode as nvarchar (30),                              
 @Invoicedate as DATETIME,                              
 @Quantity as Decimal(18,6),                            
 @OutletID as nvarchar(30)=N'',                            
 @Amount as Decimal(18,6)=0 ,
 @CreationDate as nVarchar(50) = N''                   
 )  
As
Begin
	Declare @CustChannel As nVarchar(255)
	Declare @TMDField4  As nVarchar(255)
	Declare @MarKetSKU as nVarchar(255)
	Declare @SubCat as nVarchar(255)
	Declare @Category as nVarchar(255)
	Declare @CategoryID as Int
	Declare @SubCategoryID as Int
	Declare @UOM1_Conversion as Decimal(18,6)           
	Declare @UOM2_Conversion as Decimal(18,6)       

	Declare @OlMapId int
	Declare @OlChannel nVarchar(255)
	Declare @OlOutlettype nVarchar(255)
	Declare @OlLoyalty nVarchar(255)
	         
	If isNull(@CreationDate,N'') = N''
		Select @CreationDate = GetDate()
	
	Set @CreationDate = Cast(@CreationDate as Datetime)

	Create Table #tmpScheme(SchemeID Int,GroupID Int)
	Create Table #tmpSchProdScope(SchemeID Int,ProductScopeID Int)
	Create Table #tmpSlab(SchemeID Int,RecSchemeID nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	Description nVarchar(500) Collate SQL_Latin1_General_CP1_CI_AS,SlabType Int,
	SlabID Int,UOM Int,SlabStart Decimal(18,6))	
	Create Table #tmpOutput(SchemeID Int,SchemeCode nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	Description nVarchar(500) Collate SQL_Latin1_General_CP1_CI_AS,SlabType Int,
	SlabID Int)												 
	
--	Select 
--			@CustChannel = isNull(ChannelDesc,'') , 
--			@TMDField4 = (Select isNull(TMDMas.TMDValue,'') From  Cust_TMD_Master TMDMas ,Cust_TMD_Details TMDDet 
--						 Where TMDMas.TMDCtlPos = 6 And TMDMas.TMDID = TMDDet.TMDID And TMDDet.CustomerID = C.CustomerID)
--    From 
--			Customer  C,Customer_Channel CH
--	Where 
--			C.CustomerID = @OutletID And
--			CH.ChannelType = C.ChannelType 


/* Begin: New functionality Implemented based on OLClass Mapping */
	Select @OlMapId = OLClassID from  tbl_Merp_OlclassMapping where CustomerID = @OutletID and Active =1
	Select @OlChannel = Channel_TYpe_desc, @OlOutlettype = Outlet_Type_desc, @OlLoyalty= SubOutlet_Type_desc
	From tbl_merp_Olclass where ID = @OlMapId
/* End: New functionality Implemented based on OLClass Mapping */
		

	Select @MarKetSKU = Category_Name,@SubCategoryID = ParentID From ItemCategories Where CategoryID = 
	(Select CategoryID From Items Where Product_Code = @SKUCode)

	Select 	@SubCat = Category_Name,@CategoryID = ParentID From ItemCategories Where CategoryID = @SubCategoryID

	Select 	@Category = Category_Name  From ItemCategories Where CategoryID = @CategoryID

	
	Select @UOM1_Conversion = IsNull(UOM1_Conversion,1), @UOM2_Conversion = IsNull(UOM2_Conversion,1) From Items Where Product_code = @SKUCode          



	Insert Into #tmpScheme
	Select Distinct S.SchemeID,Min(SO.GroupID)
	From 
		tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,tbl_mERP_SchemeChannel SC ,
		tbl_mERP_SchemeOutletClass  SOLC, tbl_mERP_SchemeLoyaltyList SLList
	Where 
		(dbo.stripTimeFromDate(@InvoiceDate) Between ActiveFrom And ActiveTo) And
		(dbo.stripTimeFromDate(@CreationDate) Between ActiveFrom And ExpiryDate) And
		Active = 1 And
		S.ApplicableOn = 1 And --1  means ItemBased Scheme
		s.SchemeType in (1,2) and
		S.ItemGroup = 1 And
		S.SchemeID = SO.SchemeID And
		(SO.OutletID = @OutletID Or SO.OutletID = N'All')  And
		SO.QPS = 0 And  ---0 - Direct Scheme
		S.SchemeID = SC.SchemeID And
		SC.GroupID = SO.GroupID And
--		(SC.Channel = @CustChannel Or SC.Channel = N'All')  And 
		(SC.Channel = @OlChannel Or SC.Channel = N'All')  And 
		S.SchemeID = SOLC.SchemeID And
		SOLC.GroupID = SO.GroupID And
--		(SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All') 
		(SOLC.OutLetClass = @OlOutlettype Or SOLC.OutLetClass = N'All')  And
		S.SchemeID = SLList.SchemeID And
		SLList.GroupID = SO.GroupID And
		(SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')
	Group By S.SchemeID
				

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
		tbl_mERP_SchemeAbstract SAbs, tbl_mERP_SchemeSlabDetail SSLAB,#tmpScheme T
	Where
		SAbs.SchemeID In(Select SchemeID From #tmpSchProdScope) And
		SAbs.SchemeID = T.SchemeID And
		SAbs.SchemeID = SSLAB.SchemeID And
		SSLAB.GroupID = T.GroupID And
		SSLAB.UOM IN(1,2,3) And  ---Quantity based slab
        SSLAB.SLABTYPE IN(3) AND   
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
			
--
--
--	Insert Into #tmpSlab
--	Select Distinct
--		SAbs.SchemeID,SAbs.CS_RecSchID,Description,SlabType,SSLAB.SLABID,SSLAB.UOM,SSLAB.SlabStart
--	From 
--		tbl_mERP_SchemeAbstract SAbs, tbl_mERP_SchemeSlabDetail SSLAB,#tmpScheme T
--	Where
--		SAbs.SchemeID In(Select SchemeID From #tmpSchProdScope) And
--		SAbs.SchemeID = T.SchemeID And
--		SAbs.SchemeID = SSLAB.SchemeID And
--		SSLAB.GroupID = T.GroupID And
--		SSLAB.UOM = 4 And	--Value Based slab
--		@Amount between SSLAB.SlabStart and SSLAB.SlabEnd 
--	
		
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
