Create Procedure Sp_Insert_SchSKUDetail(@ProductList Nvarchar(Max) = 'All')
As    
Begin    
    
 Set DateFormat DMY    
 Declare @OlMapId int    
 Declare @OlChannel nVarchar(255)    
 Declare @OlOutlettype nVarchar(255)    
 Declare @OlLoyalty nVarchar(255)    
 Declare @SchemeID Int    
 Declare @Delimiter Char(1) 
 Declare @PrdtScopeID int  
 Declare @MarketSKU nVarchar(255)
 Declare @SubCat Nvarchar(255)
 Declare @Cat Nvarchar(255)
 Declare @DateStart datetime
 Declare @MrktParentid int 
 Declare @subcatParentid int 
 Declare @catParentid int 
 Set @Delimiter = '|' 
 Set @MrktParentid = -1   
 Set @subcatParentid = -1   
 Set @catParentid = -1   
    
 select @DateStart = dateadd (day,1,LastInventoryUpload) from setup   
 Create Table #tmpPrdtScope (SchemeID Int, Product_code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)    
 Create Table #tmpInvProducts (Product_code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)  

 Create Table #tbl_Proctid (PrdtScopeID Int)
 Create Table #tbl_CSSKU (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, Flag Int Default 0)  	  
 Create Table #tbl_CSMrktSKU (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)    
 Create Table #tbl_CSSubCatSKU (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)  
 Create Table #tbl_CSCatSKU  (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)    

 CREATE TABLE #tbl_SchemeProducts(
	[SchemeID] [int] NULL,
	[ProductScopeID] [int] NULL,
	[Category] [nvarchar](250)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Sub_Category] [nvarchar](250)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Market_SKU] [nvarchar](250)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product_Code] [nvarchar](15)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	)
	  
     
 Declare @CDate Datetime    
     
 If @CDate='01 jan 1900'    
  Select @CDate = dbo.striptimefromdate(GetDate())    
           
 Create Table #AppSchemeList (SchemeIDs Int)   
      
 Select    
   @OlChannel = isNull(Channel_Type_desc,''),     
   @OlOutlettype = isNull(Outlet_Type_desc,''),    
   @OlLoyalty = isNull(SubOutlet_Type_desc,'')    
 From     
  tbl_merp_Olclass     
 where     
  ID = @OlMapId    
    
 /* End: New functionality Implemented based on OLClass Mapping */    
      
 If Not @ProductList = ''    
 Begin    
   If  @ProductList = 'All'
   Begin	
	 Insert into #tmpInvProducts select Product_code From Items
   End 
   Else If  @ProductList = 'IsNew' 
   Begin
       Insert into #tmpInvProducts (Product_code)
	   select Product_code From Items Where Product_code IN 
      (Select  Act_ProductCode  from SchemeProducts_log Where IsProcessed= 0 And [Type] = 2 And IsNewItem = 1 )
   End 
   Else If  @ProductList = 'IsNewUpdate' 
   Begin
	   Insert into #tmpInvProducts (Product_code)
	   select Product_code From Items Where Product_code IN (select Product_code From temp_Update_SchemeProducts)
   End 		
   Else
   Begin
		 Insert into #tmpInvProducts Select * from dbo.sp_SplitIn2Rows(@ProductList,@Delimiter)
   End 	  


   Select  Lev1.Category_name "Category" Into #tempCategory	
					from itemCategories lev1,itemCategories lev2,itemCategories lev3,Items 
					Where Lev2.Parentid = Lev1.Categoryid  and Lev3.Parentid = Lev2.Categoryid And 
					Items.Categoryid = Lev3.CategoryID  And Items.Product_code in (select Product_code from #tmpInvProducts)  
  	
  Create Table #tmpCurScheme (SchemeID int)  
  --Base on Product Category moving the Schemes
  Insert into #tmpCurScheme(schemeID)
  select A.Schemeid  AS Schemeid from tbl_mERP_SchemeAbstract A,tbl_mERP_SchCategoryScope S 
								Where A.SChemeid = S.Schemeid And
							          ActiveTo  >= @DateStart And SchemeType in (1,2)  And 
                                      category in (select distinct category from #tempCategory)
  

  select * Into #tbl_mERP_SchSKUCodeScope from tbl_mERP_SchSKUCodeScope Where Schemeid in (Select Schemeid From #tmpCurScheme)
  select * into #tbl_mERP_SchemeProductScopeMap from tbl_mERP_SchemeProductScopeMap Where Schemeid in (Select Schemeid From #tmpCurScheme)
  select * into #tbl_mERP_SchMarketSKUScope From tbl_mERP_SchMarketSKUScope	Where Schemeid in (Select Schemeid From #tmpCurScheme)
  select * into #tbl_mERP_SchSubCategoryScope  from  tbl_mERP_SchSubCategoryScope Where SchemeID in (Select Schemeid From #tmpCurScheme)	   
  select * into #tbl_mERP_SchCategoryScope From tbl_mERP_SchCategoryScope Where SchemeID in (Select Schemeid From #tmpCurScheme)	   
  
  if Not exists (select Product_code from #tmpInvProducts)
	 Goto LastRec 
  if Not exists  (select Items.Product_code From Items,#tmpInvProducts Where Items.Product_code  = #tmpInvProducts.Product_code )	
	 Goto LastRec

  If exists(select top 1 schemeid from #tmpCurScheme )    
  Begin    
  Declare CurSplCatSchemes Cursor For Select distinct SchemeID from #tmpCurScheme      
  Open CurSplCatSchemes    
  Fetch Next From CurSplCatSchemes Into @SchemeID    
  While (@@Fetch_Status = 0)    
  Begin  


	  insert into #tbl_Proctid Select ProductScopeID From #tbl_mERP_SchemeProductScopeMap Where SchemeID = @SCHEMEID  

      Declare CurProductScop Cursor For select distinct PrdtScopeID From #tbl_Proctid     
	  Open CurProductScop    
	  Fetch Next From CurProductScop Into @PrdtScopeID    
	  While (@@Fetch_Status = 0)    
	  Begin 
			
			if Not  Exists(Select SKUCode From #tbl_mERP_SchSKUCodeScope Where SchemeID = @SCHEMEID and ProductScopeID in (@PrdtScopeID)  And SKUCode= N'ALL')         
				Insert into #tbl_CSSKU    
				Select I.SKUCode, 5 
				from #tbl_mERP_SchSKUCodeScope I,#tmpInvProducts tmp Where I.SchemeID = @SCHEMEID and I.ProductScopeID in (@PrdtScopeID)and I.SKUCode=tmp.Product_Code  
				And I.SKUCode in (select Product_Code from Items Where Active = 1)	   
		   
			if Exists(Select SKUCode From #tbl_mERP_SchSKUCodeScope Where SchemeID = @SCHEMEID and ProductScopeID in (@PrdtScopeID)  And SKUCode= N'ALL')     
    			Insert into #tbl_CSSKU  (Product_Code,Flag)
				select Product_Code,0 from #tmpInvProducts Where  Product_Code in (select Product_Code from Items Where Active = 1)

			IF Not Exists (Select MarketSKU from #tbl_mERP_SchMarketSKUScope Where SchemeID = @SCHEMEID and ProductScopeID in (@PrdtScopeID)  And MarketSKU =N'ALL')    
			Begin     
				Insert into #tbl_CSMrktSKU 
				Select Items.Product_Code
				from Items ,#tmpInvProducts tmp, ItemCategories ICat, #tbl_mERP_SchMarketSKUScope MSKU  
				Where ICat.Level = 4 And   
				ICat.CategoryID = Items.CategoryID And   
				MSKU.MarketSKU = Icat.Category_Name And   
				MSKU.SChemeID = @SCHEMEID And MSKU.ProductScopeID in (@PrdtScopeID) And   
				ICat.Active = 1 And Items.Active = 1 And  
				Items.Product_Code=tmp.Product_Code  
				-- To Update and delete the Un-matched Products  
				Update PSSKU Set PSSKU.Flag = 1		
				 From #tbl_CSSKU PSSKU, #tbl_CSMrktSKU PSMSKU Where PSSKU.Product_Code = PSMSKU.Product_Code    
				Delete From #tbl_CSSKU Where Flag = 0  	
			End 
			If Not Exists(Select SubCategory from #tbl_mERP_SchSubCategoryScope Where SchemeID = @SCHEMEID and ProductScopeID in (@PrdtScopeID) And SubCategory =N'ALL')    
			Begin    
				Insert into #tbl_CSSubCatSKU  	
				Select Items.Product_code
				From ItemCategories Lev4, ItemCategories Lev3, #tbl_mERP_SchSubCategoryScope PSSubCatSKU, Items ,#tmpInvProducts tmp  
				Where Lev3.Level = 3 And Lev4.Level=4 And  
				 Lev4.ParentID = Lev3.CategoryID And   
				 PSSubCatSKU.SChemeID = @SCHEMEID And PSSubCatSKU.ProductScopeID in (@PrdtScopeID) And   
				 PSSubCatSKU.SubCategory = Lev3.Category_Name And  
				 Items.CategoryID = Lev4.CategoryId And  
				 Lev3.Active = 1 And Items.Active= 1 And  
				 Items.Product_Code = tmp.Product_Code    
				
				Update PSSKU Set PSSKU.Flag = 2		
				From #tbl_CSSKU PSSKU, #tbl_CSSubCatSKU PSSubCatSKU Where PSSKU.Product_Code = PSSubCatSKU.Product_Code    
				Delete From #tbl_CSSKU Where ( Flag = 1 Or Flag = 0)  			
			  End 	
			
			If Not Exists(Select Category from #tbl_mERP_SchCategoryScope Where SchemeID = @SCHEMEID and ProductScopeID in (@PrdtScopeID) And Category =N'ALL')    
			Begin    
				Insert into #tbl_CSCatSKU      
				Select Items.Product_code
				From ItemCategories Lev4, ItemCategories Lev3, ItemCategories Lev2, #tbl_mERP_SchCategoryScope CSCatSKU, Items,#tmpInvProducts tmp  
				Where Lev3.Level = 3 And Lev4.Level=4 And Lev2.Level=2 And   
				 CSCatSKU.SChemeID = @SCHEMEID And CSCatSKU.ProductScopeID in (@PrdtScopeID) And   
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
			
			Insert into #tbl_SchemeProducts (SchemeID,ProductScopeID,Category,Sub_Category,Market_SKU,Product_Code)			
			Select @SCHEMEID,@PrdtScopeID, Lev1.Category_name "Category",Lev2.Category_name "Sub Category",Lev3.Category_name "Market SKU",Items.Product_Code "Product Code"
						from itemCategories lev1,itemCategories lev2,itemCategories lev3,Items Where Items.Product_code in (select  Product_Code From #tbl_CSSKU) And 
						Lev2.Parentid = Lev1.Categoryid  and Lev3.Parentid = Lev2.Categoryid  And Items.Categoryid = Lev3.CategoryID		   
			
		If exists(Select Cat.SchemeID
		From
			 #tbl_mERP_SchCategoryScope Cat,#tbl_mERP_SchSubCategoryScope SubCat,
			 #tbl_mERP_SchMarketSKUScope MarSKU,#tbl_mERP_SchSKUCodeScope SKU,#tbl_SchemeProducts SP
		Where 
		     Cat.SchemeID  = SP.SchemeID And
			 SP.ProductScopeID = Cat.ProductScopeID And  		
			 Cat.ProductScopeID = SubCat.ProductScopeID And
			 SubCat.ProductScopeID = MarSKU.ProductScopeID And
			 MarSKU.ProductScopeID = SKU.ProductScopeID And
			 (Cat.Category = SP.Category Or Cat.Category = 'All') And
			 (SubCat.SubCategory = SP.Sub_Category Or SubCat.SubCategory = 'All') And
			 (MarSKU.MarketSKU = SP.Market_SKU Or MarSKU.MarketSKU = 'All') And
			 (SKU.SKUCode = SP.Product_Code Or SKU.SKUCode = 'All') )
		Begin
			Insert into SchemeProducts (SchemeID,ProductScopeID,Category,Sub_Category,Market_SKU,Product_Code)			
			select SchemeID,ProductScopeID,Category,Sub_Category,Market_SKU,Product_Code From #tbl_SchemeProducts
		End
		Else
		Begin
			Insert into SchemeProducts (SchemeID,ProductScopeID,Category,Sub_Category,Market_SKU,Product_Code,Active)			
			select SchemeID,ProductScopeID,Category,Sub_Category,Market_SKU,Product_Code,0 From #tbl_SchemeProducts 
		End 
		
		Truncate Table #tbl_Proctid   
		Truncate Table #tbl_CSSKU   
		Truncate Table #tbl_CSMrktSKU
		Truncate Table #tbl_CSSubCatSKU
		Truncate Table #tbl_CSCatSKU
		Truncate Table #tbl_SchemeProducts 	
	   Fetch Next From CurProductScop Into @PrdtScopeID    
   End
   Close CurProductScop    
   Deallocate CurProductScop  	
   Fetch Next From CurSplCatSchemes Into @SchemeID    
  End    
  Close CurSplCatSchemes    
  Deallocate CurSplCatSchemes    
  End    
  Drop Table #tmpCurScheme    
 End 
	
 If  @ProductList = 'IsNew'
	 Update SchemeProducts_log Set  IsProcessed = 1 Where [Type] = 2 And  IsNewItem = 1  And Act_ProductCode In (select Product_Code from #tmpInvProducts) 

LastRec:
 Drop Table #AppSchemeList    
 Drop Table #tmpPrdtScope    
 Drop Table #tmpInvProducts    
 Drop Table #tbl_Proctid   
 Drop Table #tbl_CSSKU   
 Drop Table #tbl_CSMrktSKU
 Drop Table #tbl_CSSubCatSKU
 Drop Table #tbl_CSCatSKU
 Drop Table #tbl_SchemeProducts
 Drop Table #tbl_mERP_SchSKUCodeScope
Drop Table #tbl_mERP_SchemeProductScopeMap
 Drop Table #tbl_mERP_SchMarketSKUScope
 DRop Table #tbl_mERP_SchSubCategoryScope
 Drop Table #tbl_mERP_SchCategoryScope
 Drop Table #tempCategory
End 
