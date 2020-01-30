CREATE Procedure sp_save_StockAdjustment_fmcg_MUOM(@STOCKID INT,      
          @ITEM_CODE NVARCHAR(15),      
          @BATCH_NUMBER NVARCHAR(255),       
          @OLD_QTY Decimal(18,6),      
          @OLD_VALUE Decimal(18,6),      
          @NEW_QTY Decimal(18,6),      
          @NEW_VALUE Decimal(18,6),      
          @REASON_ID INT,      
          @PURCHASE_PRICE Decimal(18,6),      
          @SALE_PRICE Decimal(18,6),      
          @PRICE Decimal(18,6),      
          @ADJTYPE INT = 1,      
          @ADJUSTMENT_PRICE Decimal(18,6) = 0,      
          @EXPIRY_DATE DATETIME = NULL,      
          @DAMAGEFLAG int = 0,      
          @FreeRow Int = 0,      
          @OpeningDate datetime = Null,      
          @BackDatedTransaction int = 0, @PKD1 DATETIME = NULL,   
     @TAXSUFFERED1 decimal(18,6)=0, @APPLICABLEON1 int=0, @PARTOFF1 decimal(18,6)=0)      
AS      
DECLARE @BATCH_CODE INT      
DECLARE @ORIGINAL_CODE INT      
DECLARE @GRN_ID INT      
DECLARE @QUANTITY Decimal(18,6)      
DECLARE @DIFF Decimal(18,6)      
DECLARE @OLDPRICE Decimal(18,6)      
DECLARE @PriceOption int      
DECLARE @EXPIRY datetime      
DECLARE @DAMAGE Decimal(18,6)      
DECLARE @ADJUSTMENT_QTY Decimal(18,6)      
DECLARE @PKD_DATE datetime      
DECLARE @QTY_SHIFT Decimal(18,6)      
DECLARE @VALUE_SHIFT Decimal(18,6)      
DECLARE @SERVERDATE datetime      
DECLARE @TAXSUFFERED Decimal(18,6)      
DECLARE @UOM Int      
DECLARE @Free Decimal(18,6)   
DECLARE @GRNTaxSuffered Decimal(18,6)   
DECLARE @GRNTaxId Int  
DECLARE @GRNApplicableOn Int  
DECLARE @GRNPartOff Decimal(18,6)  
DECLARE @ApplicableOn Int  
DECLARE @PartOff Decimal(18,6)  
DECLARE @Vat_Locality Decimal(18,6)   
      
Select @PriceOption = Price_Option FROM ItemCategories, Items       
WHERE ItemCategories.CategoryID = Items.CategoryID AND Items.Product_Code = @ITEM_CODE      
SET @ORIGINAL_CODE = 0      
      
IF @OLD_QTY <> 0       
  SET @OLDPRICE = @OLD_VALUE /  @OLD_QTY      
ELSE      
  SET @OLDPRICE = 0      
  
If @ADJTYPE = 2    
 DECLARE GetStocks CURSOR KEYSET FOR        
 SELECT Batch_Number,  Batch_Code , Quantity, IsNull(Damage,0) FROM Batch_Products        
 WHERE Product_Code = @ITEM_CODE AND isnull(Batch_Number, N'') = @BATCH_NUMBER         
 AND (Expiry = @EXPIRY_DATE OR Expiry IS NULL)        
 AND ISNULL(PurchasePrice, 0) = @PURCHASE_PRICE         
 AND ISNULL(Damage, 0) = @DAMAGEFLAG And isnull(Free, 0) = @FreeRow and Isnull(GRN_ID, 0) = 0 and Isnull(StockTransferID, 0) = 0    
 AND (PKD = @PKD1 OR PKD IS NULL)  
 AND IsNull(TAXSUFFERED, 0) = @TAXSUFFERED1   
 AND IsNull(APPLICABLEON, 0) = @APPLICABLEON1 AND IsNull(PARTOFPERCENTAGE, 0) = @PARTOFF1  
 ORDER BY Batch_Code        
Else      
 DECLARE GetStocks CURSOR KEYSET FOR      
 SELECT Batch_Number,  Batch_Code , Quantity, IsNull(Damage, 0) FROM Batch_Products      
 WHERE Product_Code = @ITEM_CODE AND isnull(Batch_Number, N'') = @BATCH_NUMBER       
 AND (Expiry = @EXPIRY_DATE OR Expiry IS NULL)      
 AND ISNULL(PurchasePrice, 0) = @PURCHASE_PRICE       
 AND ISNULL(Damage, 0) = @DAMAGEFLAG And isnull(Free, 0) = @FreeRow      
 AND (PKD = @PKD1 OR PKD IS NULL)  
 AND IsNull(TAXSUFFERED, 0) = @TAXSUFFERED1   
 AND IsNull(APPLICABLEON, 0) = @APPLICABLEON1 AND IsNull(PARTOFPERCENTAGE, 0) = @PARTOFF1  
 ORDER BY Batch_Code       
      
IF @NEW_QTY > @OLD_QTY SET @DIFF = @NEW_QTY - @OLD_QTY ELSE SET @DIFF = 0      
SET @ADJUSTMENT_QTY = @OLD_QTY - @NEW_QTY      
SET @QTY_SHIFT = @NEW_QTY - @OLD_QTY      
SET @VALUE_SHIFT = (@NEW_VALUE - @OLD_VALUE)      
      
OPEN GetStocks      
FETCH FROM GetStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @DAMAGE      
WHILE @@FETCH_STATUS = 0      
BEGIN      
  IF @NEW_QTY - @QUANTITY >= 0      
  BEGIN      
   IF @ORIGINAL_CODE = 0 SET @ORIGINAL_CODE = @BATCH_CODE      
         UPDATE Batch_Products SET PurchasePrice = @PRICE,       
        Quantity = Quantity + @DIFF      
         WHERE Batch_Code = @BATCH_CODE      
      
   IF @ADJTYPE = 1 or @ADJTYPE = 2      
   BEGIN      
          INSERT INTO StockAdjustment (SerialNO, Product_Code, Batch_Code, Batch_Number,      
    Quantity, Rate, ReasonID, OldQty, OldValue) VALUES (@STOCKID, @ITEM_CODE,       
    @BATCH_CODE,       
    @BATCH_NUMBER, @QUANTITY+@DIFF, (@QUANTITY+@DIFF) * @PRICE, @REASON_ID, @QUANTITY,      
    @QUANTITY * @OLDPRICE)      
   END      
   SET @NEW_QTY = @NEW_QTY - @QUANTITY      
   SET @DIFF = 0      
  END      
     ELSE      
  BEGIN      
   IF @ORIGINAL_CODE = 0 SET @ORIGINAL_CODE = @BATCH_CODE      
   IF @ADJTYPE = 1 And @DAMAGE > 0      
   BEGIN      
    UPDATE Batch_Products SET Quantity = @NEW_QTY, PurchasePrice = Case When @NEW_QTY = 0 And @PRICE = 0 Then PurchasePrice Else @PRICE End,       
    ClaimedAlready = Case When IsNull(ClaimedAlready, 0) - (@QUANTITY - @NEW_QTY) >= 0      
       Then IsNull(ClaimedAlready, 0) - (@QUANTITY - @NEW_QTY)      
  Else 0      
       End      
    where Batch_Code = @BATCH_CODE      
   END      
  ELSE      
  BEGIN      
   UPDATE Batch_Products SET Quantity = @NEW_QTY, PurchasePrice = Case When @NEW_QTY = 0 And @PRICE = 0 Then PurchasePrice Else @PRICE End      
   where Batch_Code = @BATCH_CODE      
  END      
        
    IF @ADJTYPE = 2 And @DAMAGE > 0        
    BEGIN        
     UPDATE Batch_Products SET Quantity = @NEW_QTY,PurchasePrice = Case When @NEW_QTY = 0 And @PRICE = 0 Then PurchasePrice Else @PRICE End,     
     ClaimedAlready = Case When IsNull(ClaimedAlready, 0) - (@QUANTITY - @NEW_QTY) >= 0        
        Then IsNull(ClaimedAlready, 0) - (@NEW_QTY)        
        Else 0        
        End        
     where Batch_Code = @BATCH_CODE        
    END        
    ELSE IF @ADJTYPE = 2 And @DAMAGE = 0        
    UPDATE Batch_Products SET Quantity = @NEW_QTY, PurchasePrice = Case When @NEW_QTY = 0 And @PRICE = 0 Then PurchasePrice Else @PRICE End  
    where Batch_Code = @BATCH_CODE        
         
    
   IF @ADJTYPE = 1 or @ADJTYPE = 2       
   BEGIN      
          INSERT INTO StockAdjustment (SerialNO, Product_Code, Batch_Code, Batch_Number,      
   Quantity, Rate, ReasonID, OldQty, OldValue) VALUES (@STOCKID, @ITEM_CODE,       
   @BATCH_CODE, @BATCH_NUMBER,      
   @NEW_QTY, @NEW_QTY * @PRICE, @REASON_ID, @QUANTITY, @QUANTITY * @OLDPRICE)      
   END      
        
   SET @NEW_QTY = 0      
  END       
    FETCH NEXT FROM GetStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @DAMAGE      
END      
    
IF @ADJTYPE = 0 AND @ADJUSTMENT_QTY <> 0      
BEGIN      
 SELECT @EXPIRY = Expiry, @PKD_DATE = PKD, @GRN_ID = GRN_ID, @TAXSUFFERED = TaxSuffered,   
 @Free=Case When IsNull(@ADJUSTMENT_PRICE,0)=0 then Free Else 0 End, @GRNTaxSuffered=GRNTaxSuffered, @GRNTaxId=GRNTaxId, @GRNApplicableOn=GRNApplicableOn, @GRNPartOff=GRNPartOff, @ApplicableOn=ApplicableOn, @PartOff=PartofPercentage, @Vat_Locality=Vat_Locality    
 FROM Batch_Products WHERE Batch_Code = @ORIGINAL_CODE      
 SELECT @UOM = UOM FROM Items WHERE Product_Code = @ITEM_CODE      
  
 INSERT INTO Batch_Products(Batch_Number, Expiry, Product_Code, Quantity, PurchasePrice,       
 SalePrice, Damage, DamagesReason, PKD, GRN_ID, TaxSuffered, UOM, UOMQty, UOMPrice, Free, GRNTaxSuffered, GRNTaxID, GRNApplicableOn, GRNPartOff, ApplicableOn, PartofPercentage, Vat_Locality, DocType, DocID)      
 Values(@Batch_Number, @EXPIRY, @ITEM_CODE, ABS(@ADJUSTMENT_QTY), @ADJUSTMENT_PRICE,       
 @SALE_PRICE, 1, @REASON_ID, @PKD_DATE, @GRN_ID, @TAXSUFFERED, @UOM,       
 ABS(@ADJUSTMENT_QTY), @ADJUSTMENT_PRICE, @Free, @GRNTaxSuffered, @GRNTaxId, @GRNApplicableOn, @GRNPartOff, @ApplicableOn, @PartOff, @Vat_Locality, 2, @STOCKID)      
  
 INSERT INTO StockAdjustment (SerialNO, Product_Code, Batch_Code, Batch_Number,      
 Quantity, Rate, ReasonID, OldQty, OldValue) VALUES (@STOCKID, @ITEM_CODE, @@IDENTITY,       
 @BATCH_NUMBER, ABS(@ADJUSTMENT_QTY), ABS(@ADJUSTMENT_QTY) * @ADJUSTMENT_PRICE, @REASON_ID,       
 @QUANTITY, @QUANTITY * @OLDPRICE)      
END      
CLOSE GetStocks      
DEALLOCATE GetStocks      
IF @BackDatedTransaction = 1 And @ADJTYPE = 1      
BEGIN      
 SET @SERVERDATE = dbo.StripDateFromTime(GetDate())      
 IF @FreeRow = 0 And @DAMAGEFLAG = 0      
 BEGIN      
   Update OpeningDetails Set       
   Opening_Quantity = Opening_Quantity + IsNull(@QTY_SHIFT,0),      
   Opening_Value = Opening_Value + IsNull(@VALUE_SHIFT, 0)      
   Where Opening_Date > @OpeningDate And Product_Code = @ITEM_CODE      
 END      
 ELSE IF @FreeRow = 1      
 BEGIN      
  IF @DAMAGEFLAG = 0      
  BEGIN      
    Update OpeningDetails Set      
    Opening_Quantity = Opening_Quantity + IsNull(@QTY_SHIFT,0),      
    Free_Opening_Quantity = IsNull(Free_Opening_Quantity,0) + IsNull(@QTY_SHIFT,0),      
    Free_Saleable_Quantity = IsNull(Free_Saleable_Quantity,0) + IsNull(@QTY_SHIFT,0)      
    Where Product_Code = @ITEM_CODE And Opening_Date > @OpeningDate      
   END      
  ELSE      
  BEGIN      
    Update OpeningDetails Set      
    Opening_Quantity = Opening_Quantity + IsNull(@QTY_SHIFT,0),      
    Free_Opening_Quantity = IsNull(Free_Opening_Quantity,0) + IsNull(@QTY_SHIFT,0),      
    Damage_Opening_Quantity = IsNull(Damage_Opening_Quantity,0) + IsNull(@QTY_SHIFT,0)      
    Where Product_Code = @ITEM_CODE And Opening_Date > @OpeningDate      
   END      
 END      
 ELSE IF @DAMAGEFLAG > 0      
 BEGIN      
   Update OpeningDetails Set       
   Opening_Quantity = Opening_Quantity + IsNull(@QTY_SHIFT,0),      
   Opening_Value = Opening_Value + IsNull(@VALUE_SHIFT, 0),       
   Damage_Opening_Quantity = IsNull(Damage_Opening_Quantity,0) + IsNull(@QTY_SHIFT,0),      
   Damage_Opening_Value = IsNull(Damage_Opening_Value,0) + IsNull(@VALUE_SHIFT, 0)      
   Where Opening_Date > @OpeningDate And Product_Code = @ITEM_CODE      
 END      
END      
ELSE IF @BackDatedTransaction = 1      
BEGIN  --Stock Adjt Damages (AdjType=0)        
 IF @FreeRow = 1      
 BEGIN      
   Update OpeningDetails Set      
   Opening_Value = Opening_Value + IsNull(@VALUE_SHIFT, 0) + (ABS(@ADJUSTMENT_QTY) * @ADJUSTMENT_PRICE),     
   Damage_Opening_Quantity = IsNull(Damage_Opening_Quantity,0) + ABS(@ADJUSTMENT_QTY),       
   Free_Saleable_Quantity = IsNull(Free_Saleable_Quantity,0) - ABS(@ADJUSTMENT_QTY),      
   Damage_Opening_Value = IsNull(Damage_Opening_Value,0) + ABS(@ADJUSTMENT_QTY) * @ADJUSTMENT_PRICE      
   Where Product_Code = @ITEM_CODE And Opening_Date > @OpeningDate      
 END      
 ELSE      
 BEGIN      
   Update OpeningDetails Set      
   Opening_Value = Opening_Value + IsNull(@VALUE_SHIFT, 0) + (ABS(@ADJUSTMENT_QTY) * @ADJUSTMENT_PRICE),     
   Damage_Opening_Quantity = IsNull(Damage_Opening_Quantity,0) + ABS(@ADJUSTMENT_QTY),       
   Damage_Opening_Value = IsNull(Damage_Opening_Value,0) + ABS(@ADJUSTMENT_QTY) * @ADJUSTMENT_PRICE      
   Where Product_Code = @ITEM_CODE And Opening_Date > @OpeningDate      
 END      
END      
      
IF @ADJTYPE = 2       
BEGIN         
 SET @SERVERDATE = dbo.StripDateFromTime(GetDate())        
 IF @FreeRow = 0 And @DAMAGEFLAG = 0        
 BEGIN        
   Update OpeningDetails Set         
   Opening_Quantity = Opening_Quantity + IsNull(@QTY_SHIFT,0),        
   Opening_Value = Opening_Value + IsNull(@VALUE_SHIFT, 0)        
   Where Opening_Date >= @OpeningDate And Product_Code = @ITEM_CODE        
 END        
 ELSE IF @FreeRow = 1        
 BEGIN        
  IF @DAMAGEFLAG = 0        
  BEGIN        
    Update OpeningDetails Set        
    Opening_Quantity = Opening_Quantity + IsNull(@QTY_SHIFT,0),        
    Free_Opening_Quantity = IsNull(Free_Opening_Quantity,0) + IsNull(@QTY_SHIFT,0),        
    Free_Saleable_Quantity = IsNull(Free_Saleable_Quantity,0) + IsNull(@QTY_SHIFT,0)        
    Where Product_Code = @ITEM_CODE And Opening_Date >= @OpeningDate        
  END        
  ELSE        
  BEGIN        
    Update OpeningDetails Set        
    Opening_Quantity = Opening_Quantity + IsNull(@QTY_SHIFT,0),        
    Free_Opening_Quantity = IsNull(Free_Opening_Quantity,0) + IsNull(@QTY_SHIFT,0),        
    Damage_Opening_Quantity = IsNull(Damage_Opening_Quantity,0) + IsNull(@QTY_SHIFT,0)        
    Where Product_Code = @ITEM_CODE And Opening_Date >= @OpeningDate        
  END        
 END        
 ELSE IF @DAMAGEFLAG > 0        
 BEGIN        
   Update OpeningDetails Set         
   Opening_Quantity = Opening_Quantity + IsNull(@QTY_SHIFT,0),        
   Opening_Value = Opening_Value + IsNull(@VALUE_SHIFT, 0),         
   Damage_Opening_Quantity = IsNull(Damage_Opening_Quantity,0) + IsNull(@QTY_SHIFT,0),        
   Damage_Opening_Value = IsNull(Damage_Opening_Value,0) + IsNull(@VALUE_SHIFT, 0)        
   Where Opening_Date >= @OpeningDate And Product_Code = @ITEM_CODE        
 END        
END       
  
If @ADJTYPE = 1 --Stock Adjustment Others  
Begin  
 If Exists (Select * from Batch_Products Where Batch_Code = @ORIGINAL_CODE And IsNull(DocType,0) = 5 And IsNull(DocID,0) = 0 AND IsNull(QuantityReceived,0)=0)  
 Begin  
  --Updating TaxSuff Percentage in OpeningDetails  
  Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @OpeningDate, @Item_Code, @ORIGINAL_CODE  
 End   
  
 --Updating field values for newly added batch thru StockAdjustment Others(F9 Option)  
 Update Batch_Products Set DocID = @STOCKID, QuantityReceived=@NEW_QTY   
 Where Batch_Code = @ORIGINAL_CODE And IsNull(DocType,0) = 5 And IsNull(DocID,0) = 0 AND IsNull(QuantityReceived,0)=0      
End  
  
  

