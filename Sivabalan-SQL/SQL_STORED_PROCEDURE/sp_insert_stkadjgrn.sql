CREATE PROCEDURE sp_insert_stkadjgrn(@GRNID int,       
     @PRODUCT_CODE nvarchar(15),       
     @QUANTITY Decimal(18,6),      
     @SALE_PRICE Decimal(18,6),      
     @BATCH_NUMBER nvarchar(128),      
     @EXPIRY datetime,      
     @PTS Decimal(18,6),      
     @PTR Decimal(18,6),      
     @ECP Decimal(18,6),      
     @PRICEOPTION int,      
     @SPECIAL_PRICE Decimal(18,6),      
     @PKD nvarchar(12),      
     @FREE Int,      
     @OpeningDate datetime = Null,      
     @BackDatedTransaction int = 0,      
     @StkAdj Int = 0, 
	 @TaxType Int = 1)      
AS      
DECLARE @PURCHASE_PRICE Decimal(18,6)      
DECLARE @PKD_DATE datetime      
DECLARE @PKD_TRACKED int      
DECLARE @BATCHCODE int      
DECLARE @DIFF Decimal(18,6)      
      
SET @BATCH_NUMBER = Replace(@BATCH_NUMBER, CHAR(9), N',')      
IF @PRICEOPTION = 0      
 SELECT @PURCHASE_PRICE = Purchase_Price, @PKD_TRACKED = TrackPKD FROM Items WHERE Product_Code = @PRODUCT_CODE      
ELSE      
 SELECT @PURCHASE_PRICE = Case Purchased_At       
    WHEN 1 THEN @PTS      
    WHEN 2 THEN @PTR      
    ELSE Items.Purchase_Price      
    END,       
    @PKD_TRACKED = TrackPKD      
    FROM Items WHERE Product_Code = @PRODUCT_CODE      
SELECT @PKD_TRACKED = TrackPKD FROM Items WHERE Product_Code = @PRODUCT_CODE      
IF @PKD_TRACKED = 1      
BEGIN      
SET @PKD_DATE = N'1/' + substring(@PKD, 1, 2) + N'/' + substring(@PKD, 4, 4)      
IF ISNULL(@BATCH_NUMBER, N'') = N'' SET @BATCH_NUMBER = @PKD      
END      
ELSE      
 SET @PKD_DATE = Null      
      
   
INSERT INTO Batch_Products(Batch_Number,      
      Product_Code,      
      GRN_ID,      
      Expiry,      
      Quantity,      
      SalePrice,      
      PTS,      
      PTR,      
      ECP,      
      PurchasePrice,      
      QuantityReceived,      
      Company_Price,      
      PKD,       
      Free,StkAdj,DocType,DocId, taxtype)      
VALUES (@BATCH_NUMBER,      
  @PRODUCT_CODE,      
  @GRNID,      
  @EXPIRY,      
  @QUANTITY,      
  @SALE_PRICE,      
  @PTS,      
  @PTR,      
  @ECP,      
  @PURCHASE_PRICE,      
  @QUANTITY,      
  @SPECIAL_PRICE,      
  @PKD_DATE,      
  0,@STKAdj,5,0, @TaxType)      
Select @BATCHCODE = @@IDENTITY  
  
IF @BackDatedTransaction = 1       
BEGIN      
	SET @DIFF = @QUANTITY      
	exec sp_update_opening_stock @PRODUCT_CODE, @OpeningDate, @DIFF, 0, @PURCHASE_PRICE ,0 ,0 , @BATCHCODE     
END  

Select @BATCHCODE

