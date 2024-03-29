   
Create Procedure sp_save_dispatchdetail_UOM_ITC(@DISPATCH_ID int,        
      @ITEM_CODE NVARCHAR(15),        
      @BATCH_NUMBER NVARCHAR(255),         
      @SALE_PRICE Decimal(18,6),         
      @REQUIRED_QUANTITY Decimal(18,6),        
      @TRACK_BATCHES int,        
      @TRACK_INVENTORY int,        
      @FLAG int,        
      @FreeRow Int = 0,        
      @OpeningDate datetime = Null,        
      @BackDatedTransaction int = 0,        
      @UOM Int,        
      @UOMQty Decimal(18,6),        
      @UOMPrice Decimal(18,6),        
      @Serial int = 0,        
      @OtherCG_Item int = 0,        
      @SchemeID Int = 0,      
      @FreeSerial nVarchar(255) ='',  
      @CSchemeID nVarchar(255) = N'',  
      @SPLCATSCHEMEID nVarchar(255) = N'',  
      @SpecialCategoryScheme INT =0,  
      @SPLCATSerial nvarchar(255) = N'',
      @MultiSchID nVarchar(255)= N'',  
      @MultiSchemeDetail nVarchar(2000)='' , 
      @MultiCatSchID nVarchar(255)= N'',  
      @MultiCatSchemeDetail nVarchar(2000)=''     
)        
AS        
DECLARE @BATCH_CODE int         
DECLARE @QUANTITY Decimal(18,6)        
DECLARE @RETVAL Decimal(18,6)        
DECLARE @TOTAL_QUANTITY Decimal(18,6)        
DECLARE @PURCHASEPRICE Decimal(18,6)        
DECLARE @DIFF Decimal(18,6)        
        
IF @TRACK_INVENTORY = 0        
BEGIN        
 SET @RETVAL = 1        
        INSERT INTO DispatchDetail(DispatchID, Product_Code, Batch_Code, Quantity,         
 SalePrice, FlagWord, UOM, UOMQty, UOMPrice, Serial, OtherCG_Item,SchemeID,FreeSerial,  
 CSchemeid,SPLCATSCHEMEID,SpecialCategoryScheme,SPLCATSerial ,
MultipleSchemeID,MultipleSchemeDetails, MultipleSplcatschemeid,MULTIPLESPLCATEGORYsCHDETAIL 
 )        
 VALUES (@DISPATCH_ID, @ITEM_CODE, 0, @REQUIRED_QUANTITY, @SALE_PRICE, @FLAG, @UOM,        
 @UOMQty, @UOMPrice, @Serial, @OtherCG_Item,@SchemeID,@FreeSerial,  
 @CSchemeID, @SPLCATSCHEMEID,@SpecialCategoryScheme,@SPLCATSerial ,
 @MultiSchID,@MultiSchemeDetail,@MultiCatSchID, @MultiCatSchemeDetail 
)        
 GOTO ALL_SAID_AND_DONE        
END        
IF @TRACK_BATCHES = 1        
 BEGIN        
 SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products         
 WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER         
 AND (Expiry >= GetDate() OR Expiry IS NULL)         
 And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow        
        
 DECLARE ReleaseStocks CURSOR KEYSET FOR        
 SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice FROM Batch_Products        
 WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER         
 AND ISNULL(Quantity, 0) > 0 AND (Expiry >= GetDate() OR Expiry IS NULL)         
 And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow        
        
 END        
ELSE        
 BEGIN        
 SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products         
 WHERE Product_Code = @ITEM_CODE And ISNULL(Damage, 0) = 0         
 And isnull(Free, 0) = @FreeRow        
        
 DECLARE ReleaseStocks CURSOR KEYSET FOR        
 SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice FROM Batch_Products        
 WHERE Product_Code = @ITEM_CODE AND ISNULL(Quantity, 0) > 0         
 And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow         
 END        
        
OPEN ReleaseStocks        
IF @TOTAL_QUANTITY < @REQUIRED_QUANTITY        
 BEGIN        
 SET @RETVAL = 0        
 GOTO OVERNOUT        
 END        
ELSE        
 BEGIN        
 SET @RETVAL = 1        
 END        
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @PURCHASEPRICE        
        
WHILE @@FETCH_STATUS = 0        
BEGIN        
    IF @QUANTITY >= @REQUIRED_QUANTITY        
 BEGIN        
        UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY        
        WHERE Batch_Code = @BATCH_CODE        
     
 IF @@ROWCOUNT = 0        
 BEGIN        
  SET @RETVAL = 0        
  GOTO OVERNOUT        
 END        
        INSERT INTO DispatchDetail(DispatchID, Product_Code, Batch_Code, Quantity,         
 SalePrice, FlagWord, UOM, UOMQty, UOMPrice, Serial, OtherCG_Item,SchemeID,FreeSerial,  
CSchemeid,SPLCATSCHEMEID,SpecialCategoryScheme,SPLCATSerial,
MultipleSchemeID,MultipleSchemeDetails, MultipleSplcatschemeid,MULTIPLESPLCATEGORYsCHDETAIL)         
 VALUES (@DISPATCH_ID, @ITEM_CODE, @BATCH_CODE, @REQUIRED_QUANTITY, @SALE_PRICE,         
 @FLAG, @UOM, @UOMQty, @UOMPrice, @Serial, @OtherCG_Item,@SchemeID,@FreeSerial,  
 @CSchemeID, @SPLCATSCHEMEID,@SpecialCategoryScheme,@SPLCATSerial,
 @MultiSchID,@MultiSchemeDetail,@MultiCatSchID, @MultiCatSchemeDetail)        
 IF @BackDatedTransaction = 1         
 BEGIN        
 SET @DIFF = 0 - @REQUIRED_QUANTITY        
 exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @PURCHASEPRICE, 0, 0, @BATCH_CODE
 END        
        GOTO OVERNOUT        
 END        
    ELSE        
 BEGIN        
 set @REQUIRED_QUANTITY = @REQUIRED_QUANTITY - @QUANTITY        
 UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE        
 IF @@ROWCOUNT = 0        
 BEGIN        
  SET @RETVAL = 0        
  GOTO OVERNOUT        
 END        
        INSERT INTO DispatchDetail(DispatchID, Product_Code, Batch_Code, Quantity,         
 SalePrice, FlagWord, UOM, UOMQty, UOMPrice, Serial, OtherCG_Item,SchemeID,FreeSerial,  
 CSchemeid,SPLCATSCHEMEID,SpecialCategoryScheme,SPLCATSerial,
MultipleSchemeID,MultipleSchemeDetails, MultipleSplcatschemeid,MULTIPLESPLCATEGORYsCHDETAIL)        
 VALUES (@DISPATCH_ID, @ITEM_CODE, @BATCH_CODE, @QUANTITY, @SALE_PRICE, @FLAG, @UOM,        
 @UOMQty, @UOMPrice, @Serial, @OtherCG_Item,@SchemeID,@FreeSerial,  
 @CSchemeID, @SPLCATSCHEMEID,@SpecialCategoryScheme,@SPLCATSerial,
@MultiSchID,@MultiSchemeDetail,@MultiCatSchID, @MultiCatSchemeDetail)        
 IF @BackDatedTransaction = 1         
 BEGIN        
 SET @DIFF = 0 - @QUANTITY        
 exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @PURCHASEPRICE, 0,  0, @BATCH_CODE
 END        
 END         
 Set @UOMQty = 0        
    FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @PURCHASEPRICE        
END        
OVERNOUT:        
CLOSE ReleaseStocks        
DEALLOCATE ReleaseStocks        
ALL_SAID_AND_DONE:        
SELECT @RETVAL        
  
