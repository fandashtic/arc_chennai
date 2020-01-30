Create Procedure Sp_Update_SchSKUDetail(@ProductList Nvarchar(15) = 'All')
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
 Declare @Category Nvarchar(255)
 Declare @SubCategory Nvarchar(255)
 Declare @MarketSKU Nvarchar(255)
 Declare @Products Nvarchar(max)
 Declare @ProdcutName Nvarchar(15)
 Declare @DateStart datetime	
  
 Set @Delimiter = '|'    
  select @DateStart = dateadd (day,1,LastInventoryUpload) from setup   
    
 Create Table #tmpPrdtScope (SchemeID Int, Product_code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)    
 Create Table #tmpInvProducts (Product_code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)  

 Create Table #tbl_Proctid (PrdtScopeID Int) 

 Create Table #tmpCurScheme (SchemeID int)  
    
 Declare @CDate Datetime  

 Set @OlMapId = 0
 Set @Products = ''

truncate table temp_Update_SchemeProducts

 If Not @ProductList = ''    
 Begin    
	If  @ProductList = 'All'
		BEGIN			
		Insert Into #tmpInvProducts Select Product_code From Items
		END
	Else If @ProductList = 'IsUpdate'
		BEGIN
		--- Throught SchemeProduct_log Table while receving the items
		Insert Into #tmpInvProducts (Product_code)
		select Product_code From Items Where Product_code IN 
        (Select  Act_ProductCode  from SchemeProducts_log Where IsProcessed= 0 And [Type] = 2 And IsNewItem = 0 )
		END
    Else
		Begin 	 
				--- for individual item 
				if exists (select Product_code From Items Where Product_code = @ProductList and Active = 0)
				Begin
					Update SchemeProducts set Active = 0 Where   Product_Code = @ProductList	
					Goto LastSkip		
				End 
				Insert Into #tmpInvProducts Select Product_code From Items Where Product_code = @ProductList	    
		End   

         if Not exists (select Product_code from #tmpInvProducts)
			Goto LastSkip 
		 if Not exists  (select Items.Product_code From Items,#tmpInvProducts Where Items.Product_code  = #tmpInvProducts.Product_code )	
			Goto LastSkip
	   
		select * into #tbl_mERP_SchemeAbstract From tbl_mERP_SchemeAbstract where ActiveTo >= @DateStart And Active = 1 And SchemeType in (1,2)

		
		
		Select  Lev1.Category_name "Category",Lev2.Category_name "Sub_Category",Lev3.Category_name "Market_SKU",Items.Product_Code "Product_Code"
								Into #tempCategory	
								from itemCategories lev1,itemCategories lev2,itemCategories lev3,Items 
								Where Lev2.Parentid = Lev1.Categoryid  and Lev3.Parentid = Lev2.Categoryid And 
									  Items.Categoryid = Lev3.CategoryID  And Items.Product_code in (select Product_code from #tmpInvProducts) 

		
		select * into #tbl_mERP_SchemeProductScopeMap from tbl_mERP_SchemeProductScopeMap Where Schemeid in (Select  SchemeID From #tbl_mERP_SchemeAbstract)


		
	    Declare CurProducts Cursor For Select Product_code From  #tmpInvProducts		    
        Open CurProducts    
		Fetch Next From CurProducts Into @ProdcutName    
		While (@@Fetch_Status = 0)    
		Begin  			   	
				Insert Into #tmpCurScheme(SchemeID)   
				Select #tbl_mERP_SchemeAbstract.Schemeid from #tbl_mERP_SchemeAbstract,SchemeProducts  Where #tbl_mERP_SchemeAbstract.Schemeid = SchemeProducts.Schemeid And 
				Product_Code In (select Product_code from #tmpInvProducts)  And SchemeProducts.Active = 1  
				
				IF Exists(Select Top 1 SchemeID From #tmpCurScheme )    
				Begin    
					Declare CurSplCatSchemes Cursor For Select distinct SchemeID from #tmpCurScheme      
					Open CurSplCatSchemes    
					Fetch Next From CurSplCatSchemes Into @SchemeID    
					While (@@Fetch_Status = 0)    
					Begin  
					   Truncate Table  #tbl_Proctid
					   Insert Into #tbl_Proctid Select ProductScopeID From #tbl_mERP_SchemeProductScopeMap Where SchemeID = @SCHEMEID  

						Declare CurProductScop Cursor For select distinct PrdtScopeID From #tbl_Proctid     
						Open CurProductScop		
						Fetch Next From CurProductScop Into @PrdtScopeID    
						While (@@Fetch_Status = 0)    
						Begin 
							Set @Category = ''
							SEt @SubCategory = ''
							SEt @MarketSKU = ''
							Select @Category = Category,@SubCategory = Sub_Category,@MarketSKU = Market_SKU
							From SchemeProducts Where SchemeID = @SchemeID and ProductScopeID  = @PrdtScopeID and Product_Code = @ProdcutName
							And Active = 1		
							
							IF @Category <> '' And  @SubCategory <> '' And @MarketSKU <> '' 
           					Begin 
								if (select count(*)  from  #tempCategory where 
													Product_code =  @ProdcutName And
													Market_Sku = @MarketSKU And
													Sub_Category = @SubCategory  And
													Category = @Category) = 0

             					Begin
									
									Update SchemeProducts Set Active = 0 Where  SchemeID = @SchemeID and ProductScopeID  = @PrdtScopeID and Product_Code = @ProdcutName and Active  = 1			
									Set @OlMapId = 1
									Set @Products = @Products + @ProdcutName +  @Delimiter 
									Insert into temp_Update_SchemeProducts values (@ProdcutName)
								End 			
							End 
							Fetch Next From CurProductScop Into @PrdtScopeID    
						End	

						Close CurProductScop    
						Deallocate CurProductScop 	 	
						Fetch Next From CurSplCatSchemes Into @SchemeID    
					End    
					Close CurSplCatSchemes    
					Deallocate CurSplCatSchemes    		
			  End
			  Else			
			  Begin		
			      Set @Products = @Products + @ProdcutName +  @Delimiter
				  Insert into temp_Update_SchemeProducts values (@ProdcutName)
			  End 
			Truncate Table #tmpCurScheme	
			Fetch Next From CurProducts Into @ProdcutName    
       End   
	   Close CurProducts    
	   Deallocate CurProducts  

    -- for insert scheme which related for Products
	IF @Products <> ''
	   Exec Sp_Insert_SchSKUDetail 'IsNewUpdate'
		

--	IF Not Exists(Select Top 1 SchemeID From #tmpCurScheme )  
--		Exec Sp_Insert_SchSKUDetail @ProductList

    If @ProductList = 'IsUpdate'
		Update SchemeProducts_log Set  IsProcessed = 1 Where [Type] = 2 And  IsNewItem = 0  And Act_ProductCode In (select Product_Code from #tmpInvProducts) 
	
	Drop Table #tbl_mERP_SchemeAbstract
	Drop Table #tbl_mERP_SchemeProductScopeMap 
    Drop Table #tempCategory		
End      
LastSkip:
	Drop Table #tmpCurScheme    
	Drop Table #tmpPrdtScope    
	Drop Table #tmpInvProducts    
	Drop Table #tbl_Proctid      
End 
