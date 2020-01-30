Create procedure sp_Adjust_Physical_Stock(@StockID Integer, @ITEMCODE nvarchar(15),@AdjType Integer, @ReconDate DateTime, @Diff Decimal(18,6), @SaveAdjType Integer, @ReconcileID Int = 0, @ItemBatch Int = 0, @BackDatedTransaction int = 0)                  
As                  
Begin                  
Declare @PriceOption Integer          
Declare @ActualDamage as integer                    
Declare @BatchNumber nvarchar(100)          
Declare @Qty Decimal(18,6)      
Declare @Price Decimal(18,6)      
Declare @Damage Decimal(18,6)      
Declare @BatchCode Integer          
Declare @ActDamage Integer          
        
Declare @NewQty Decimal(18,6)      
Declare @Bal Decimal(18,6)      
Declare @NewVal Decimal(18,6)          
Declare @OldVal Decimal(18,6)    
Declare @MRPPerPack Decimal(18,6)
Declare @Free int          
      
Select @PriceOption = Price_Option FROM ItemCategories, Items WHERE ItemCategories.CategoryID = Items.CategoryID AND Items.Product_Code = @ITEMCODE                          
Select top 1 @ActualDamage = isnull(Damage, 0) from Batch_products Where product_Code = @ITEMCODE Order by Damage DESC              
Set @Damage = Isnull(@AdjType, 0)      
Set @ActualDamage = Isnull(@ActualDamage, 0)        
       
If @PriceOption = 1               
Begin              
if @Damage = 0                     
Begin          
 Declare GetBatchInfo Cursor For          
 SELECT Batch_Code, Batch_Number, Sum(Quantity), PurchasePrice, ISNULL(Damage, 0), 0,MRPPerPack, isnull(Free,0)                 
 FROM Batch_Products                          
 WHERE Batch_Products.Product_Code = @ITEMCODE 
 and Batch_Code = Case @ItemBatch When 0 then Batch_code Else @ItemBatch End 
 and Isnull(Damage, 0) = 0              
-- and Isnull(Free, 0) <> 1      
 Group by ISNULL(Damage, 0), Batch_Code, Batch_Number, PurchasePrice,MRPPerPack, isnull(Free,0)
 order by Batch_Code DESC                   
End          
Else If @Damage = 1 And @ActualDamage >= 1              
Begin        
 Declare GetBatchInfo Cursor For          
 SELECT Batch_Code, Batch_Number, Sum(Quantity), PurchasePrice, ISNULL(Damage, 0), 0,MRPPerPack, isnull(Free,0)                  
 FROM Batch_Products                          
 WHERE  Batch_Products.Product_Code = @ITEMCODE       
 and Batch_Code = Case @ItemBatch When 0 then Batch_code Else @ItemBatch End                    
 and Isnull(Damage, 0) >= 1               
-- and Isnull(Free, 0) <> 1      
 GROUP BY Batch_Code, Batch_Number, PurchasePrice, ISNULL(Damage, 0),MRPPerPack, isnull(Free,0)         
 order by Batch_Code DESC                      
End          
Else If @Damage = 1  And  @ActualDamage = 0        
Begin        
      
 Declare GetBatchInfo Cursor For          
 SELECT Batch_Code, Batch_Number, 0, PurchasePrice, ISNULL(Damage, 0), 1,MRPPerPack, isnull(Free,0)                 
 FROM Batch_Products                          
 WHERE  Batch_Products.Product_Code = @ITEMCODE    
 and Batch_Code = Case @ItemBatch When 0 then Batch_code Else @ItemBatch End                       
-- and Isnull(Free, 0) <> 1      
 order by Batch_Code DESC                          
End            
End            
  
-- Price Option Else = 0    
Else                  
Begin              
if @Damage = 0                    
Begin          
      
 Declare GetBatchInfo Cursor For          
 SELECT Batch_Code, Batch_Number, Sum(Quantity), PurchasePrice, ISNULL(Damage, 0), 0,Batch_Products.MRPPerPack, isnull(Batch_Products.Free,0)                  
 FROM Batch_Products, Items                          
 WHERE  Batch_Products.Product_Code = @ITEMCODE                          
 and Batch_Products.Product_Code = Items.Product_Code        
 and Batch_Code = Case @ItemBatch When 0 then Batch_code Else @ItemBatch End             
 and Isnull(Damage, 0) = 0               
-- and Isnull(Free, 0) <> 1      
 GROUP BY Batch_Code, Batch_Number, PurchasePrice, ISNULL(Damage, 0),Batch_Products.MRPPerPack, isnull(Batch_Products.Free,0)                  
 order by Batch_Code DESC                     
End          
Else If @Damage = 1 And @ActualDamage >= 1              
begin        
      
 Declare GetBatchInfo Cursor For          
 Select Batch_Code, Batch_Number, Sum(Quantity), PurchasePrice, ISNULL(Damage, 0), 0,Batch_Products.MRPPerPack, isnull(Batch_Products.Free,0)                  
 FROM Batch_Products, Items                          
 WHERE  Batch_Products.Product_Code = @ITEMCODE                          
 and Batch_Products.Product_Code = Items.Product_Code                    
 and Batch_Code = Case @ItemBatch When 0 then Batch_code Else @ItemBatch End 
 and Isnull(Damage, 0) >= 1               
-- and Isnull(Free, 0) <> 1      
 GROUP BY Batch_Code, Batch_Number, PurchasePrice, ISNULL(Damage, 0),Batch_Products.MRPPerPack, isnull(Batch_Products.Free,0)          
 order by Batch_Code DESC                        
End          
Else if @Damage = 1 And @ActualDamage = 0   
begin        
      
 Declare GetBatchInfo Cursor For          
 Select Batch_Code, Batch_Number, 0, PurchasePrice, ISNULL(Damage, 0), 1,Batch_Products.MRPPerPack, isnull(Batch_Products.Free,0)        
 FROM Batch_Products, Items                          
 WHERE  Batch_Products.Product_Code = @ITEMCODE                          
 and Batch_Code = Case @ItemBatch When 0 then Batch_code Else @ItemBatch End 
 and Batch_Products.Product_Code = Items.Product_Code                    
-- and Isnull(Free, 0) <> 1      
 GROUP BY Batch_Code, Batch_Number, PurchasePrice, ISNULL(Damage, 0),Batch_Products.MRPPerPack, isnull(Batch_Products.Free,0)         
 order by Batch_Code DESC                          
End            
End                  
                
OPEN GetBatchInfo          
FETCH FROM GetBatchInfo Into @BatchCode, @BatchNumber, @Qty, @Price, @Damage, @ActDamage,@MRPPerPack, @Free                                     
        
Set @Bal = @Diff           
if @Bal < 0         
Begin        
 WHILE @@FETCH_STATUS = 0                        
 BEGIN        
   If @Bal < 0         
   Begin        
   Set @NewQty = (@Qty + @Diff)          
   Set @OldVal = (@Qty * @Price)          
   Set @NewVal = (@NewQty * @Price)          
        
     If @NewQty < 0           
     Begin        
     Set @Diff = @newQty        
     Set @Bal = @Diff         
     End        
     Else        
     Begin        
     Set @Bal = 0        
     End            
   
   if @NewVal < 0           
     Set @NewVal = 0          
            
   If @NewQty < 0           
     Set @NewQty = 0           
      
   --Exec sp_Adjust_BatchProducts @StockID, @ITEMCODE, @BatchCode, @BatchNumber, @Qty,  @OldVal, @NewQty, @NewVal, @SaveAdjType, @ReconDate, @Damage, @ActDamage         
	Exec sp_Adjust_BatchProducts_GST @StockID, @ITEMCODE, @BatchCode, @BatchNumber, @Qty, @OldVal, @NewQty, @NewVal, @SaveAdjType, @ReconDate, @Damage, @ActDamage, @Diff, @Price, @Free, @BackDatedTransaction
   End        
         
   FETCH NEXT FROM GetBatchInfo Into @BatchCode, @BatchNumber, @Qty, @Price, @Damage, @ActDamage,@MRPPerPack, @Free         
 END            
End        
Else        
Begin        

  /*Below Cursor will return the Batch Type identifier for New batch*/
  Declare @NewBatch Int 
  Set @NewBatch = 0 
  Declare @BatchType int 
  Declare @ReconBatch_Code nVarchar(Max)
  Declare Cur_GetBatch Cursor For
  Select Batch_code, IsNull(NewBatch,0) From ReconcileDetail
  Where ReconcileID = @ReconcileID
        and StockReconciled = 1 
        and Product_code = @ITEMCODE 
        and Batch_code Like '%' + Cast(@ItemBatch as nVarchar(10)) + '%'
  Open Cur_GetBatch
  Fetch Next From Cur_GetBatch into @ReconBatch_Code, @BatchType
  While @@Fetch_Status = 0
  Begin
    If Exists(Select * from dbo.fn_SplitIn2Rows_Int(@ReconBatch_Code,',') Where ItemValue = @ItemBatch)
       Set @NewBatch =  @BatchType
    
    Fetch Next From Cur_GetBatch into @ReconBatch_Code, @BatchType
  End
  Close Cur_GetBatch
  Deallocate Cur_GetBatch

  IF @QTY = @Diff And @NewBatch = 1 
  Begin  
    /*Since the New Batch introduced during Stock Recon, this should not be considered for adjustment hence New Qty set as Qty instead Qty + diff*/
    /*and Qty(Old Qty) is set as Zero */
    Set @NewQty = @Qty   
    Set @Qty = 0    
  End
  Else
    Set @NewQty = (@Qty + @Diff)          
   
  Set @OldVal = (@Qty * @Price)          
  Set @NewVal = (@NewQty * @Price)          
    
  --Exec sp_Adjust_BatchProducts @StockID, @ITEMCODE, @BatchCode, @BatchNumber, @Qty,  @OldVal, @NewQty, @NewVal, @SaveAdjType, @ReconDate, @Damage, @ActDamage         
	Exec sp_Adjust_BatchProducts_GST @StockID, @ITEMCODE, @BatchCode, @BatchNumber, @Qty,  @OldVal, @NewQty, @NewVal, @SaveAdjType, @ReconDate, @Damage, @ActDamage, @Diff, @Price, @Free, @BackDatedTransaction
       
End        
        
        
Close GetBatchInfo          
Deallocate GetBatchInfo
End
