CREATE PROCEDURE sp_insert_grnstkadj_FMCG(@GRNID int,       
     @PRODUCT_CODE nvarchar(15),       
     @QUANTITY Decimal(18,6),      
     @SALE_PRICE Decimal(18,6),      
     @BATCH_NUMBER nvarchar(128),      
     @EXPIRY datetime,      
     @PKD nvarchar(12),      
     @FREE Int=0,      
     @OpeningDate datetime = Null,      
     @BackDatedTransaction int = 0,      
     @FrmStkAdj Int=0)      
AS          
DECLARE @PURCHASE_PRICE Decimal(18,6)      
DECLARE @PKD_DATE datetime      
DECLARE @PKD_TRACKED int      
DECLARE @BATCHCODE int      
DECLARE @DIFF Decimal(18,6)      
      
SET @BATCH_NUMBER = Replace(@BATCH_NUMBER, CHAR(9), N',')      
SELECT @PURCHASE_PRICE = Purchase_Price, @PKD_TRACKED = TrackPKD FROM Items WHERE Product_Code = @PRODUCT_CODE      
IF @PKD_TRACKED = 1      
BEGIN      
SET @PKD_DATE = N'1/' + substring(@PKD, 1, 2) + N'/' + substring(@PKD, 4, 4)      
IF ISNULL(@BATCH_NUMBER, N'') = N'' SET @BATCH_NUMBER = @PKD      
END      
ELSE      
 SET @PKD_DATE = Null      
      
IF @BackDatedTransaction = 1       
BEGIN      
SET @DIFF = @QUANTITY      
exec sp_update_opening_stock @PRODUCT_CODE, @OpeningDate, @DIFF, 0, @PURCHASE_PRICE      
END      
INSERT INTO Batch_Products(Batch_Number,      
      Product_Code,      
      GRN_ID,      
      Expiry,      
      Quantity,      
      SalePrice,      
      PurchasePrice,      
      QuantityReceived,      
      PKD,      
      Free,StkAdj,DocType,DocID)      
VALUES (@BATCH_NUMBER,      
  @PRODUCT_CODE,      
  @GRNID,      
  @EXPIRY,      
  @QUANTITY,      
  @SALE_PRICE,      
  @PURCHASE_PRICE,      
  @QUANTITY,      
  @PKD_DATE,      
  0,@FrmStkAdj,5,0)      
Select @@IDENTITY      
      
      
      
    
  
  
  


