CREATE Procedure sp_Get_Stock_Reconcile_Quantity(@Reconcile Int, @Damage Int)  
As  
Begin
Create Table #tmpBatchGrp(Product_Code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, Batch_Code nVarchar(Max),Reason nVarchar(Max)  COLLATE SQL_Latin1_General_CP1_CI_AS, Physical_Qty Decimal(18,6) Default 0)
Create Table #tmpBatch(Product_Code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, Batch_Code Int)

DECLARE @STOCKSTATUS Int
Declare @DamageStock Int 

Select  @STOCKSTATUS = StockStatus, @DamageStock = IsNull(DamageStock,0) From ReconcileAbstract Where ReconcileId = @Reconcile

DECLARE @listStr nVARCHAR(MAX)
DECLARE @lstReason nVARCHAR(MAX)
DECLARE @Product_Code nVarchar(50)
/*Cursor Batch Code grouping with comma seperation*/
Declare Cur_BatchGrp Cursor For
Select Distinct Product_code From ReconcileDetail Where ReconcileID = @Reconcile And IsNull(StockReconciled,0) = 0
Open Cur_BatchGrp 
Fetch Next From Cur_BatchGrp into @Product_Code
While @@Fetch_Status = 0 
Begin
  Set @listStr = NULL
  Set @lstReason = NULL
  Select @listStr = COALESCE(@listStr+ N',','')+ IsNull(Batch_code,0) From ReconcileDetail
  Where Product_Code = @Product_Code and ReconcileID = @Reconcile

  Declare @tmpReason as Table(ReconcileReason nVarchar(Max))
  Insert into @tmpReason
  Select Distinct IsNull(Reason,'') from ReconcileDetail Where Product_Code = @Product_Code and ReconcileID = @Reconcile
  Select @lstReason = COALESCE(@lstReason+ Case IsNull(ReconcileReason,'') When N'' Then N'' Else N',' End,'')+ IsNull(ReconcileReason,'')  from @tmpReason
  Delete from @tmpReason 

  Insert into #tmpBatchGrp values(@Product_Code, 
                 Case Substring(@listStr,1,1) When N',' then Substring(@listStr,2,len(@listStr)) Else @listStr End,
                 Case Substring(@lstReason,1,1) When N',' then Substring(@lstReason,2,len(@lstReason)) Else @lstReason End,0)
  Fetch Next From Cur_BatchGrp into @Product_Code
End
Close Cur_BatchGrp 
Deallocate Cur_BatchGrp 

--SelecT * from @tmpBatchGrp

/*Updating the Physical Qty*/
Update tmpGrp Set Physical_Qty = PhysicalQuantity 
From #tmpBatchGrp tmpGrp, (Select Product_Code, Sum(PhysicalQuantity) PhysicalQuantity From ReconcileDetail Where ReconcileID = @Reconcile Group By Product_Code)RD 
Where tmpGrp.Product_Code = RD.Product_Code

--Select * from @tmpBatchGrp 

/*Getting Batch_code Direct Batch Insert*/
Insert into #tmpBatch
Select Product_code, Cast(Batch_Code as Int)  From ReconcileDetail 
Where ReconcileID = @Reconcile and CHARINDEX(N',', IsNull(Batch_code,0)) = 0 And IsNull(StockReconciled,0) = 0

/*Getting Batch_code Cursor to Split the batch with comma sepetation*/
Declare @Batch_Code nVarchar(Max)
Declare Cur_ItemGrp Cursor For
Select Product_code, Batch_Code From ReconcileDetail Where ReconcileID = @Reconcile and CHARINDEX(N',', IsNull(Batch_code,0)) > 0 and Isnull(StockReconciled, 0) = 0 
Open Cur_ItemGrp 
Fetch Next From Cur_ItemGrp into @Product_Code, @Batch_Code
While @@Fetch_Status = 0 
Begin
  Insert into #tmpBatch
  Select @Product_Code,ItemValue From dbo.fn_SplitIn2Rows_Int(@Batch_Code,N',')  
  Fetch Next From Cur_ItemGrp into @Product_Code, @Batch_Code
End
Close Cur_ItemGrp 
Deallocate Cur_ItemGrp 

--Select * from @tmpBatch 
/*To include additional batches non exists while Stock Taking*/
Insert into #tmpBatch
Select BP.Product_code, BP.Batch_code
from Batch_products BP, #tmpBatch tBatch
Where BP.Product_code = tBatch.Product_code and
IsNull(BP.Damage,0) >= (Case @DamageStock When 0 then 0 Else 1 End) and 
IsNull(BP.Damage,0) <= (Case @DamageStock When 0 then 0 Else 2 End) and 
BP.Batch_code not in (Select Batch_code From #tmpBatch)
Group By BP.Product_code, BP.Batch_code
Having Sum(BP.Quantity) > 0 


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


Declare @DefUOM int
Select @DefUOM=IsNull(UOM,2) From ReconcileAbstract Where ReconcileID = @Reconcile
If @Damage = 0   
  Begin
	Select Items.Product_Code, Items.ProductName,
	Case @DefUOM When 1 Then Items.UOM2 When 2 Then Items.UOM1 Else Items.UOM End UOM, UOM.Description,
	Cast((Sum(IsNull(Batch_Products.Quantity, 0))/ (Case @DefUOM When 1 then IsNull(Items.UOM2_Conversion,1)
				 When 2 then IsNull(Items.UOM1_Conversion,1)
				 Else 1 End)) as Decimal (18,6)) as Quantity,
	Cast((IsNull(tR.Physical_Qty, 0)/ (Case @DefUOM When 1 then IsNull(Items.UOM2_Conversion,1)
				 When 2 then IsNull(Items.UOM1_Conversion,1)
				 Else 1 End)) as Decimal (18,6)) as PhysicalQuantity,
	(Cast((IsNull(tR.Physical_Qty, 0)/ (Case @DefUOM When 1 then IsNull(Items.UOM2_Conversion,1)
				 When 2 then IsNull(Items.UOM1_Conversion,1)
				 Else 1 End)) as Decimal (18,6)) - 
	 Cast((Sum(IsNull(Batch_Products.Quantity, 0))/ (Case @DefUOM When 1 then IsNull(Items.UOM2_Conversion,1)
				 When 2 then IsNull(Items.UOM1_Conversion,1)
				 Else 1 End)) as Decimal (18,6)))  as 'Difference', tR.BATCH_CODE, tR.Reason 
	From Items
	Inner Join #tmpBatchGrp tR On Items.Product_Code = tR.Product_Code
	Inner Join #tmpBatch tRB On Items.Product_Code = tRB.Product_Code
	Left Outer Join Batch_products On Items.Product_Code = Batch_products.Product_Code And Batch_products.Batch_Code = tRB.Batch_code
	Inner Join #tmpCategoryList tmpCat On tmpCat.CategoryID = Items.CategoryID
	Inner Join UOM On UOM.UOM = Case @DefUOM When 1 Then Items.UOM2 When 2 Then Items.UOM1 Else Items.UOM End
	Where isnull(Batch_products.Damage, 0) = 0  
	group by tmpCat.RowID,Items.Product_Code, Items.ProductName, UOM.Description, tR.BATCH_CODE, tR.Reason, tR.Physical_Qty,
	Case @DefUOM When 1 then Items.UOM2 When 2 then Items.UOM1 Else Items.UOM End, 
	Case @DefUOM When 1 then IsNull(Items.UOM2_Conversion,1) When 2 then IsNull(Items.UOM1_Conversion,1) Else 1 End
	Order by tmpCat.RowID, Items.Product_Code
  End 
Else  
  Begin
	Select Items.Product_Code, Items.ProductName, 
	Case @DefUOM When 1 Then Items.UOM2 When 2 Then Items.UOM1 Else Items.UOM End UOM,  UOM.Description,
	Cast((Sum(IsNull(Batch_Products.Quantity, 0))/ (Case @DefUOM When 1 then IsNull(Items.UOM2_Conversion,1)
				 When 2 then IsNull(Items.UOM1_Conversion,1)
				 Else 1 End)) as Decimal (18,6)) as Quantity,
	Cast((IsNull(tR.Physical_Qty, 0)/ (Case @DefUOM When 1 then IsNull(Items.UOM2_Conversion,1)
				 When 2 then IsNull(Items.UOM1_Conversion,1)
				 Else 1 End)) as Decimal (18,6)) as PhysicalQuantity,
	(Cast((IsNull(tR.Physical_Qty, 0)/ (Case @DefUOM When 1 then IsNull(Items.UOM2_Conversion,1)
				 When 2 then IsNull(Items.UOM1_Conversion,1)
				 Else 1 End)) as Decimal (18,6)) - 
	 Cast((Sum(IsNull(Batch_Products.Quantity, 0))/ (Case @DefUOM When 1 then IsNull(Items.UOM2_Conversion,1)
				 When 2 then IsNull(Items.UOM1_Conversion,1)
				 Else 1 End)) as Decimal (18,6)))  as 'Difference', tR.BATCH_CODE, tR.Reason
	From Items
	Inner Join #tmpBatchGrp tR On Items.Product_Code = tR.Product_Code  
	Inner Join #tmpBatch tRB On Items.Product_Code = tRB.Product_Code 
	Left Outer Join Batch_products On Items.Product_Code = Batch_products.Product_Code And Batch_products.Batch_Code = tRB.Batch_code 
	Inner Join #tmpCategoryList TmpCat On TmpCat.CategoryID = Items.CategoryID
	Inner Join UOM On UOM.UOM = Case @DefUOM When 1 Then Items.UOM2 When 2 Then Items.UOM1 Else Items.UOM End
	Where isnull(Batch_products.Damage, 0) in (1,2)  
	group by tmpCat.RowID, Items.Product_Code, Items.ProductName, tR.Physical_Qty, UOM.Description, tR.BATCH_CODE, tR.Reason,
	Case @DefUOM When 1 then Items.UOM2 When 2 then Items.UOM1 Else Items.UOM End, 
	Case @DefUOM When 1 then IsNull(Items.UOM2_Conversion,1) When 2 then IsNull(Items.UOM1_Conversion,1) Else 1 End
	Order by tmpCat.RowID, Items.Product_Code  
  End
Drop table #tmpCategoryList
Drop Table #tmpBatchGrp
Drop Table #tmpBatch
End
