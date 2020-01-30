CREATE PROCEDURE sp_get_bookstock_Adjutment(@PRODUCT_CODE nvarchar(15),          
      @TRACK_BATCH int)               
AS          
Declare @PriceOpt int           
Declare @CategoryID int           
Declare @TaxCode int           
Declare @TaxSuffered Decimal(18,6)          
          
Select @CategoryID = CategoryID, @TaxCode = IsNull(TaxSuffered,0)           
From Items Where Product_Code = @Product_code          
          
IF @TRACK_BATCH = 1          
BEGIN          
 Select Batch_Number, Expiry, SUM(Quantity), PurchasePrice, IsNull(Free, 0),          
 IsNull(TaxSuffered,0), PKD as PKD,PTS,PTR,ECP,Company_Price,
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0)          
 From Batch_Products           
 where Product_Code= @PRODUCT_CODE AND Quantity > 0 And IsNull(Damage, 0) = 0          
 Group By Batch_Number, Expiry, PurchasePrice, PKD, IsNull(Free, 0), IsNull(TaxSuffered,0),    
 PTS,PTR,ECP,Company_Price, 
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0)        
 Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code)
END          
ELSE          
BEGIN          
 Select N'', '', SUM(Quantity), PurchasePrice, IsNull(Free, 0),          
 IsNull(TaxSuffered,0), PKD as PKD,PTS,PTR,ECP,Company_Price,
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0)                 
 From Batch_Products           
 where Product_Code= @PRODUCT_CODE AND Quantity > 0 And IsNull(Damage, 0) = 0          
 Group By PurchasePrice, IsNull(Free, 0), IsNull(TaxSuffered,0),PKD,  
 PTS,PTR,ECP,Company_Price,  
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0)                 
 Order By Isnull(Free, 0), MIN(Batch_Code)     
END     
    
    




