CREATE PROCEDURE sp_update_category_SchemeProducts(@CategoryID int)  
AS
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
	Declare @Level int
	Declare @Category_Name Nvarchar(255)
	Declare @ParentCategory_Name Nvarchar(255)
	Declare @ParentID Int
	Set @Delimiter = '|'  

	Create Table #tmpPrdtScope (SchemeID Int, Product_code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)    
	Create Table #tmpInvProducts (Product_code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Create Table #tbl_Proctid (PrdtScopeID Int)
	Create Table #tbl_CSSKU (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, Flag Int Default 0)  	  
	Create Table #tbl_CSMrktSKU (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)    
	Create Table #tbl_CSSubCatSKU (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)  
	Create Table #tbl_CSCatSKU  (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)      
	Create Table #tmpCurScheme (SchemeID int)  

	select  @Category_Name=Category_Name,@Level = [Level],@ParentID = ParentID from ItemCategories Where CategoryID = @CategoryID  	
	Select @ParentCategory_Name = Category_Name from ItemCategories Where CategoryID = @ParentID
	Insert into #tmpInvProducts select Product_code From Items
	if @Level = 4
	Begin
		Update SchemeProducts SEt Active = 0 Where  Market_SKU = @Category_Name	
       Insert into #tmpCurScheme(schemeID)  select Schemeid from tbl_mERP_SchemeAbstract Where getdate() Between  ActiveFrom and ActiveTo
		And Schemeid in (Select Schemeid From SchemeProducts,ItemCategories Where ItemCategories.CategoryID = @ParentID
						 And  SchemeProducts.Sub_Category = @ParentCategory_Name And SchemeProducts.Active = 1)                          
	End 	
	if @Level = 3
	Begin
		Update SchemeProducts SEt Active = 0 Where  Sub_Category = @Category_Name	
		Insert into #tmpCurScheme(schemeID) 
        select Schemeid from tbl_mERP_SchemeAbstract Where getdate() Between  ActiveFrom and ActiveTo
		And Schemeid in (Select Schemeid From SchemeProducts,ItemCategories Where ItemCategories.CategoryID = @ParentID
						 And  SchemeProducts.Category = @ParentCategory_Name And SchemeProducts.Active = 1)                          
	End 	
	if @Level = 2
	Begin
		Update SchemeProducts SEt Active = 0 Where  Category = @Category_Name		
		Insert into #tmpCurScheme(schemeID)  select Schemeid from tbl_mERP_SchemeAbstract Where getdate() Between  ActiveFrom and ActiveTo
	End 
	
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

		    Insert Into #tbl_Proctid Select ProductScopeID From tbl_mERP_SchemeProductScopeMap Where SchemeID = @SCHEMEID 

		    Declare CurProductScop Cursor For select distinct PrdtScopeID From #tbl_Proctid     
		    Open CurProductScop    
		    Fetch Next From CurProductScop Into @PrdtScopeID    
		    While (@@Fetch_Status = 0)    
			Begin
					Delete From #tbl_Proctid   
			Delete From #tbl_CSSKU   
			Delete From #tbl_CSMrktSKU
			Delete From #tbl_CSSubCatSKU
			Delete From #tbl_CSCatSKU
			
				Insert into #tbl_CSSKU  (Product_Code,Flag)
				Select Product_Code,0 from #tmpInvProducts Where  Product_Code in (select Product_Code from 
                              Items Where Active = 1)
					
				IF @Level = 4
				Begin
					IF Not Exists (Select MarketSKU from tbl_mERP_SchMarketSKUScope Where SchemeID = @SCHEMEID and 
						   ProductScopeID in (@PrdtScopeID)  And MarketSKU =N'ALL')    
					Begin     
						Insert into #tbl_CSMrktSKU 
						Select Items.Product_Code
						from Items ,#tmpInvProducts tmp, ItemCategories ICat, tbl_mERP_SchMarketSKUScope MSKU  
						Where   ICat.CategoryID =  @CategoryID And ICat.Level = 4 And   
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
					IF Not Exists(Select SubCategory from tbl_mERP_SchSubCategoryScope Where SchemeID = @SCHEMEID and ProductScopeID in (@PrdtScopeID) And SubCategory =N'ALL')    
					Begin    
						Insert into #tbl_CSSubCatSKU  	
						Select Items.Product_code
						From ItemCategories Lev4, ItemCategories Lev3, tbl_mERP_SchSubCategoryScope PSSubCatSKU, Items ,#tmpInvProducts tmp  
						Where Lev4.CategoryID =  @CategoryID And  Lev3.Level = 3 And Lev4.Level=4 And  
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
						
					IF Not Exists(Select Category from tbl_mERP_SchCategoryScope Where SchemeID = @SCHEMEID and ProductScopeID in (@PrdtScopeID) And Category =N'ALL')    
					Begin    
						Insert into #tbl_CSCatSKU      
						Select Items.Product_code
						From ItemCategories Lev4, ItemCategories Lev3, ItemCategories Lev2, tbl_mERP_SchCategoryScope CSCatSKU, Items,#tmpInvProducts tmp  
						Where Lev4.CategoryID =  @CategoryID And Lev3.Level = 3 And Lev4.Level=4 And Lev2.Level=2 And   
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
				
				End 

				IF @Level = 3
				Begin					
					IF Not Exists(Select SubCategory from tbl_mERP_SchSubCategoryScope Where SchemeID = @SCHEMEID and ProductScopeID in (@PrdtScopeID) And SubCategory =N'ALL')    
					Begin    
						Insert into #tbl_CSSubCatSKU  	
						Select Items.Product_code
						From ItemCategories Lev4, ItemCategories Lev3, tbl_mERP_SchSubCategoryScope PSSubCatSKU, Items ,#tmpInvProducts tmp  
						Where Lev3.CategoryID =  @CategoryID And  Lev3.Level = 3 And Lev4.Level=4 And  
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
						
					IF Not Exists(Select Category from tbl_mERP_SchCategoryScope Where SchemeID = @SCHEMEID and ProductScopeID in (@PrdtScopeID) And Category =N'ALL')    
					Begin    
						Insert into #tbl_CSCatSKU      
						Select Items.Product_code
						From ItemCategories Lev4, ItemCategories Lev3, ItemCategories Lev2, tbl_mERP_SchCategoryScope CSCatSKU, Items,#tmpInvProducts tmp  
						Where Lev3.CategoryID =  @CategoryID And Lev3.Level = 3 And Lev4.Level=4 And Lev2.Level=2 And   
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
				End 				

				IF @Level = 2
				Begin
					IF Not Exists(Select Category from tbl_mERP_SchCategoryScope Where SchemeID = @SCHEMEID and ProductScopeID in (@PrdtScopeID) And Category =N'ALL')    
					Begin    
						Insert into #tbl_CSCatSKU      
						Select Items.Product_code
						From ItemCategories Lev4, ItemCategories Lev3, ItemCategories Lev2, tbl_mERP_SchCategoryScope CSCatSKU, Items,#tmpInvProducts tmp  
						Where Lev2.CategoryID =  @CategoryID And Lev3.Level = 3 And Lev4.Level=4 And Lev2.Level=2 And   
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
				End 

				Insert Into SchemeProducts (SchemeID,ProductScopeID,Category,Sub_Category,Market_SKU,Product_Code)	
				Select @SCHEMEID,@PrdtScopeID, Lev1.Category_name "Category",Lev2.Category_name "Sub 
				Category",Lev3.Category_name "Market SKU",Items.Product_Code "Product Code"
				From itemCategories lev1,itemCategories lev2,itemCategories lev3,Items Where 
					Items.Product_code in (select  Product_Code From #tbl_CSSKU) And 
					Lev2.Parentid = Lev1.Categoryid  and Lev3.Parentid = Lev2.Categoryid  And 
					Items.Categoryid = Lev3.CategoryID	
	   
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
	Drop Table #tmpPrdtScope		
	Drop Table #tmpInvProducts    
	Drop Table #tbl_Proctid   
	Drop Table #tbl_CSSKU   
	Drop Table #tbl_CSMrktSKU
	Drop Table #tbl_CSSubCatSKU
	Drop Table #tbl_CSCatSKU
End 
