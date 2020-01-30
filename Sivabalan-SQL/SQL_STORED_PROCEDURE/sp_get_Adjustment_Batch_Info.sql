CREATE PROCEDURE sp_get_Adjustment_Batch_Info(@ITEMCODE NVARCHAR(15), @TYPE int = 1)              
AS              
        
Declare @PriceOption Integer        
Select @PriceOption = Price_Option FROM ItemCategories, Items WHERE ItemCategories.CategoryID = Items.CategoryID AND Items.Product_Code = @ITEMCODE          
        
If @PriceOption = 1        
BEGIN        
 IF @TYPE = 0              
  SELECT Batch_Number, Expiry, SUM(Quantity), PurchasePrice, SalePrice, PTS, PTR, ECP, 0, isnull(Free, 0), PKD, IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType,  
  IsNull(MRPPerPack,0)    
  FROM Batch_Products, tbl_merp_TaxType TT  
  WHERE  Batch_Products.Product_Code = @ITEMCODE  AND ISNULL(Damage, 0) = 0 and TT.TaxID = IsNull(Batch_Products.TaxType,1)  
  GROUP BY Batch_Number, Expiry, PurchasePrice, isnull(Free, 0), PKD, SalePrice, PTS, PTR, ECP,   
         IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType,IsNull(MRPPerPack,0)  
  Order By Isnull(Free, 0),isnull(Expiry,'9999'),PKD, MIN(Batch_Code)   
 ELSE IF @TYPE = 2         
  SELECT Batch_Number, Expiry, SUM(Quantity), PurchasePrice, SalePrice, PTS, PTR, ECP, ISNULL(Damage, 0), isnull(Free, 0), PKD, IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType,  
  IsNull(MRPPerPack,0)  
  FROM Batch_Products, tbl_merp_TaxType TT             
  WHERE  Batch_Products.Product_Code = @ITEMCODE and Isnull(GRN_ID, 0) = 0 and Isnull(StockTransferID, 0) = 0  AND ISNULL(Damage, 0) = 0  and TT.TaxID = IsNull(Batch_Products.TaxType,1)     
  GROUP BY Isnull(Free, 0), Batch_Number, Expiry, PurchasePrice, ISNULL(Damage, 0), PKD, SalePrice, PTS, PTR, ECP,            
         IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType,IsNull(MRPPerPack,0)  
  Order By Isnull(Free, 0),isnull(Expiry,'9999'),PKD, MIN(Batch_Code)   
 ELSE              
  SELECT Batch_Number, Expiry, SUM(Quantity), PurchasePrice, SalePrice, PTS, PTR, ECP, ISNULL(Damage, 0), isnull(Free, 0), PKD, IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType,  
  IsNull(MRPPerPack,0)  
  FROM Batch_Products, tbl_merp_TaxType TT              
  WHERE  Batch_Products.Product_Code = @ITEMCODE and TT.TaxID = IsNull(Batch_Products.TaxType,1)  
  GROUP BY Isnull(Free, 0), Batch_Number, Expiry, PurchasePrice, ISNULL(Damage, 0), PKD, SalePrice, PTS, PTR, ECP,            
         IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType,IsNull(MRPPerPack,0)  
  Order By Isnull(Free, 0),isnull(Expiry,'9999'),PKD, MIN(Batch_Code)   
END      
ELSE      
BEGIN      
 IF @TYPE = 0              
  SELECT Batch_Number, Expiry, SUM(Quantity), PurchasePrice, Items.Sale_Price, Items.PTS, Items.PTR, Items.ECP, 0, isnull(Free, 0), PKD, IsNull(Batch_Products.TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType,   
  IsNull(Items.MRPPerPack,0)  
  FROM Batch_Products, tbl_merp_TaxType TT, Items              
  WHERE  Batch_Products.Product_Code = @ITEMCODE  AND ISNULL(Damage, 0) = 0              
  and Batch_Products.Product_Code = Items.Product_Code and TT.TaxID = IsNull(Batch_Products.TaxType,1)       
  GROUP BY Batch_Number, Expiry, PurchasePrice, isnull(Free, 0), PKD, Items.Sale_Price, Items.PTS, Items.PTR, Items.ECP,              
         IsNull(Batch_Products.TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType, IsNull(Items.MRPPerPack,0)  
  Order By Isnull(Free, 0),isnull(Expiry,'9999'),PKD, MIN(Batch_Code)   
  --HAVING SUM(Quantity) > 0              
 ELSE IF @TYPE = 2         
  SELECT Batch_Number, Expiry, SUM(Quantity), PurchasePrice, Items.Sale_Price, Items.PTS, Items.PTR, Items.ECP, ISNULL(Damage, 0), isnull(Free, 0), PKD, IsNull(Batch_Products.TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType,  
IsNull(Items.MRPPerPack,0)         
  FROM Batch_Products, tbl_merp_TaxType TT, Items     
  WHERE  Batch_Products.Product_Code = @ITEMCODE              
  and Batch_Products.Product_Code = Items.Product_Code and Isnull(GRN_ID, 0) = 0 and Isnull(StockTransferID, 0) = 0  AND ISNULL(Damage, 0) = 0 and TT.TaxID = IsNull(Batch_Products.TaxType,1)      
  GROUP BY Isnull(Free, 0), Batch_Number, Expiry, PurchasePrice, ISNULL(Damage, 0), PKD, Items.Sale_Price, Items.PTS, Items.PTR, Items.ECP,              
         IsNull(Batch_Products.TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType, IsNull(Items.MRPPerPack,0)  
  Order By Isnull(Free, 0),isnull(Expiry,'9999'),PKD, MIN(Batch_Code)   
 ELSE             
  SELECT Batch_Number, Expiry, SUM(Quantity), PurchasePrice, Items.Sale_Price, Items.PTS, Items.PTR, Items.ECP, ISNULL(Damage, 0), isnull(Free, 0), PKD, IsNull(Batch_Products.TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType,      
  IsNull(Items.MRPPerPack,0)    
  FROM Batch_Products, tbl_merp_TaxType TT, Items              
  WHERE  Batch_Products.Product_Code = @ITEMCODE              
  and Batch_Products.Product_Code = Items.Product_Code and TT.TaxID = IsNull(Batch_Products.TaxType,1)       
  GROUP BY Isnull(Free, 0), Batch_Number, Expiry, PurchasePrice, ISNULL(Damage, 0), PKD, Items.Sale_Price, Items.PTS, Items.PTR, Items.ECP,              
         IsNull(Batch_Products.TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0), TT.TaxType, IsNull(Items.MRPPerPack,0)  
  Order By Isnull(Free, 0),isnull(Expiry,'9999'),PKD, MIN(Batch_Code)   
END        
