Create procedure sp_GetECP_ForPurchaseReturn(@Product_Code nVarchar(50), @Batch nVarchar(50),    
@PKD DateTime, @Expiry DateTime, @PurchaseRate Decimal(18,6))    
AS  
SELECT "PTS" = CASE Price_Option     
WHEN 1 THEN    
Max(Batch.PTS)
ELSE    
Max(Items.PTS)
END,    
"PTR" = CASE Price_Option     
WHEN 1 THEN    
Max(Batch.PTR)
ELSE    
Max(Items.PTR)
END,    
"ECP" = CASE Price_Option     
WHEN 1 THEN    
Max(Batch.ECP)
ELSE    
Max(Items.ECP)
END,  
Batch.Product_Code, Batch_Number, Expiry, PKD, PurchasePrice    
INTO #TempPrices FROM Items, ItemCategories, Batch_Products Batch    
WHERE ItemCategories.CategoryID = Items.CategoryID And    
IsNull(Batch.PKD,'') = IsNull(@PKD,'') And     
IsNull(Batch.Expiry,'') = IsNull(@Expiry,'') And    
Items.Product_Code = Batch.Product_Code And     
Batch.Batch_Number = @Batch And 
Batch.Product_Code = @Product_Code     
GROUP BY Batch.Product_Code, Batch_Number, Expiry, PKD, PurchasePrice, Price_Option 

SELECT #TempPrices.PTS, #TempPrices.PTR, #TempPrices.ECP  FROM #TempPrices, Items
WHERE Items.Product_Code = @Product_Code And #TempPrices.Product_Code = Items.Product_Code
And PurchasePrice = @PurchaseRate 
