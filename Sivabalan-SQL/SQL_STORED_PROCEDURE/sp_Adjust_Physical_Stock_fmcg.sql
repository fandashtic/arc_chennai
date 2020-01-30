CREATE procedure sp_Adjust_Physical_Stock_fmcg(@StockID Integer, @ITEMCODE nvarchar(15),@AdjType Integer, @ReconDate DateTime, @Diff Decimal(18,6), @SaveAdjType Integer)                  
As                  
                  
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
      
          
Select @PriceOption = Price_Option FROM ItemCategories, Items WHERE ItemCategories.CategoryID = Items.CategoryID AND Items.Product_Code = @ITEMCODE                          
Select top 1 @ActualDamage = isnull(Damage, 0) from Batch_products Where product_Code = @ITEMCODE Order by Damage DESC              
Set @Damage = Isnull(@AdjType, 0)      
Set @ActualDamage = Isnull(@ActualDamage, 0)        
       
If @PriceOption = 1               
Begin              
if @Damage = 0                     
Begin          
 Declare GetBatchInfo Cursor For          
 SELECT Batch_Code, Batch_Number, Sum(Quantity), PurchasePrice, ISNULL(Damage, 0), 0                  
 FROM Batch_Products                          
 WHERE Batch_Products.Product_Code = @ITEMCODE                          
 and Isnull(Damage, 0) = 0              
 and Isnull(Free, 0) <> 1      
 Group by ISNULL(Damage, 0), Batch_Code, Batch_Number, PurchasePrice        
 order by Batch_Code DESC                   
End          
Else If @Damage = 1 And @ActualDamage >= 1              
Begin        
 Declare GetBatchInfo Cursor For          
 SELECT Batch_Code, Batch_Number, Sum(Quantity), PurchasePrice, ISNULL(Damage, 0), 0                  
 FROM Batch_Products                          
 WHERE  Batch_Products.Product_Code = @ITEMCODE                          
 and Isnull(Damage, 0) >= 1               
 and Isnull(Free, 0) <> 1      
 GROUP BY Batch_Code, Batch_Number, PurchasePrice, ISNULL(Damage, 0)        
 order by Batch_Code DESC                      
End          
Else If @Damage = 1  And  @ActualDamage = 0        
Begin        
      
 Declare GetBatchInfo Cursor For          
 SELECT Batch_Code, Batch_Number, 0, PurchasePrice, ISNULL(Damage, 0), 1                 
 FROM Batch_Products                          
 WHERE  Batch_Products.Product_Code = @ITEMCODE                          
 and Isnull(Free, 0) <> 1      
 order by Batch_Code DESC                          
End            
End            
  
-- Price Option Else = 0    
Else                  
Begin              
if @Damage = 0                    
Begin          
      
 Declare GetBatchInfo Cursor For          
 SELECT Batch_Code, Batch_Number, Sum(Quantity), PurchasePrice, ISNULL(Damage, 0), 0                  
 FROM Batch_Products, Items                          
 WHERE  Batch_Products.Product_Code = @ITEMCODE                          
 and Batch_Products.Product_Code = Items.Product_Code                    
 and Isnull(Damage, 0) = 0               
 and Isnull(Free, 0) <> 1      
 GROUP BY Batch_Code, Batch_Number, PurchasePrice, ISNULL(Damage, 0)                 
 order by Batch_Code DESC                     
End          
Else If @Damage = 1 And @ActualDamage >= 1              
begin        
      
 Declare GetBatchInfo Cursor For          
 Select Batch_Code, Batch_Number, Sum(Quantity), PurchasePrice, ISNULL(Damage, 0), 0                  
 FROM Batch_Products, Items                          
 WHERE  Batch_Products.Product_Code = @ITEMCODE                          
 and Batch_Products.Product_Code = Items.Product_Code                    
 and Isnull(Damage, 0) >= 1               
 and Isnull(Free, 0) <> 1      
 GROUP BY Batch_Code, Batch_Number, PurchasePrice, ISNULL(Damage, 0)         
 order by Batch_Code DESC                        
End          
Else if @Damage = 1 And @ActualDamage = 0     
begin        
      
 Declare GetBatchInfo Cursor For          
 Select Batch_Code, Batch_Number, 0, PurchasePrice, ISNULL(Damage, 0), 1        
 FROM Batch_Products, Items                          
 WHERE  Batch_Products.Product_Code = @ITEMCODE                          
 and Batch_Products.Product_Code = Items.Product_Code                    
 and Isnull(Free, 0) <> 1      
 GROUP BY Batch_Code, Batch_Number, PurchasePrice, ISNULL(Damage, 0)        
 order by Batch_Code DESC                          
End            
End                  
                
OPEN GetBatchInfo          
FETCH FROM GetBatchInfo Into @BatchCode, @BatchNumber, @Qty, @Price, @Damage, @ActDamage                                     
        
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
      
Exec sp_Adjust_BatchProducts_FMCG @StockID, @ITEMCODE, @BatchCode, @BatchNumber, @Qty,  @OldVal, @NewQty, @NewVal, @SaveAdjType, @ReconDate, @Damage, @ActDamage         
    End        
         
 FETCH NEXT FROM GetBatchInfo Into @BatchCode, @BatchNumber, @Qty, @Price, @Damage, @ActDamage        
      
      
 END            
End        
Else        
Begin        
        
        
  Set @NewQty = (@Qty + @Diff)          
  Set @OldVal = (@Qty * @Price)          
  Set @NewVal = (@NewQty * @Price)          
    
Exec sp_Adjust_BatchProducts_FMCG @StockID, @ITEMCODE, @BatchCode, @BatchNumber, @Qty,  @OldVal, @NewQty, @NewVal, @SaveAdjType, @ReconDate, @Damage, @ActDamage         
       
End        
        
        
Close GetBatchInfo          
Deallocate GetBatchInfo          
    
  
  


