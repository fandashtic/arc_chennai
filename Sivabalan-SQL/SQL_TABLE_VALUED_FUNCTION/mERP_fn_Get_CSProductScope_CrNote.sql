Create Function mERP_fn_Get_CSProductScope_CrNote(@SchemeID Int)
Returns @tblCSProducts Table(SchemeID Int, PrdtScopeID Int, Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)   
As
Begin  
DECLARE @PrdtScopeID Int  
DECLARE @tbl_CSSKU Table (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS, Flag Int Default 0)  
DECLARE @tbl_CSMrktSKU Table (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)  
DECLARE @tbl_CSSubCatSKU Table (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)  
DECLARE @tbl_CSCatSKU Table (Product_Code nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS)  
  
Declare CurCSPrductGroup Cursor For  
Select ProductScopeID From tbl_mERP_SchemeProductScopeMap Where SchemeID = @SCHEMEID
Open CurCSPrductGroup
Fetch From CurCSPrductGroup Into @PrdtScopeID
While @@FETCH_STATUS = 0  
Begin   
  If Exists(Select SKUCode From tbl_mERP_SchSKUCodeScope Where SchemeID = @SCHEMEID and ProductScopeID = @PrdtScopeID And SKUCode= N'ALL')   
    Insert into @tbl_CSSKU  
    Select Product_Code, 0 from Items --Where Active = 1
  Else  
    Insert into @tbl_CSSKU  
    Select SKUCode, 0 from tbl_mERP_SchSKUCodeScope Where SchemeID = @SCHEMEID and ProductScopeID = @PrdtScopeID
  
  IF Not Exists (Select MarketSKU from tbl_mERP_SchMarketSKUScope Where SchemeID = @SCHEMEID and ProductScopeID = @PrdtScopeID And MarketSKU =N'ALL')  
  Begin   
    Insert into @tbl_CSMrktSKU
    Select Product_Code from Items, ItemCategories ICat, tbl_mERP_SchMarketSKUScope MSKU
    Where ICat.Level = 4 And 
    ICat.CategoryID = Items.CategoryID And 
    MSKU.MarketSKU = Icat.Category_Name And 
    MSKU.SChemeID = @SCHEMEID And MSKU.ProductScopeID = @PrdtScopeID 
	--And ICat.Active = 1 And Items.Active = 1 
    -- To Update and delete the Un-matched Products
    Update PSSKU Set PSSKU.Flag = 1 From @tbl_CSSKU PSSKU, @tbl_CSMrktSKU PSMSKU Where PSSKU.Product_Code = PSMSKU.Product_Code  
    Delete From @tbl_CSSKU Where Flag = 0
  End   

  If Not Exists(Select SubCategory from tbl_mERP_SchSubCategoryScope Where SchemeID = @SCHEMEID and ProductScopeID = @PrdtScopeID And SubCategory =N'ALL')  
  Begin  
    Insert into @tbl_CSSubCatSKU
    Select Items.Product_code 
    From ItemCategories Lev4, ItemCategories Lev3, tbl_mERP_SchSubCategoryScope PSSubCatSKU, Items
    Where Lev3.Level = 3 And Lev4.Level=4 And
     Lev4.ParentID = Lev3.CategoryID And 
     PSSubCatSKU.SChemeID = @SCHEMEID And PSSubCatSKU.ProductScopeID = @PrdtScopeID And 
     PSSubCatSKU.SubCategory = Lev3.Category_Name And
     Items.CategoryID = Lev4.CategoryId 
	 --And Lev3.Active = 1 And Items.Active= 1 

    Update PSSKU Set PSSKU.Flag = 2 From @tbl_CSSKU PSSKU, @tbl_CSSubCatSKU PSSubCatSKU Where PSSKU.Product_Code = PSSubCatSKU.Product_Code  
    Delete From @tbl_CSSKU Where ( Flag = 1 Or Flag = 0)
  End

  If Not Exists(Select Category from tbl_mERP_SchCategoryScope Where SchemeID = @SCHEMEID and ProductScopeID = @PrdtScopeID And Category =N'ALL')  
  Begin  
    Insert into @tbl_CSCatSKU
    Select Items.Product_code 
    From ItemCategories Lev4, ItemCategories Lev3, ItemCategories Lev2, tbl_mERP_SchCategoryScope CSCatSKU, Items
    Where Lev3.Level = 3 And Lev4.Level=4 And Lev2.Level=2 And 
     CSCatSKU.SChemeID = @SCHEMEID And CSCatSKU.ProductScopeID = @PrdtScopeID And 
     Lev4.ParentID = Lev3.CategoryID And 
     Lev3.ParentID = Lev2.CategoryID And 
     Lev2.Category_Name = CSCatSKU.Category And 
     Items.CategoryID = Lev4.CategoryId
	 --And Items.Active =1 And Lev2.Active =1 

    Update PSSKU Set PSSKU.Flag = 3 From @tbl_CSSKU PSSKU, @tbl_CSCatSKU PSCatSKU Where PSSKU.Product_Code = PSCatSKU.Product_Code  
    Delete From @tbl_CSSKU Where (Flag = 2 or Flag = 1 Or Flag = 0)
  End

  Insert into @tblCSProducts Select @SCHEMEID, @PrdtScopeID, Product_Code From @tbl_CSSKU  
  Delete From @tbl_CSSKU
  Delete From @tbl_CSMrktSKU
  Delete From @tbl_CSSubCatSKU
  Delete From @tbl_CSCatSKU
  Fetch From CurCSPrductGroup Into @PrdtScopeID    
END  
Close CurCSPrductGroup   
Deallocate CurCSPrductGroup  
  
Return   
End  

