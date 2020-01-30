CREATE Procedure sp_save_Invoicedetail_DCSP_MUOM(@INVOICE_ID int,  
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
          @TAXCODE2 Decimal(18,6),  
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
		@GSTCSTaxCode int)    
AS  
DECLARE @BATCH_CODE int   
DECLARE @QUANTITY Decimal(18,6)  
DECLARE @RETVAL Decimal(18,6)  
DECLARE @TOTAL_QUANTITY Decimal(18,6)  
DECLARE @COST Decimal(18,6)  
DECLARE @SALEID int  
DECLARE @ORIGINAL_QTY Decimal(18,6)  
DECLARE @PTR Decimal(18,6)  
DECLARE @PTS Decimal(18,6)  
DECLARE @MRP Decimal(18,6)  
--DECLARE @TAXID int  
DECLARE @DIFF Decimal(18,6)  
DECLARE @LOCALITY int  
DECLARE @PRICEOPTION int  
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
SET @ORIGINAL_QTY = @REQUIRED_QUANTITY  
Retry:  
IF @TRACK_BATCHES = 1  
 BEGIN  
 SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
 WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
 And ISNULL(Damage, 0) = 0 AND (Expiry >= GetDate() OR Expiry IS NULL)  
 And isnull(Free, 0) = @FreeRow  
   
 DECLARE ReleaseStocks CURSOR KEYSET FOR  
 SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP  
 FROM Batch_Products  
 WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
 AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0   
 AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow  
   
 END  
ELSE  
 BEGIN  
 SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
 WHERE Product_Code = @ITEM_CODE And ISNULL(Damage, 0) = 0   
 And isnull(Free, 0) = @FreeRow  
  
 DECLARE ReleaseStocks CURSOR KEYSET FOR  
 SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP  
 FROM Batch_Products  
 WHERE Product_Code = @ITEM_CODE AND ISNULL(Quantity, 0) > 0   
 And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
   
 END  
  
SELECT @SALEID = SaleID, @COST = Purchase_Price, @MRP = MRP, @PRICEOPTION = Price_Option  
FROM Items, ItemCategories  
WHERE Product_Code = @ITEM_CODE And Items.CategoryID = ItemCategories.CategoryID  
SET @COST = @COST  
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @REQUIRED_QUANTITY  
  
OPEN ReleaseStocks  
IF @TOTAL_QUANTITY < @REQUIRED_QUANTITY  
 BEGIN  
 IF @PRICEOPTION = 0 And @TRACK_BATCHES = 0 And @FreeRow = 1  
 BEGIN  
 SET @FreeRow = 0  
 Close ReleaseStocks  
 DeAllocate ReleaseStocks  
 GOTO Retry  
 END  
 SET @RETVAL = 0  
 GOTO OVERNOUT  
 END  
ELSE  
 BEGIN  
 SET @RETVAL = 1  
 END  
  
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @PTR, @PTS, @MRP  
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
    IF @QUANTITY >= @REQUIRED_QUANTITY  
 BEGIN  
        UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY  
        WHERE Batch_Code = @BATCH_CODE  
  
        INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number,   
 Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount,   
 PurchasePrice, STPayable, SaleID, PTR, PTS, MRP, TaxID, FlagWord, TaxCode2,   
 CSTPayable, TaxSuffered, TaxSuffered2, UOM, UOMQty, UOMPrice,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)   
 VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @REQUIRED_QUANTITY,   
 @SALE_PRICE, @SALE_TAX, @DISCOUNT_PER, @DISCOUNT_AMOUNT, @AMOUNT,   
 @COST * @REQUIRED_QUANTITY, @STPAYABLE, @SALEID, @PTR, @PTS, @MRP, @TAXID, @FLAG,   
 @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @UOM, @UOMQty, @UOMPrice,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)  
 IF @BackDatedTransaction = 1   
 BEGIN  
 SET @DIFF = 0 - @REQUIRED_QUANTITY  
 exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @COST  
 END  
        GOTO OVERNOUT  
 END  
    ELSE  
 BEGIN  
 set @REQUIRED_QUANTITY = @REQUIRED_QUANTITY - @QUANTITY  
 UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE  
        INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number,   
 Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount,   
 PurchasePrice, STPayable, SaleID, PTR, PTS, MRP, TaxID, FlagWord, TaxCode2,   
 CSTPayable, TaxSuffered, TaxSuffered2, UOM, UOMQty, UOMPrice,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)  
 VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @QUANTITY,   
 @SALE_PRICE, @SALE_TAX, @DISCOUNT_PER, @DISCOUNT_AMOUNT, @AMOUNT,   
 @COST * @QUANTITY, @STPAYABLE, @SALEID, @PTR, @PTS, @MRP, @TAXID, @FLAG, @TAXCODE2,   
 @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @UOM, @UOMQty, @UOMPrice,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)  
 SET @SALE_TAX = 0  
 SET @AMOUNT = 0  
 SET @DISCOUNT_PER = 0  
 SET @DISCOUNT_AMOUNT = 0  
 SET @STPAYABLE = 0  
 SET @CSTPAYABLE = 0  
 SET @TAXCODE2 = 0  
 SET @TAXSUFFERED = 0  
 SET @TAXSUFFERED2 = 0  
 SET @UOMQty = 0  
 IF @BackDatedTransaction = 1   
 BEGIN  
 SET @DIFF = 0 - @QUANTITY  
 exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @COST  
 END  
 END   
    FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @PTR, @PTS, @MRP  
END  
OVERNOUT:  
CLOSE ReleaseStocks  
DEALLOCATE ReleaseStocks  
IF @SCHEMEID <> 0  
BEGIN  
 Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SCHEMEID  
 Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags)   
 Values(@ITEM_CODE, @PRIMARY_QUANTITY, @ORIGINAL_QTY, @SALE_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SCHEMEID, @INVOICE_ID, 0, @ORIGINAL_QTY, @SECONDARY_SCHEME)  
END  
SELECT @RETVAL  

