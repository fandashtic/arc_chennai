Create Procedure sp_print_ReconcileDocumentDetail (@ReconcileID Integer)      
As      
Begin  
Declare @STK_STATUS as Int  
Declare @DisplayUOM Int   
Declare @DamageStock Int   
Select @STK_STATUS = StockStatus, @DisplayUOM = IsNull(UOM,1), @DamageStock = IsNull(DamageStock,0) From ReconcileAbstract Where ReconcileID = @ReconcileID  
  
  
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
  
/*Getting the batch selection info on stk taking*/  
Declare @tmpBatchProducts table (Product_Code nVarchar(30), Batch_Code int)  
  
Insert into @tmpBatchProducts   
Select Product_code, Batch_code From ReconcileDetail Where ReconcileID = @ReconcileID and CharIndex(',', Batch_code) = 0 and IsNull(NewBatch,0) = 0  
  
Declare @Batch_Code nVarchar(Max)   
Declare @Product_Code nVarchar(30)  
Declare Cur_Prdt_batch Cursor For  
Select Product_code, Batch_code From ReconcileDetail Where ReconcileID = @ReconcileID and CharIndex(',', Batch_code) > 0   
Open Cur_Prdt_batch  
Fetch Next From Cur_Prdt_batch into @Product_Code, @Batch_Code  
  While @@Fetch_Status = 0   
  Begin  
    Insert into @tmpBatchProducts  
    Select @Product_Code, * from dbo.fn_SplitIn2Rows_Int(@Batch_Code,',')  
    Fetch Next From Cur_Prdt_batch into @Product_Code, @Batch_Code  
  End  
Close Cur_Prdt_batch  
Deallocate Cur_Prdt_batch  
  
  
/*To include additional batches non exists while Stock Taking*/  
Insert into @tmpBatchProducts  
Select BP.Product_code, BP.Batch_code  
from Batch_products BP, @tmpBatchProducts tBatch  
Where BP.Product_code = tBatch.Product_code and  
IsNull(BP.Damage,0) >= (Case @DamageStock When 0 then 0 Else 1 End) and   
IsNull(BP.Damage,0) <= (Case @DamageStock When 0 then 0 Else 2 End) and   
BP.Batch_code not in (Select Batch_code From @tmpBatchProducts)  
Group By BP.Product_code, BP.Batch_code  
Having Sum(BP.Quantity) > 0   
   
  
/*to find any batch exists with stock*/  
Declare @Batch_Count Int   
Select @Batch_Count = Count(Batch_Code) From @tmpBatchProducts where Batch_Code > 0   
  
If IsNull(@Batch_Count,0) = 0 /*Without Stock*/  
  Begin  
  Select ReconcileDetail.Product_Code as 'Product Code', Items.ProductName as 'Product Name', N'' as 'Batch', N'' as 'PKD', N'' as 'Expiry',  
  Cast((Items.PTS * Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion Else 1 End) as Decimal(18,6)) as PTS,   
  Cast((Items.PTR * Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion Else 1 End) as Decimal(18,6)) as PTR,   
  Cast((Items.ECP * Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion Else 1 End) as Decimal(18,6)) as ECP,   
  isnull(items.MRPPerPack,0) as 'MRP Per Pack',
  Tax.Percentage as 'TaxSuffered', UOM.Description as 'UOM', '' as 'Physical Stock', '' as 'Reason', Tax.Tax_Code as 'Tax_Code', 1 as 'TaxTypeID'  
  From ReconcileDetail, Items, ReconcileAbstract, UOM, Tax, #tmpCategoryList tmpCat  
  Where ReconcileDetail.ReconcileID = @ReconcileID and   
        ReconcileAbstract.ReconcileID = ReconcileDetail.ReconcileID and   
        ReconcileDetail.Product_Code = Items.Product_Code and    
        IsNull(ReconcileDetail.NewBatch,0) = 0 and   
        tmpCat.CategoryId = Items.CategoryID and   
        UOM.UOM = Case IsNull(ReconcileAbstract.UOM,1) When 1 Then Items.UOM2 When 2 Then Items.UOM1 Else Items.UOM End and   
        Tax.Tax_code = Items.TaxSuffered  
  Order by tmpCat.RowID, Items.Product_Code  
  End  
Else  
  Begin  
  /*To Print the Item with Zero-as-Batch Code*/  
  Select "Product Code" = Items.Product_Code, "Product Name" = Items.ProductName, "Batch" =A.Batch,   
  "PKD" = IsNull(Convert(varchar(10),A.PKD,103),''),   
  "Expiry" = IsNull(Convert(varchar(10),A.Expiry,103),''),  
--"PTS" = A.PTS, "PTR" = A.PTR, "ECP" = A.ECP, "TaxSuffered" = A.TaxSuffered, "UOM" = A.Description, "Physical Stock" = '', "Reason" = N''  
  "PTS" = A.PTS, "PTR" = A.PTR, 
"MRP Per Pack" = A.MRPPerPack, 
"TaxSuffered" = A.TaxSuffered, "UOM" = A.Description, "Physical Stock" = '', "Reason" = N'', A.Tax_Code, A.TaxTypeID 	
  From   
  (Select tmpBP.Product_Code as 'Product_Code', Items.ProductName as 'ProductName', N'' as 'Batch', N'' as 'PKD', N'' as 'EXPIRY',   
     Cast((ITEMs.PTS * Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion Else 1 End) as Decimal(18,6)) as 'PTS',   
     Cast((ITEMs.PTR * Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion Else 1 End) as Decimal(18,6)) as 'PTR',    
  --   Cast((ITEMs.ECP * Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion Else 1 End) as Decimal(18,6)) as 'ECP',   
     isnull(items.MRPPerPack,0) as 'MRPPerPack',
     IsNull(Tax.Percentage,0) as 'TaxSuffered', UOM.Description, Tax.Tax_Code as 'Tax_Code' , 1 as 'TaxTypeID' 
  From ReconcileAbstract RA, Items, UOM, Tax, --ReconcileDetail RD  
       (Select Product_Code, Batch_code From @tmpBatchProducts Where IsNull(Batch_code,0) = 0 ) tmpBP  
  Where RA.ReconcileID = @ReconcileID and   
      tmpBP.Product_Code = Items.Product_Code and   
      tmpBP.Batch_Code = 0 and    
      tax.Tax_Code = Items.TaxSuffered and   
      UOM.UOM = Case IsNull(RA.UOM,1) When 1 Then Items.UOM2 When 2 Then Items.UOM1 Else Items.UOM End   
--  Group by tmpBP.Product_Code, Items.ProductName, Items.PTR, Items.PTS, Items.ECP, IsNull(Tax.Percentage,0), UOM.Description,  
  Group by tmpBP.Product_Code, Items.ProductName, Items.PTR, Items.PTS, Items.MRPPerPack, IsNull(Tax.Percentage,0), UOM.Description,  	
      Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion Else 1 End, Tax.Tax_Code  
  Union   
  /*To Print Non-Zero Batch Code items*/  
  Select tmpBP.Product_Code as 'Product_Code',  Items.ProductName as 'ProductName', IsNull(BP.Batch_number,'') as 'Batch',  
     Case IsNull(Convert(nVarchar(10),BP.PKD,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.PKD,103),4,Len(Convert(nVarchar(10),BP.PKD,103))) End  as 'PKD',   
     Case IsNull(Convert(nVarchar(10),BP.Expiry,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.Expiry,103),4,Len(Convert(nVarchar(10),BP.Expiry,103))) End as 'Expiry',   
     Cast((BP.PTS * Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion Else 1 End) as Decimal(18,6)) as 'PTS',   
     Cast((BP.PTR * Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion Else 1 End) as Decimal(18,6)) as 'PTR',    
   --  Cast((BP.ECP * Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion Else 1 End) as Decimal(18,6)) as 'ECP',   
    isnull(BP.MRPPerPack,0) as 'MRPPerPack',
     IsNull(BP.TaxSuffered,0) as 'TaxSuffered', UOM.Description, isnull(BP.GRNTaxID,0) as 'Tax_Code'
	, Case isnull(BP.TaxType,1) When 5 Then isnull(GSTTaxType,1) Else isnull(BP.TaxType,1) End as 'TaxTypeID'   
  From ReconcileAbstract RA, Items, Batch_Products BP, UOM,   
  (Select Product_Code, Batch_code From @tmpBatchProducts Where IsNull(Batch_code,0) > 0 )tmpBP  
  Where RA.ReconcileID = @ReconcileID and   
      BP.Product_Code = Items.Product_Code and   
      IsNull(BP.StockReconID,0) < @ReconcileID and  /*To consider only the items created Before selected Reconcilation*/  
      tmpBP.Batch_Code = BP.Batch_Code and    
      UOM.UOM = Case IsNull(RA.UOM,1) When 1 Then Items.UOM2 When 2 Then Items.UOM1 Else Items.UOM End   
  Group by tmpBP.Product_Code, Items.ProductName, IsNull(BP.Batch_number,''),  
      Case IsNull(Convert(nVarchar(10),BP.PKD,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.PKD,103),4,Len(Convert(nVarchar(10),BP.PKD,103))) End,   
      Case IsNull(Convert(nVarchar(10),BP.Expiry,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.Expiry,103),4,Len(Convert(nVarchar(10),BP.Expiry,103))) End,   
      --BP.PTR, BP.PTS, BP.ECP, IsNull(BP.TaxSuffered,0), UOM.Description,   
	  BP.PTR, BP.PTS, BP.MRPPerPack, IsNull(BP.TaxSuffered,0), UOM.Description, isnull(BP.GRNTaxID,0), isnull(BP.TaxType,1), isnull(GSTTaxType,1),
      Case @DisplayUOM When 1 Then Items.UOM2_Conversion When 2 Then Items.UOM1_Conversion Else 1 End)A, ITEMS, #tmpCategoryList tmpCat  
  Where  A.Product_Code = Items.Product_code and   
  tmpCat.CategoryId = Items.CategoryID   
  Order by tmpCat.RowID, Items.Product_code  
	
  End   
  Drop table #tmpCategoryList   
End  
