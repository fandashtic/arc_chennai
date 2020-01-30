
Create Procedure [dbo].[mERP_SP_ListApplicableITemScheme]  
(@SKUCode as nvarchar (30),  
@Invoicedate as DATETIME,  
@OutletID as nvarchar(30)=N'',  
@CreationDate as nvarchar(30)=N''  
)  
As  
Begin  
	Declare @CustChannel As nVarchar(255)  
	Declare @OLClass  As nVarchar(255)  
	Declare @MarKetSKU as nVarchar(255)  
	Declare @SubCat as nVarchar(255)  
	Declare @Category as nVarchar(255)  
	Declare @CategoryID as Int  
	Declare @SubCategoryID as Int  
	Declare @UOM1_Conversion as Decimal(18,6)  
	Declare @UOM2_Conversion as Decimal(18,6)  
	Declare @SchemeID Int  
	Declare @ScopeID Int  
	  
	Declare @OlMapId int  
	Declare @OlChannel nVarchar(255)  
	Declare @OlOutlettype nVarchar(255)  
	Declare @OlLoyalty nVarchar(255)  	  
	  
	If (@CreationDate ='')  
		Set @CreationDate = getdate()  
	Else  
		Select @CreationDate = Convert(Datetime, @CreationDate)  
	  
	  
	Create Table #tmpScheme(SchemeID Int,GroupID Int)  
	Create Table #tmpSchProdScope(SchemeID Int,ProductScopeID Int)  
	--Create Table #tmpSlab(SchemeID Int,RecSchemeID Int,Description nVarchar(500) Collate SQL_Latin1_General_CP1_CI_AS,SlabType Int,SlabID Int,UOM Int,SlabStart Decimal(18,6))  
	--Create Table #tmpOutput(SchemeID Int,SchemeCode nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,Description nVarchar(500) Collate SQL_Latin1_General_CP1_CI_AS,SlabType Int,SlabID Int)  
	  
	  
	/* Begin: Commented Old Scheme functionality as New functionality based on OLClass Mapping Implemented */  
	 --Select @CustChannel = ChannelDesc From Customer_Channel CC, Customer C  
	 --Where C.CustomerID = @OutletID  
	 --And CC.ChannelType = C.ChannelType  
	 --  
	 --Select @OLClass = CM.TMDValue From Cust_TMD_Master CM, Cust_TMD_Details CD  
	 --Where CM.TMDID = CD.TMDID  
	 --And CD.CustomerID = @OutletID  
	 --And CM.TMDCtlPos = 6  
	/* End: Commented Old Scheme functionality as New functionality based on OLClass Mapping Implemented */  
	  
	/* Begin: New functionality Implemented based on OLClass Mapping */  
	 Select @OlMapId = IsNull(OLClassID,0) from  tbl_Merp_OlclassMapping where CustomerID = @OutletID and Active =1  
	 Select @OlChannel = IsNull(Channel_TYpe_desc,''), @OlOutlettype = IsNull(Outlet_Type_desc,''),   
	 @OlLoyalty= IsNull(SubOutlet_Type_desc,'')  
	 From tbl_merp_Olclass where ID = @OlMapId  
	/* End: New functionality Implemented based on OLClass Mapping */  

	/* To get Register or Unregister Customer */
	Declare @RegCustomer as nvarchar(100)
	Set @RegCustomer = ''
	Select @RegCustomer = Case When isnull(IsRegistered,0) = 1 Then 'Registered' Else 'UnRegistered' End
	From Customer Where CustomerID = @OutletID      
	  
	Select @MarKetSKU = Category_Name,@SubCategoryID = ParentID  
	From ItemCategories Where CategoryID =  
	(Select CategoryID From Items Where Product_Code = @SKUCode)  
	Select  @SubCat = Category_Name,@CategoryID = ParentID From ItemCategories Where CategoryID = @SubCategoryID  
	  
	Select  @Category = Category_Name  From ItemCategories Where CategoryID = @CategoryID  
	  
	Select @UOM1_Conversion = IsNull(UOM1_Conversion,1), @UOM2_Conversion = IsNull(UOM2_Conversion,1) From Items Where Product_code = @SKUCode  
	  
	Insert Into #tmpScheme  
	Select Distinct S.SchemeID,Min(SO.GroupID)  
	From  
	tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,tbl_mERP_SchemeChannel SC ,  
	tbl_mERP_SchemeOutletClass  SOLC,  tbl_mERP_SchemeLoyaltyList SLList  
	Where  
	(dbo.stripTimeFromDate(@InvoiceDate) Between dbo.stripTimeFromDate(ActiveFrom) And dbo.stripTimeFromDate(ActiveTo)) And  
	(dbo.stripTimeFromDate(@CreationDate) Between dbo.stripTimeFromDate(ActiveFrom) And dbo.stripTimeFromDate(ExpiryDate)) And  
	Active = 1 And  
	S.ApplicableOn = 1 And --1  means ItemBased Scheme  
	s.SchemeType in (1,2) and   
	S.ItemGroup = 1 And  
	S.SchemeID = SO.SchemeID And  
	(SO.OutletID = @OutletID Or SO.OutletID = N'All')  And  
	SO.QPS = 0 And  ---0 - Direct Scheme  
	S.SchemeID = SC.SchemeID And  
	SC.GroupID = SO.GroupID And  
	-- (SC.Channel = @CustChannel Or SC.Channel = N'All')  And  
	(SC.Channel = @OlChannel Or SC.Channel = N'All')  And   
	S.SchemeID = SOLC.SchemeID And  
	SOLC.GroupID = SO.GroupID And  
	--(SOLC.OutLetClass = @OLClass Or SOLC.OutLetClass = N'All')  
	(SOLC.OutLetClass = @OlOutlettype Or SOLC.OutLetClass = N'All')  And  
	S.SchemeID = SLList.SchemeID And  
	SLList.GroupID = SO.GroupID And  
	(SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')  
	and isnull(S.Color,'') = Case When isnull(S.Color,'') = '' Then '' Else @RegCustomer End
	Group By S.SchemeID  
	  
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
			From tbl_mERP_SchCategoryScope Cat,tbl_mERP_SchSubCategoryScope SubCat,  
			tbl_mERP_SchMarketSKUScope MarSKU,tbl_mERP_SchSKUCodeScope SKU  
			Where Cat.ProductScopeID = SubCat.ProductScopeID And  
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
	  
	Select SABS.SchemeID, CS_RecSchID, ActivityCode, Description, ActiveFrom, ActiveTo, CSAppType.ApplicableOn, CSIGrp.ItemGroup, GroupID, SABS.ApplicableOn, SABS.ItemGroup  
	--case when SchemeType=1 then 'SP' when SchemeType=2 then 'CP' else '' end,  
	--case when ApplicableOn=1 Then 'Line' when ApplicableOn=2 then 'Invoice' else '' end,  
	ActiveFrom,ActiveTo,GroupID  
	From tbl_mERP_schemeAbstract SABS,#tmpScheme T,  
	tbl_mERP_SchemeItemGroup CSIGrp, tbl_mERP_SchemeApplicableType CSAppType  
	Where SABS.SchemeID in (select distinct SchemeID from #tmpSchProdScope) And  
	SABS.SchemeID = T.SchemeID And  
	SABS.ItemGroup = CSIGrp.ID And  
	SABS.ApplicableOn = CSAppType.ID  
	  
	  
	Drop table #tmpSchProdScope  
	Drop table #tmpScheme  
End  
