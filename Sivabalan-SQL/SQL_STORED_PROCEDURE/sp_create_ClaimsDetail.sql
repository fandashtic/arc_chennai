CREATE PROCEDURE sp_create_ClaimsDetail(@ClaimID INT,     
 @ProductCode nvarchar(15),     
 @Batch nvarchar(128),    
 @Expiry datetime,    
 @UOM int, 
 @UOMConversion Decimal(18,6),
 @PurchasePrice Decimal(18,6),    
 @Quantity Decimal(18,6),     
 @Rate Decimal(18,6),    
 @TaxPercent Decimal(18,6),    
 @Taxamount Decimal(18,6),    
 @Remarks nvarchar(255),    
 @SchemeType int = 0,    
 @Damage Decimal(18,6) = 0,    
 @FlagScheme int = 0,  
 @Serial int = 0)    
AS    
DECLARE @TOTAL_QUANTITY Decimal(18,6)    
DECLARE @BATCH_QUANTITY Decimal(18,6)    
DECLARE @COST Decimal(18,6)    
DECLARE @BATCH_CODE int    
DECLARE @BATCH_NUMBER nvarchar(128)    
DECLARE @CLTYPE INT  
    
If @FlagScheme <> 0    
Begin    
 INSERT INTO     
 CLAIMSDETAIL  (ClaimID ,    
   Product_Code ,    
   Quantity ,    
   Rate ,    
   Remarks,    
   Batch,    
   Expiry,    
   PurchasePrice,    
   SchemeType,    
   Batch_Code,  
   Serial,
   UOMId, UOMConversion, TaxSuffPercent, TaxAmount)    
 VALUES      
   (@ClaimID ,     
   @ProductCode ,     
   @Quantity,     
   @Rate,    
   @Remarks,    
   @Batch,    
   @Expiry,    
   @PurchasePrice,    
   @SchemeType,    
   0,  
   @Serial,
   @UOM, @UOMConversion, @TaxPercent, @TaxAmount)     
 Select 1    
End    
Else    
Begin    
-- TAKE CLAIMTYPE INORDER TO FETCH EXPIRY ITEM ALONE FROM BATCH PRODUCTS TABLE  
 SELECT @CLTYPE = claimtype FROM claimsnote WHERE claimid = @ClaimID  
 SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity - ISNULL(ClaimedAlready, 0)), 0) FROM Batch_Products     
 WHERE Product_Code = @ProductCode AND ISNULL(PurchasePrice, 0) = @PurchasePrice     
 And Batch_Number = @Batch And ISNULL(Damage, 0) = @Damage     
 AND   ((@CLTYPE = 1 and Expiry = @Expiry) or (@CLTYPE <> 1 and (Expiry = @Expiry OR Expiry IS NULL)))   
 And (Quantity - ISNULL(ClaimedAlready, 0)) > 0    
     
 DECLARE ClaimStocks CURSOR KEYSET FOR    
 SELECT Batch_Code, Batch_Number,     
 ISNULL(SUM(Quantity - ISNULL(ClaimedAlready, 0)), 0), PurchasePrice    
 FROM Batch_Products     
 WHERE Product_Code = @ProductCode AND ISNULL(PurchasePrice, 0) = @PurchasePrice     
 And Batch_Number = @Batch And ISNULL(Damage, 0) = @Damage     
 AND   ((@CLTYPE = 1 and Expiry = @Expiry) or (@CLTYPE <> 1 and (Expiry = @Expiry OR Expiry IS NULL)))   
 And (Quantity - ISNULL(ClaimedAlready, 0)) > 0    
 Group By Batch_Code, Batch_Number, Expiry, PurchasePrice    
  
 IF @TOTAL_QUANTITY < @Quantity    
 BEGIN    
  SELECT 0    
  Goto Overout    
 END    
 ELSE    
 BEGIN    
  SELECT 1    
 END    
     
 Open ClaimStocks    
 FETCH FROM ClaimStocks Into @BATCH_CODE, @BATCH_NUMBER, @BATCH_QUANTITY, @COST    
 WHILE @@FETCH_STATUS = 0    
 BEGIN    
 SET @PurchasePrice = @COST
 IF @BATCH_QUANTITY >= @Quantity    
 BEGIN    
  UPDATE Batch_Products     
  SET ClaimedAlready = ISNULL(ClaimedAlready, 0) + @Quantity    
  WHERE Batch_Code = @BATCH_CODE   

  
 
  INSERT INTO     
  CLAIMSDETAIL  (ClaimID ,    
    Product_Code ,    
    Quantity ,    
    Rate ,    
    Remarks,    
    Batch,    
    Expiry,    
    PurchasePrice,    
    SchemeType,    
    Batch_Code,  
    serial,
    UOMId, UOMConversion, TaxSuffPercent,TaxAmount)    
  VALUES      
    (@ClaimID ,     
    @ProductCode ,      
    @Quantity,     
    @Rate ,    
    @Remarks,    
    @Batch,    
    @Expiry,    
    @PurchasePrice,    
    @SchemeType,    
    @Batch_Code,  
    @Serial,
    @UOM, @UOMConversion, @TaxPercent,@Taxamount) 
	/*only for damage claim*/
	if @CLTYPE = 2
	BEGIN
		update claimsdetail set taxamount = (isnull(quantity,0) * isnull(rate,0)) * (isnull(taxsuffpercent,0) /100.)
		where isnull(taxsuffpercent,0) > 0  and taxamount <> (isnull(quantity,0) * isnull(rate,0)) * (isnull(taxsuffpercent,0) /100.)
		and claimid = @ClaimID and product_code=@ProductCode and Batch_Code=@Batch_Code
	END   
  GOTO OverOut    
 END    
 ELSE    
 BEGIN    
  SET @Quantity = @Quantity - @BATCH_QUANTITY    
  UPDATE Batch_Products     
  SET ClaimedAlready = ISNULL(ClaimedAlready, 0) + @BATCH_QUANTITY    
  WHERE Batch_Code = @BATCH_CODE     
  INSERT INTO     
  CLAIMSDETAIL  (ClaimID ,    
    Product_Code ,    
    Quantity ,    
    Rate ,    
    Remarks,    
    Batch,    
    Expiry,    
    PurchasePrice,    
    SchemeType,    
    Batch_Code,  
    Serial, 
    UOMID, UOMConversion, TaxSuffPercent, TaxAmount)    
  VALUES      
    (@ClaimID ,     
    @ProductCode ,     
    @BATCH_QUANTITY ,     
    @Rate ,    
    @Remarks,    
    @Batch,    
    @Expiry,    
    @PurchasePrice,    
    @SchemeType,    
    @Batch_Code,  
    @Serial,
    @UOM, @UOMConversion, @TaxPercent,@Taxamount)    
  SET @PurchasePrice = 0    
  /*only for damage claim*/
  if @CLTYPE = 2
  BEGIN
	  update claimsdetail set taxamount = (isnull(quantity,0) * isnull(rate,0)) * (isnull(taxsuffpercent,0) /100.)
	  where isnull(taxsuffpercent,0) > 0  and taxamount <> (isnull(quantity,0) * isnull(rate,0)) * (isnull(taxsuffpercent,0) /100)
	  and claimid = @ClaimID and product_code=@ProductCode and Batch_Code=@Batch_Code
  END
 END    
 FETCH NEXT FROM ClaimStocks Into @BATCH_CODE, @BATCH_NUMBER, @BATCH_QUANTITY, @COST    
 END    
 OverOut:    
 Close ClaimStocks    
 DeAllocate ClaimStocks    
End
