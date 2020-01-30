CREATE Procedure sp_Save_RetailInvoiceDetail_DCSP_MUOM (@INVOICE_ID int,    
          @ITEM_CODE NVARCHAR(30),    
          @BATCH_NUMBER NVARCHAR(255),     
          @SALE_PRICE Decimal(18,6),     
          @REQUIRED_QUANTITY Decimal(18,6),    
          @SALE_TAX Decimal(18,6),    
          @DISCOUNT_PER Decimal(18,6),     
          @DISCOUNT_AMOUNT Decimal(18,6),    
          @AMOUNT Decimal(18,6),      
          @TRACK_BATCHES int,    
          @STPAYABLE Decimal(18,6),    
          @SCHEMEID int,    
          @PRIMARY_QUANTITY Decimal(18,6),    
          @SCHEME_COST Decimal(18,6),    
          @FLAG int,    
          @TAXCODE2 float,    
          @CSTPAYABLE Decimal(18,6),    
          @TAXSUFFERED Decimal(18,6) = 0,    
          @TAXSUFFERED2 Decimal(18,6) = 0,    
          @FreeRow Decimal(18,6) = 0,    
          @OpeningDate datetime = Null,    
          @BackDatedTransaction int = 0,  
   @UOM int,   
   @UOMQty Decimal(18, 6),   
   @UOMPrice Decimal(18, 6),
	@TaxID int,
	@GSTFlag int,
	@GSTCSTaxCode int 
)    
AS    
DECLARE @BATCH_CODE int     
DECLARE @COST Decimal(18,6)    
DECLARE @SALEID int    
DECLARE @PTR Decimal(18,6)    
DECLARE @PTS Decimal(18,6)    
DECLARE @MRP Decimal(18,6)    
--DECLARE @TAXID int    
DECLARE @DIFF Decimal(18,6)    
DECLARE @LOCALITY int    
DECLARE @SECONDARY_SCHEME int  
Declare @HSNNumber nvarchar(15)
Declare @CategorizationID int

Select @HSNNumber = isnull(HSNNumber,0), @CategorizationID = isnull(CategorizationID,0) From Items Where Product_Code = @ITEM_CODE
  
--Select @LOCALITY = IsNull(case InvoiceType When 2 Then 1 Else Locality End, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID *= Customer.CustomerID And InvoiceID = @INVOICE_ID    
--IF @LOCALITY = 0 SET @LOCALITY = 1    
--IF @LOCALITY = 1    
-- SELECT @TAXID = Tax_Code FROM Tax WHERE Percentage = @SALE_TAX    
--ELSE    
-- SELECT @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = @TAXCODE2   
 
IF @TRACK_BATCHES = 1    
Begin    
 DECLARE ReleaseStocks CURSOR KEYSET FOR    
 SELECT Batch_Number, Batch_Code, PurchasePrice, PTR, PTS, ECP    
 FROM Batch_Products    
 WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER     
 And ISNULL(Damage, 0) = 0 AND (Expiry >= GetDate() OR Expiry IS NULL)  
 And isnull(Free, 0) = @FreeRow    
End    
Else    
Begin    
 DECLARE ReleaseStocks CURSOR KEYSET FOR    
 SELECT Batch_Number, Batch_Code, PurchasePrice, PTR, PTS, ECP    
 FROM Batch_Products    
 WHERE Product_Code = @ITEM_CODE    
 And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow    
End    
Open ReleaseStocks    
    
SELECT @SALEID = SaleID, @COST = Purchase_Price, @MRP = MRP FROM Items     
WHERE Product_Code = @ITEM_CODE    
SET @COST = @COST    
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @REQUIRED_QUANTITY    
    
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @COST, @PTR, @PTS, @MRP    
UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY    
WHERE Batch_Code = @BATCH_CODE    
If @@RowCount = 0 And @FreeRow = 1    
Begin    
 IF @TRACK_BATCHES = 1    
 Begin    
  DECLARE ReleaseStocks CURSOR KEYSET FOR    
  SELECT Batch_Number, Batch_Code, PurchasePrice, PTR, PTS, ECP    
  FROM Batch_Products    
  WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER     
  AND (Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0    
 End    
Else    
 Begin    
  DECLARE ReleaseStocks CURSOR KEYSET FOR    
  SELECT Batch_Number, Batch_Code, PurchasePrice, PTR, PTS, ECP    
  FROM Batch_Products    
  WHERE Product_Code = @ITEM_CODE    
  And ISNULL(Damage, 0) = 0    
 End    
 Open ReleaseStocks    
 FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @COST, @PTR, @PTS, @MRP     
 UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY    
 WHERE Batch_Code = @BATCH_CODE    
End    
    
INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number,     
Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount,     
PurchasePrice, STPayable, SaleID, PTR, PTS, MRP, TaxID, FlagWord, TaxCode2,     
CSTPayable, TaxSuffered, TaxSuffered2,UOM,UOMQty,UOMPrice,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)     
VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @REQUIRED_QUANTITY,     
@SALE_PRICE, @SALE_TAX, @DISCOUNT_PER, @DISCOUNT_AMOUNT, @AMOUNT,     
@COST * @REQUIRED_QUANTITY, @STPAYABLE, @SALEID, @PTR, @PTS, @MRP, @TAXID, @FLAG,     
@TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @UOM, @UOMQty, @UOMPrice,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)    
    
IF @BackDatedTransaction = 1     
BEGIN    
 SET @DIFF = 0 - @REQUIRED_QUANTITY    
 exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @COST    
END    
    
IF @SCHEMEID <> 0    
BEGIN    
 Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SCHEMEID  
 Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags)  
 Values(@ITEM_CODE, @PRIMARY_QUANTITY, @REQUIRED_QUANTITY,     
 @SALE_PRICE * @REQUIRED_QUANTITY, @SCHEME_COST, @SCHEMEID, @INVOICE_ID, 0, @REQUIRED_QUANTITY, @SECONDARY_SCHEME)    
END    
SELECT 1    
OvernOut:    
CLOSE ReleaseStocks    
DEALLOCATE ReleaseStocks    

