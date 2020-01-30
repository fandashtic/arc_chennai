CREATE Procedure sp_save_invoice_detail_CSP(@INVOICE_ID int,  
          @ITEM_CODE NVARCHAR(15),  
          @BATCH_NUMBER NVARCHAR(255),   
          @SALE_PRICE Decimal(18,6),   
          @REQUIRED_QUANTITY Decimal(18,6),  
          @TRACK_BATCHES int,  
          @TRACK_INVENTORY int,  
          @TAXCODE Decimal(18,6),  
          @DISCOUNTPERCENTAGE Decimal(18,6),  
          @DISCOUNTAMOUNT Decimal(18,6),  
          @AMOUNT Decimal(18,6),  
          @STPAYABLE Decimal(18,6),  
          @CUSTOMER_TYPE int,  
          @SCHEMEID int,  
		  @PRIMARY_QUANTITY Decimal(18,6),  
          @SCHEME_COST Decimal(18,6),  
          @MODIFIED_PRICE Decimal(18,6),  
          @FLAG int,  
          @TAXCODE2 Decimal(18,6),  
          @CSTPAYABLE Decimal(18,6),  
          @TAXSUFFERED Decimal(18,6) = 0,  
          @TAXSUFFERED2 Decimal(18,6) = 0,  
          @UNUSED int = 0,  
          @UNUSED2 nvarchar(50) = N'',  
          @FreeRow Decimal(18,6) = 0,  
          @OpeningDate datetime = Null,  
          @BackDatedTransaction int = 0)  
AS  
DECLARE @BATCH_CODE int   
DECLARE @QUANTITY Decimal(18,6)  
DECLARE @RETVAL Decimal(18,6)  
DECLARE @TOTAL_QUANTITY Decimal(18,6)  
DECLARE @COST Decimal(18,6)  
DECLARE @ORIGINAL_QTY Decimal(18,6)  
DECLARE @PTS Decimal(18,6)  
DECLARE @PTR Decimal(18,6)  
DECLARE @MRP Decimal(18,6)  
DECLARE @TAXID int  
DECLARE @SALEID int  
DECLARE @DIFF Decimal(18,6)  
DECLARE @LOCALITY int  
DECLARE @SECONDARY_SCHEME int  
  
Select @LOCALITY = IsNull(Locality, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceID = @INVOICE_ID  
IF @LOCALITY = 0 SET @LOCALITY = 1  
IF @LOCALITY = 1  
 SELECT @TAXID = Tax_Code FROM Tax WHERE Percentage = @TAXCODE  
ELSE  
 SELECT @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = @TAXCODE2  
  
SET @ORIGINAL_QTY = @REQUIRED_QUANTITY  
SELECT @COST = Purchase_Price, @MRP = MRP, @SALEID = SaleID FROM Items WHERE Product_code = @ITEM_CODE  
SET @COST = @COST  
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @REQUIRED_QUANTITY  
IF @TRACK_INVENTORY = 0  
BEGIN  
 SET @RETVAL = 1  
 INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number, Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount, PurchasePrice, STPayable, TaxID,   
 FlagWord, SaleID, TaxCode2, CSTPayable, TaxSuffered, TaxSuffered2)  
 VALUES (@INVOICE_ID, @ITEM_CODE, 0, N'', @REQUIRED_QUANTITY, @MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT, @COST * @REQUIRED_QUANTITY, @STPAYABLE, @TAXID,   
 @FLAG, @SALEID, @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2)  
 GOTO ALL_SAID_AND_DONE  
END  
IF @TRACK_BATCHES = 1  
 BEGIN  
 IF @CUSTOMER_TYPE = 1  
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
  WHERE Product_Code = @ITEM_CODE AND   
  ISNULL(Batch_Number, N'') = @BATCH_NUMBER AND   
  ISNULL(PTS, 0) = @SALE_PRICE AND (Expiry >= GetDate() OR Expiry IS NULL)   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
 ELSE IF @CUSTOMER_TYPE = 2  
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
  WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER  
  AND ISNULL(PTR, 0) = @SALE_PRICE AND (Expiry >= GetDate() OR Expiry IS NULL)   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
 ELSE IF @CUSTOMER_TYPE = 3  
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
  WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
  AND ISNULL(Company_Price, 0) = @SALE_PRICE AND   
  (Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0   
  And isnull(Free, 0) = @FreeRow  
 ELSE IF @CUSTOMER_TYPE = 4  
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
  WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER     
  AND ISNULL(SalePrice, 0) = @SALE_PRICE AND   
  (Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0   
  And isnull(Free, 0) = @FreeRow    
  
  
 IF @CUSTOMER_TYPE = 1  
  BEGIN  
  DECLARE ReleaseStocks CURSOR KEYSET FOR  
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP  
  FROM Batch_Products  
  WHERE Product_Code = @ITEM_CODE   
  and ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
  and ISNULL(PTS, 0) = @SALE_PRICE AND ISNULL(Quantity, 0) > 0   
  AND (Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0  
  And isnull(Free, 0) = @FreeRow  
  END  
 ELSE IF @CUSTOMER_TYPE = 2  
  BEGIN  
  DECLARE ReleaseStocks CURSOR KEYSET FOR  
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP  
  FROM Batch_Products  
  WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
  and ISNULL(PTR, 0) = @SALE_PRICE AND ISNULL(Quantity, 0) > 0   
  AND (Expiry >= GetDate() OR Expiry IS NULL)   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
  END  
 ELSE IF @CUSTOMER_TYPE = 3  
  BEGIN  
  DECLARE ReleaseStocks CURSOR KEYSET FOR  
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP  
  FROM Batch_Products  
  WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
  and ISNULL(Company_Price, 0) = @SALE_PRICE AND ISNULL(Quantity, 0) > 0   
  AND (Expiry >= GetDate() OR Expiry IS NULL)   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
  END  
 ELSE IF @CUSTOMER_TYPE = 4  
  BEGIN  
  DECLARE ReleaseStocks CURSOR KEYSET FOR    
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP   
  FROM Batch_Products    
  WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
  and ISNULL(SalePrice, 0) = @SALE_PRICE AND ISNULL(Quantity, 0) > 0   
  AND (Expiry >= GetDate() OR Expiry IS NULL)   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow    
  END  
 END  
ELSE  
 BEGIN  
 IF @CUSTOMER_TYPE = 1  
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
  WHERE Product_Code = @ITEM_CODE AND ISNULL(PTS, 0) = @SALE_PRICE   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
 ELSE IF @CUSTOMER_TYPE = 2  
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
  WHERE Product_Code = @ITEM_CODE AND ISNULL(PTR, 0) = @SALE_PRICE   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
 ELSE IF @CUSTOMER_TYPE = 3  
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
  WHERE Product_Code = @ITEM_CODE AND ISNULL(Company_Price, 0) = @SALE_PRICE   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
 ELSE IF @CUSTOMER_TYPE = 4  
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
  WHERE Product_Code = @ITEM_CODE AND ISNULL(SalePrice, 0) = @SALE_PRICE   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
  
 IF @CUSTOMER_TYPE = 1  
  BEGIN  
  DECLARE ReleaseStocks CURSOR KEYSET FOR  
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP  
  FROM Batch_Products  
  WHERE Product_Code = @ITEM_CODE AND ISNULL(PTS, 0) = @SALE_PRICE   
  AND ISNULL(Quantity, 0) > 0   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
  END  
 ELSE IF @CUSTOMER_TYPE = 2  
  BEGIN  
  DECLARE ReleaseStocks CURSOR KEYSET FOR  
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP  
  FROM Batch_Products  
  WHERE Product_Code = @ITEM_CODE AND ISNULL(PTR, 0) = @SALE_PRICE   
  AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0   
  And isnull(Free, 0) = @FreeRow  
  END  
 ELSE IF @CUSTOMER_TYPE = 3  
  BEGIN  
  DECLARE ReleaseStocks CURSOR KEYSET FOR  
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP  
  FROM Batch_Products  
  WHERE Product_Code = @ITEM_CODE AND ISNULL(Company_Price, 0) = @SALE_PRICE   
  AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0   
  And isnull(Free, 0) = @FreeRow  
  END  
 ELSE IF @CUSTOMER_TYPE = 4  
  BEGIN  
  DECLARE ReleaseStocks CURSOR KEYSET FOR    
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP   
  FROM Batch_Products    
  WHERE Product_Code = @ITEM_CODE AND ISNULL(SalePrice, 0) = @SALE_PRICE   
  AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0   
  And isnull(Free, 0) = @FreeRow    
  END  
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
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @PTR, @PTS, @MRP  
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
    IF @QUANTITY >= @REQUIRED_QUANTITY  
 BEGIN  
        UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY  
        WHERE Batch_Code = @BATCH_CODE  
  
 IF @@ROWCOUNT = 0  
 BEGIN  
  SET @RETVAL = 1  
  GOTO OVERNOUT  
 END  
 INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number,   
 Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount,   
 PurchasePrice, STPayable, PTR, PTS, MRP, TaxID, FlagWord, SaleID,   
 TaxCode2, CSTPayable, TaxSuffered, TaxSuffered2)  
 VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @REQUIRED_QUANTITY,   
 @MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT,   
 @REQUIRED_QUANTITY * @COST, @STPAYABLE, @PTR, @PTS, @MRP, @TAXID, @FLAG,   
 @SALEID, @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2)  
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
 IF @@ROWCOUNT = 0  
 BEGIN  
  SET @RETVAL = 1  
  GOTO OVERNOUT  
 END  
 INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number,   
 Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount,   
 PurchasePrice, STPayable, PTR, PTS, MRP, TaxID, FlagWord, SaleID, TaxCode2,   
 CSTPayable, TaxSuffered, TaxSuffered2)  
 VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @QUANTITY,   
 @MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT,   
 @COST * @QUANTITY, @STPAYABLE, @PTR, @PTS, @MRP, @TAXID, @FLAG, @SALEID,   
 @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2)  
 SET @TAXCODE = 0  
 SET @DISCOUNTPERCENTAGE = 0  
 SET @DISCOUNTAMOUNT = 0  
 SET @AMOUNT = 0  
 SET @STPAYABLE = 0  
 SET @CSTPAYABLE = 0  
 SET @TAXCODE2 = 0  
 SET @TAXSUFFERED = 0  
 SET @TAXSUFFERED2 = 0  
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
ALL_SAID_AND_DONE:  
IF @SCHEMEID <> 0  
BEGIN  
 Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SCHEMEID  
 Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags)   
 Values(@ITEM_CODE, @PRIMARY_QUANTITY, @ORIGINAL_QTY, @MODIFIED_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SCHEMEID, @INVOICE_ID, 0, @ORIGINAL_QTY, @SECONDARY_SCHEME)  
END  
SELECT @RETVAL

