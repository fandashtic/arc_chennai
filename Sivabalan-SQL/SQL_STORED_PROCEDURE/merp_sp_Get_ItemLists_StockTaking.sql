Create Procedure merp_sp_Get_ItemLists_StockTaking(@CategoryList nVarchar(MAX), @SubCategoryList nVarchar(MAX), @StockStatus Int = 1, @DisplayUOM Int = 1, @SaleType Int =0)
as
Begin
  /*Generating Categoty ID list*/
  Declare @ChildCategory table(ID int Identity(1,1),CategoryID int)
  Declare @ParentCategory table(CategoryID int)
  Declare @Tax_Code int
  Declare @TaxTypeID int

  IF @CategoryList = N'ALL'
  Begin
    Insert into @ParentCategory
    Select CategoryID from dbo.mERP_fn_CatHandler_GetCategoryList(2,0)
    Where Category_Name Not Like N'ALL'
  End
  Else
  Begin
    Insert into @ParentCategory
    Select CategoryID from dbo.mERP_fn_CatHandler_GetCategoryList(2,0) 
    Where Category_Name Not Like N'ALL' and 
    CategoryID in (select * from dbo.fn_SplitIn2Rows_Int(@CategoryList,','))
  End 

  /*Generating Sub Categoty ID list*/
  IF @SubCategoryList = N'ALL'
  Begin
    Insert into @ChildCategory
    Select ChildCat.CategoryID from dbo.mERP_fn_CatHandler_GetCategoryList(3,0) SubCat, @ParentCategory Cat, 
    ItemCategories ChildCat, ItemCategories ParentCat
    Where SubCat.Category_Name Not Like N'ALL' and 
    ChildCat.Level = 4 and 
    ParentCat.Level = 3 and 
    ChildCat.ParentID = SubCat.CategoryID and 
    ParentCat.ParentID = Cat.CategoryID and 
    SubCat.CategoryID = ParentCat.CategoryID
    Order by ParentCat.ParentID, SubCat.CategoryID, ChildCat.CategoryID
  End
  Else
  Begin
    Insert into @ChildCategory
    Select ChildCat.CategoryID from dbo.mERP_fn_CatHandler_GetCategoryList(3,0) SubCat, @ParentCategory Cat, 
    ItemCategories ChildCat, ItemCategories ParentCat
    Where SubCat.Category_Name Not Like N'ALL' and 
    SubCat.CategoryID in (select * from dbo.fn_SplitIn2Rows_Int(@SubCategoryList,',')) and 
    ChildCat.Level = 4 and 
    ParentCat.Level = 3 and 
    ChildCat.ParentID = SubCat.CategoryID and 
    ParentCat.ParentID = Cat.CategoryID and 
    SubCat.CategoryID = ParentCat.CategoryID
    Order by ParentCat.ParentID, SubCat.CategoryID, ChildCat.CategoryID
  End

  /*Category For Order by Class*/
  Create table #tmpCategoryList(ROWID Int Identity,  
                              Division nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                              SubCategory nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                              MarketSKU nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                              CategoryID Int)
  Insert into #tmpCategoryList
  Select Distinct C2.Category_Name, C1.Category_Name, C.Category_Name, C.CategoryID
  From ItemCategories C, Items  I, ItemCategories C1, ItemCategories C2
  Where C.CategoryID = I.CategoryID
   And C1.Level = 3 
   And C1.CategoryID = C.ParentID
   And C2.Level = 2 
   And C2.CategoryID = C1.ParentID
  Order by C2.Category_Name, C1.Category_Name, C.Category_Name 


  /*With stock without stock filter*/
  Declare @tmpProductList table(Product_Code nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, BatchCode Int Default 0, StockType Int)
  If @StockStatus = 2  /*With Stock*/
  Begin 
    Insert into @tmpProductList
    Select Product_code, Batch_Code, @StockStatus From Batch_Products 
    group by Product_code, Batch_Code  Having Sum(Quantity) > 0 
  End 
  Else If @StockStatus = 3 /*Without Stock*/
  Begin
    Insert into @tmpProductList
    Select Product_code, Batch_Code, @StockStatus From 
    /*[Getting items not exists BatchProducts]*/
    (Select Product_code, 0 as 'Batch_Code' From Items Where Product_Code Not in
    (Select Product_code From Batch_Products group by Product_code)
    Union
    /*[Getting GRN Max BatchCode from BatchProducts]*/
	Select BP.Product_code, Max(BP.Batch_Code) as 'Batch_Code'
	From Batch_products BP, (Select Product_code, Max(IsNull(GRN_ID,0)) GRNID
							 From Batch_Products
							 group by Product_code
							 Having Sum(Quantity) <=0  
							 ) MaxBatch
	Where BP.Product_code = MaxBatch.Product_code And 
	IsNull(BP.GRN_ID,0) = IsNull(MaxBatch.GRNID,0) 
	Group By BP.Product_code) A
  End 
  Else /*both*/
  Begin
    Insert into @tmpProductList
    Select Product_code, Batch_Code, @StockStatus From 
    /*[Getting items not exists BatchProducts]*/
    (Select Product_code, 0 as 'Batch_Code' From Items Where Product_Code Not in
    (Select Product_code From Batch_Products group by Product_code)
    Union
    /*[Getting GRN Max BatchCode from BatchProducts]*/
	Select BP.Product_code, Max(BP.Batch_Code) as 'Batch_Code'
	From Batch_products BP, (Select Product_code, Max(IsNull(GRN_ID,0)) GRNID
							 From Batch_Products
							 group by Product_code
							 Having Sum(Quantity) <=0  
							 ) MaxBatch
	Where BP.Product_code = MaxBatch.Product_code And 
	IsNull(BP.GRN_ID,0) = IsNull(MaxBatch.GRNID,0) 
	Group By BP.Product_code
    Union
    Select Product_code, Batch_Code From Batch_Products 
    group by Product_code, Batch_Code Having Sum(Quantity) > 0) A
  End

  Create table #tmpBatch(
  Product_Code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
  Batch_Code Int, 
  Batch_Number nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
  PKD nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
  Expiry nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
  PTS Decimal(18,6), 
  PTR Decimal(18,6), 
  MRPPerPack Decimal(18,6), 
  TaxSuffered Decimal(18,6), 
  UOM Int, 
  Description nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, StockType Int, Tax_Code int, TaxTypeID int)

  /*Collecting Batch Product info*/
  Insert Into #tmpBatch 
  Select Items.Product_Code, N'', N'', N'', N'', 
  Cast(Items.PTS * (Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion When 3 Then 1 End) as Decimal(18,6)), 
  Cast(Items.PTR * (Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion When 3 Then 1 End) as Decimal(18,6)), 
  --Cast(Items.ECP * (Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion When 3 Then 1 End) as Decimal(18,6)), 
  Items.MRPPerPack,
  Tax.Percentage, 
       Case @DisplayUOM When 3 Then Items.UOM When 2 Then Items.UOM1 When 1 Then Items.UOM2 End UOM, UOM.Description, 0 'StockType'
  ,Tax.Tax_Code, 1 as 'TaxTypeID' 
  From @ChildCategory Cat
  Inner Join Items On Cat.CategoryID = Items.CategoryID
  Left Outer Join Batch_Products BP On Items.Product_Code = BP.Product_code
  Inner Join UOM On UOM.UOM = Case @DisplayUOM When 3 Then Items.UOM When 2 Then Items.UOM1 When 1 Then Items.UOM2 End 
  Inner Join @tmpProductList tmpProducts On Items.Product_Code = tmpProducts.Product_code
  Inner Join TAX On Tax.Tax_code = Items.TaxSuffered
  Where 
   Items.Active = 1 and 
   (IsNull(BP.Damage,0) >= Case @SaleType When 0 then 0 Else 1 End and 
   IsNull(BP.Damage,0) <= Case @SaleType When 0 then 0 Else 2 End) and 
   tmpProducts.BatchCode = 0 
  Union 
  Select Items.Product_Code, BP.Batch_Code, IsNull(BP.Batch_Number,'') Batch_Number, Convert(varchar(10),PKD,103) PKD, 
   Convert(varchar(10),Expiry,103) Expiry, 
  Cast(BP.PTS * (Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion When 3 Then 1 End) as Decimal(18,6)), 
  Cast(BP.PTR * (Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion When 3 Then 1 End) as Decimal(18,6)), 
  --Cast(BP.ECP * (Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion When 3 Then 1 End) as Decimal(18,6)), 
  BP.MRPPerPack,
  BP.TaxSuffered, 
  Case @DisplayUOM When 3 Then Items.UOM When 2 Then Items.UOM1 When 1 Then Items.UOM2 End UOM, UOM.Description, 1 'StockType'
  ,isnull(BP.GRNTaxID,0) as GRNTaxID
  , Case isnull(BP.TaxType,1) When 5 Then isnull(GSTTaxType,1) Else isnull(BP.TaxType,1) End as 'TaxTypeID'
  From @ChildCategory Cat, Items, Batch_Products BP, UOM, @tmpProductList tmpProducts
  Where Cat.CategoryID = Items.CategoryID and 
   UOM.UOM = Case @DisplayUOM When 3 Then Items.UOM When 2 Then Items.UOM1 When 1 Then Items.UOM2 End and 
   Items.Product_Code = tmpProducts.Product_code and 
   Items.Product_Code = BP.Product_code and 
   Items.Active = 1 and 
   BP.Batch_Code = tmpProducts.BatchCode and 
   (IsNull(BP.Damage,0) >= Case @SaleType When 0 then 0 Else 1 End and 
   IsNull(BP.Damage,0) <= Case @SaleType When 0 then 0 Else 2 End) 


  /*Cursor for Grouping Items*/
  Declare @TmpResult Table(Product_Code nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                           Batch_Number nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                           PKD nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                           Expiry nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                           PTS Decimal(18,6), 
                           PTR Decimal(18,6), 
                           MRPPerPack Decimal(18,6), 
                           TaxSuffered Decimal(18,6),
                           UOM Int, 
                           Description nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                           Batch_code nVarchar(max),
                           StockType Int, Tax_Code int, TaxTypeID int)
  Declare @Product_Code nVarchar(30), @Batch_Number nVarchar(255), @PKD nVarchar(50), @Expiry nVarchar(50), @PTS Decimal(18,6), @PTR  Decimal(18,6), @MRPPerPack  Decimal(18,6), @TaxSuffered  Decimal(18,6), @UOM Int, @UOMDesc nVarchar(255), @StockType Int

  /*To insert Single Batch entry*/
  Insert into @TmpResult
  Select tBatch.Product_Code, IsNull(Batch_Number,''), IsNull(PKD,''), IsNull(Expiry,''), PTS, PTR, MRPPerPack, TaxSuffered, UOM, Description, Cast(Batch_code as nVarchar(Max)),tBatch.StockType,tBatch.Tax_Code,tBatch.TaxTypeID
  From #tmpBatch tBatch,(Select Product_Code From #tmpBatch Group By Product_Code Having Count(Product_Code) = 1) Distinct_Prod
  Where tBatch.Product_Code = Distinct_Prod.Product_Code

  /*To insert multiple batch entries*/
  Declare Cur_BatchCode Cursor For 
  Select Distinct Product_Code, IsNull(Batch_Number,''), IsNull(PKD,''), IsNull(Expiry,''), PTS, PTR, MRPPerPack, TaxSuffered, UOM, Description, StockType, Tax_Code, TaxTypeID
  From #tmpBatch Where #tmpBatch.Product_code not in (Select Product_Code From @TmpResult)
  Open Cur_BatchCode
  Fetch next From Cur_BatchCode into @Product_Code, @Batch_Number, @PKD, @Expiry, @PTS, @PTR, @MRPPerPack, @TaxSuffered, @UOM, @UOMDesc, @StockType, @Tax_Code,@TaxTypeID
  While @@Fetch_Status = 0
  Begin
    DECLARE @listStr VARCHAR(MAX)
    /*Batch Code grouping withcomma seperation*/
    Select @listStr = COALESCE(@listStr+N',','')+Cast(Batch_code as nVarchar(Max)) from #tmpBatch
    Where Product_Code = @Product_Code and
        IsNull(Batch_Number,'') = @Batch_Number and 
        IsNull(PKD,'') = @PKD and 
        IsNull(Expiry,'') = @Expiry and 
        PTS = @PTS and
        PTR = @PTR and
        isnull(MRPPerPack,0) = isnull(@MRPPerPack,0) and
        TaxSuffered = @TaxSuffered and 
		isnull(Tax_Code,0) = isnull(@Tax_Code,0) and isnull(TaxTypeID,0) = isnull(@TaxTypeID,0) and
        UOM = @UOM and Batch_code > 0 
    Insert into @TmpResult Values(@Product_Code, @Batch_Number, @PKD, @Expiry, @PTS, @PTR, @MRPPerPack, @TaxSuffered, @UOM, @UOMDesc,@listStr, @StockType, @Tax_Code,@TaxTypeID)
    SET  @listStr = NULL
    Fetch next From Cur_BatchCode into @Product_Code, @Batch_Number, @PKD, @Expiry, @PTS, @PTR, @MRPPerPack, @TaxSuffered,@UOM, @UOMDesc, @StockType, @Tax_Code,@TaxTypeID
  End
  Close Cur_BatchCode
  Deallocate Cur_BatchCode

  Select TR.Product_Code, Items.ProductName, TR.Batch_Number, TR.PKD, TR.PTS, TR.PTR, TR.MRPPerPack, TR.TaxSuffered ,TR.UOM , TR.Description , TR.Batch_code, TR.Tax_Code, TR.TaxTypeID
  From @TmpResult TR, Items, #tmpCategoryList tmpCat
  Where Items.Product_code = TR.Product_code and 
 Items.Active = 1 and 
  tmpCat.CategoryID = Items.CategoryID
  Order by tmpCat.RowID, Items.Product_Code, TR.StockType

  Drop table #tmpBatch
  Drop table #tmpCategoryList
End
