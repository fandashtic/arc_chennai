Create Procedure mERP_sp_FindSplCatSchemeID(@InvoiceDate Datetime,@OutletID nVarchar(500),    
@AppliedSchemes nVarChar(2550)='',@CreationDate as nVarchar(50) = N'',@ProductList nvarchar(4000) = '')    
As    
Begin    
    
 Set DateFormat DMY    
-- Declare @CustChannel As nVarchar(255)    
-- Declare @TMDField4  As nVarchar(255)    
    
    
 Declare @OlMapId int    
 Declare @OlChannel nVarchar(255)    
 Declare @OlOutlettype nVarchar(255)    
 Declare @OlLoyalty nVarchar(255)    
 Declare @SchemeID Int    
 Declare @Delimiter Char(1)    
 Set @Delimiter = '|'    
    
    
 Create Table #tmpPrdtScope (SchemeID Int, Product_code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)    
 Create Table #tmpInvProducts (Product_code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)  

 Create Table #tbl_Proctid (PrdtScopeID Int)
 Create Table #tbl_CSSKU (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, Flag Int Default 0)  	  
 Create Table #tbl_CSMrktSKU (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)    
 Create Table #tbl_CSSubCatSKU (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)  
 Create Table #tbl_CSCatSKU  (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)      
 
    
 Declare @CDate Datetime    
 Set @CDate = dbo.striptimefromdate(Cast(@CreationDate as Datetime))    
     
 If @CDate='01 jan 1900'    
  Select @CDate = dbo.striptimefromdate(GetDate())    
     
 set @InvoiceDate = dbo.striptimefromdate(@InvoiceDate)    
    
-- If isNull(@CreationDate,N'') = N''    
--  Select @CreationDate = GetDate()    
--     
-- Set @CreationDate = Cast(@CreationDate as Datetime)    
    
    
 Create Table #AppSchemeList (SchemeIDs Int)   
  Insert Into #AppSchemeList Select * from dbo.sp_SplitIn2Rows(@AppliedSchemes,',')    
    
     
    
 /* Begin: Commented Old Scheme functionality of customerchannel  as New functionality based on OLClass Mapping Implemented */     
 -- Select     
 --   @CustChannel = isNull(ChannelDesc,'') ,     
 --   @TMDField4 = (Select isNull(TMDMas.TMDValue,'') From  Cust_TMD_Master TMDMas ,Cust_TMD_Details TMDDet     
 --       Where TMDMas.TMDCtlPos = 6 And TMDMas.TMDID = TMDDet.TMDID And TMDDet.CustomerID = C.CustomerID)    
 --    From     
 --   Customer  C,Customer_Channel CH    
 -- Where     
 --   C.CustomerID = @OutletID And    
 --   CH.ChannelType = C.ChannelType     
 /* End: Commented Old Scheme functionality of customerchannel as New functionality based on OLClass Mapping Implemented */       
    
    
 /* Begin: New functionality Implemented based on OLClass Mapping */    
    
 Select @OlMapId = isNull(OLClassID,0) from  tbl_Merp_OlclassMapping where CustomerID = @OutletID and Active =1    
    
 Select    
   @OlChannel = isNull(Channel_Type_desc,''),     
   @OlOutlettype = isNull(Outlet_Type_desc,''),    
   @OlLoyalty = isNull(SubOutlet_Type_desc,'')    
 From     
  tbl_merp_Olclass     
 where     
  ID = @OlMapId    
    
 /* End: New functionality Implemented based on OLClass Mapping */    
        
	/* To get Register or Unregister Customer */
	Declare @RegCustomer as nvarchar(100)
	Set @RegCustomer = ''
	Select @RegCustomer = Case When isnull(IsRegistered,0) = 1 Then 'Registered' Else 'UnRegistered' End
	From Customer Where CustomerID = @OutletID
     
 If Not @ProductList = ''    
 Begin    
  Insert into #tmpInvProducts Select * from dbo.sp_SplitIn2Rows(@ProductList,@Delimiter)    
    
  Create Table #tmpCurScheme (SchemeID int)    
  Insert into #tmpCurScheme(schemeID)    
  Select SA.SchemeID From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeOutlet SO,    
  tbl_mERP_SchemeChannel SC, tbl_mERP_SchemeOutletClass SOC,  tbl_mERP_SchemeLoyaltyList SLList    
  Where     
  SA.SchemeID Not In (Select SchemeIDs from #AppSchemeList)      
  And SA.Active  = 1    
  And SA.ApplicableOn = 1    
  And SA.ItemGroup = 2    
And SA.SchemeType in (1,2)    
  /*And SA.SKUCount <= @SKUCount*/    
  And (@invoicedate Between SA.ActiveFrom And SA.ActiveTo)    
  And (@cdate Between ActiveFrom And ExpiryDate)    
  And SA.SchemeID = SO.SchemeID    
  And SO.QPS = 0 --Direct Scheme    
  And (SO.OutletID = @OutletID Or SO.OutletID = N'ALL')    
  And SO.SchemeID = SC.SchemeID    
  And SO.GroupID = SC.GroupID    
  -- And (SC.Channel = @Channel Or SC.Channel = N'ALL')    
  And (SC.Channel = @OlChannel Or SC.Channel = N'All')      
  And SO.SchemeID = SOC.SchemeID    
  And SO.GroupID = SOC.GroupID    
  --And (SOC.OutletClass = @OLClass Or SOC.OutletClass = N'ALL')    
  And (SOC.OutLetClass = @OlOutlettype Or SOC.OutLetClass = N'All')      
  And SO.SchemeID = SLList.SchemeID     
  And SO.GroupID  = SLList.GroupID     
  And (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')   
  and isnull(SA.Color,'') = Case When isnull(SA.Color,'') = '' Then '' Else @RegCustomer End 
  Group By SA.SchemeID    
    
  If exists(select top 1 schemeid from #tmpCurScheme )    
  Begin    
  Declare CurSplCatSchemes Cursor For Select distinct SchemeID from #tmpCurScheme      
  Open CurSplCatSchemes    
  Fetch Next From CurSplCatSchemes Into @SchemeID    
  While (@@Fetch_Status = 0)    
  Begin  
   Delete From #tbl_Proctid   
   Delete From #tbl_CSSKU   
   Delete From #tbl_CSMrktSKU
   Delete From #tbl_CSSubCatSKU
   Delete From #tbl_CSCatSKU  

   insert into #tbl_Proctid Select ProductScopeID From tbl_mERP_SchemeProductScopeMap Where SchemeID = @SCHEMEID  

	if Not  Exists(Select SKUCode From tbl_mERP_SchSKUCodeScope Where SchemeID = @SCHEMEID and ProductScopeID in (select PrdtScopeID From #tbl_Proctid)  And SKUCode= N'ALL')         
		Insert into #tbl_CSSKU    
		Select I.SKUCode, 5 
		from tbl_mERP_SchSKUCodeScope I,#tmpInvProducts tmp Where I.SchemeID = @SCHEMEID and I.ProductScopeID in (select PrdtScopeID From #tbl_Proctid)and I.SKUCode=tmp.Product_Code     
   
	if Exists(Select SKUCode From tbl_mERP_SchSKUCodeScope Where SchemeID = @SCHEMEID and ProductScopeID in (select PrdtScopeID From #tbl_Proctid)  And SKUCode= N'ALL')     
    	Insert into #tbl_CSSKU  (Product_Code,Flag)
		select Product_Code,0 from #tmpInvProducts Where  Product_Code in (select Product_Code from Items Where Active = 1)

	IF Not Exists (Select MarketSKU from tbl_mERP_SchMarketSKUScope Where SchemeID = @SCHEMEID and ProductScopeID in (select PrdtScopeID From #tbl_Proctid)  And MarketSKU =N'ALL')    
	Begin     
		Insert into #tbl_CSMrktSKU 
		Select Items.Product_Code
		from Items ,#tmpInvProducts tmp, ItemCategories ICat, tbl_mERP_SchMarketSKUScope MSKU  
		Where ICat.Level = 4 And   
		ICat.CategoryID = Items.CategoryID And   
		MSKU.MarketSKU = Icat.Category_Name And   
		MSKU.SChemeID = @SCHEMEID And MSKU.ProductScopeID in (select PrdtScopeID From #tbl_Proctid) And   
		ICat.Active = 1 And Items.Active = 1 And  
		Items.Product_Code=tmp.Product_Code  
		-- To Update and delete the Un-matched Products  
		Update PSSKU Set PSSKU.Flag = 1		
		 From #tbl_CSSKU PSSKU, #tbl_CSMrktSKU PSMSKU Where PSSKU.Product_Code = PSMSKU.Product_Code    
		Delete From #tbl_CSSKU Where Flag = 0  	
	End 
	If Not Exists(Select SubCategory from tbl_mERP_SchSubCategoryScope Where SchemeID = @SCHEMEID and ProductScopeID in (select PrdtScopeID From #tbl_Proctid) And SubCategory =N'ALL')    
	Begin    
		Insert into #tbl_CSSubCatSKU  	
		Select Items.Product_code
		From ItemCategories Lev4, ItemCategories Lev3, tbl_mERP_SchSubCategoryScope PSSubCatSKU, Items ,#tmpInvProducts tmp  
		Where Lev3.Level = 3 And Lev4.Level=4 And  
		 Lev4.ParentID = Lev3.CategoryID And   
		 PSSubCatSKU.SChemeID = @SCHEMEID And PSSubCatSKU.ProductScopeID in (select PrdtScopeID From #tbl_Proctid) And   
		 PSSubCatSKU.SubCategory = Lev3.Category_Name And  
		 Items.CategoryID = Lev4.CategoryId And  
		 Lev3.Active = 1 And Items.Active= 1 And  
		 Items.Product_Code = tmp.Product_Code    
		
		Update PSSKU Set PSSKU.Flag = 2		
		From #tbl_CSSKU PSSKU, #tbl_CSSubCatSKU PSSubCatSKU Where PSSKU.Product_Code = PSSubCatSKU.Product_Code    
		Delete From #tbl_CSSKU Where ( Flag = 1 Or Flag = 0)  			
	  End 	

	
	If Not Exists(Select Category from tbl_mERP_SchCategoryScope Where SchemeID = @SCHEMEID and ProductScopeID in (select PrdtScopeID From #tbl_Proctid) And Category =N'ALL')    
    Begin    
		Insert into #tbl_CSCatSKU      
		Select Items.Product_code
		From ItemCategories Lev4, ItemCategories Lev3, ItemCategories Lev2, tbl_mERP_SchCategoryScope CSCatSKU, Items,#tmpInvProducts tmp  
		Where Lev3.Level = 3 And Lev4.Level=4 And Lev2.Level=2 And   
		 CSCatSKU.SChemeID = @SCHEMEID And CSCatSKU.ProductScopeID in (select PrdtScopeID From #tbl_Proctid) And   
		 Lev4.ParentID = Lev3.CategoryID And   
		 Lev3.ParentID = Lev2.CategoryID And   
		 Lev2.Category_Name = CSCatSKU.Category And   
		 Items.CategoryID = Lev4.CategoryId And  
		 Items.Active =1 And Lev2.Active =1 And  
		 Items.Product_Code = tmp.Product_Code  
	  
		Update PSSKU Set PSSKU.Flag = 3	
		From #tbl_CSSKU PSSKU, #tbl_CSCatSKU PSCatSKU Where PSSKU.Product_Code = PSCatSKU.Product_Code    
		Delete From #tbl_CSSKU Where (Flag = 2 or Flag = 1 Or Flag = 0)  
    End  
	--Insert into #tmpPrdtScope Select SchemeID, Product_Code  From dbo.mERP_fn_Get_CSProductScope_New(@SchemeID,@ProductList)    
	Insert into #tmpPrdtScope Select @SCHEMEID, Product_Code From #tbl_CSSKU group by  Product_Code  
   Fetch Next From CurSplCatSchemes Into @SchemeID    
  End    
  Close CurSplCatSchemes    
  Deallocate CurSplCatSchemes    
  End    
  Drop Table #tmpCurScheme    
 End    
             
    
 If Not @ProductList = ''    
 Begin    
    
  Select  S.SchemeID,Description,Min(SO.GroupID) GroupID    
  From     
   tbl_mERP_SchemeAbstract S,tbl_mERP_SchemeOutlet SO,tbl_mERP_SchemeChannel SC,    
   tbl_mERP_SchemeOutletClass  SOLC , tbl_mERP_SchemeLoyaltyList SLList    
  Where S.SchemeID Not In (Select SchemeIDs from #AppSchemeList) And     
   (@InvoiceDate Between ActiveFrom And ActiveTo) And    
   (@Cdate Between ActiveFrom And ExpiryDate) And    
   Active = 1 And    
   S.ApplicableOn = 1 And --1  means ItemBased Scheme    
   s.SchemeType in (1,2) and    
   S.ItemGroup = 2 And    
   S.SchemeID = SO.SchemeID And    
   (SO.OutletID = @OutletID Or SO.OutletID = N'All')  And    
   SO.QPS = 0 And  ---0 - Direct Scheme    
   S.SchemeID = SC.SchemeID And    
   SC.GroupID = SO.GroupID And    
 --  (SC.Channel = @CustChannel Or SC.Channel = N'All')  And     
   (SC.Channel = @OlChannel Or SC.Channel = N'All')  And     
   S.SchemeID = SOLC.SchemeID And    
   SOLC.GroupID = SO.GroupID And    
 --  (SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All')     
   (SOLC.OutLetClass = @OlOutlettype Or SOLC.OutLetClass = N'All')  And    
   S.SchemeID = SLList.SchemeID And    
   SLList.GroupID = SO.GroupID And    
   (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All') And    
   S.SchemeID  In(Select Distinct tmpPS.SchemeID From  #tmpInvProducts tmpIP, #tmpPrdtScope tmpPS Where tmpPS.Product_Code = tmpIP.Product_Code)    
   and isnull(S.Color,'') = Case When isnull(S.Color,'') = '' Then '' Else @RegCustomer End
   Group By  S.SchemeID,Description     
 End    
 Else    
 Begin    
  Select  S.SchemeID,Description,Min(SO.GroupID) GroupID    
  From     
   tbl_mERP_SchemeAbstract S,tbl_mERP_SchemeOutlet SO,tbl_mERP_SchemeChannel SC,    
   tbl_mERP_SchemeOutletClass  SOLC , tbl_mERP_SchemeLoyaltyList SLList    
  Where S.SchemeID Not In (Select SchemeIDs from #AppSchemeList) And     
   (@InvoiceDate Between ActiveFrom And ActiveTo) And    
   (@CDate Between ActiveFrom And ExpiryDate) And    
   Active = 1 And    
   S.ApplicableOn = 1 And --1  means ItemBased Scheme    
   s.SchemeType in (1,2) and    
   S.ItemGroup = 2 And    
   S.SchemeID = SO.SchemeID And    
   (SO.OutletID = @OutletID Or SO.OutletID = N'All')  And    
   SO.QPS = 0 And  ---0 - Direct Scheme    
   S.SchemeID = SC.SchemeID And    
   SC.GroupID = SO.GroupID And    
 --  (SC.Channel = @CustChannel Or SC.Channel = N'All')  And     
   (SC.Channel = @OlChannel Or SC.Channel = N'All')  And     
   S.SchemeID = SOLC.SchemeID And    
   SOLC.GroupID = SO.GroupID And    
 --  (SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All')     
   (SOLC.OutLetClass = @OlOutlettype Or SOLC.OutLetClass = N'All')  And    
   S.SchemeID = SLList.SchemeID And    
   SLList.GroupID = SO.GroupID And    
   (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')    
   and isnull(S.Color,'') = Case When isnull(S.Color,'') = '' Then '' Else @RegCustomer End 
   Group By  S.SchemeID,Description    
 End     
     
 Drop Table #AppSchemeList    
 Drop Table #tmpPrdtScope    
 Drop Table #tmpInvProducts    
 Drop Table #tbl_Proctid   
 Drop Table #tbl_CSSKU   
 Drop Table #tbl_CSMrktSKU
 Drop Table #tbl_CSSubCatSKU
 Drop Table #tbl_CSCatSKU
End 
