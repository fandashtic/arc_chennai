
Create Procedure sp_save_invoice_detail_CSP_VanReturn_MUOM(@INVOICE_ID int,      
          @ITEM_CODE NVARCHAR(15),      
          @BATCH_NUMBER NVARCHAR(255),       
          @SALE_PRICE Decimal(18,6),       
          @REQUIRED_QUANTITY Decimal(18,6),      
          @TRACK_BATCHES int,      
          @TRACK_INVENTORY int,      
          @TAXCODE FLOAT,      
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
          @TAXCODE2 FLOAT,      
          @CSTPAYABLE Decimal(18,6),      
          @TAXSUFFERED Decimal(18,6) = 0,      
          @TAXSUFFERED2 Decimal(18,6) = 0,      
          @DAMAGES Decimal(18,6) = 0,      
          @DAMAGESREASON nvarchar(50),      
          @FreeRow Decimal(18,6) = 0,      
          @OpeningDate datetime = Null,      
          @BackDatedTransaction int = 0,      
          @UOM int = 0,      
          @UOMQty Decimal(18, 6) = 0,      
          @UOMPrice Decimal(18, 6) = 0, 
	  @DOCSERIAL Int = 0)      
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
DECLARE @EXPIRY datetime      
DECLARE @PURCHASEPRICE Decimal(18,6)      
DECLARE @ECP Decimal(18,6)      
DECLARE @SPECIAL_PRICE Decimal(18,6)      
DECLARE @REASON_ID int      
DECLARE @PKD_DATE datetime      
DECLARE @DIFF Decimal(18,6)      
DECLARE @LOCALITY int      
DECLARE @TAXSUFFERED_ORIG Decimal(18, 6)      
DECLARE @SECONDARY_SCHEME int      
DECLARE @IS_VAT_ITEM Int  
DECLARE @ADD_TAXSUFF_TO_OPDET int  
DECLARE @CNT Int
Set @ADD_TAXSUFF_TO_OPDET = 0  
set @CNT = 0       
Select @LOCALITY = IsNull(Locality, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceID = @INVOICE_ID      
IF @LOCALITY = 0 SET @LOCALITY = 1      
IF @LOCALITY = 1      
 SELECT @TAXID = Tax_Code FROM Tax WHERE Percentage = @TAXCODE      
ELSE      
 SELECT @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = @TAXCODE2      
      
EXEC sp_update_openingdetails_firsttime @ITEM_CODE      
IF NOT EXISTS (SELECT MessageID FROM StockAdjustmentReason WHERE Message = @DAMAGESREASON)      
BEGIN      
  INSERT INTO StockAdjustmentReason(Message, Active) Values (@DAMAGESREASON, 1)      
END      
      
SELECT @REASON_ID = ISNULL(MessageID, 0) FROM StockAdjustmentReason WHERE Message = @DAMAGESREASON      
SET @ORIGINAL_QTY = @REQUIRED_QUANTITY      
SELECT @COST = Purchase_Price, @MRP = MRP, @SALEID = SaleID FROM Items WHERE Product_code = @ITEM_CODE      
SET @COST = @COST      
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @REQUIRED_QUANTITY      
IF @TRACK_INVENTORY = 0      
BEGIN      
 SET @RETVAL = 1      
 INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number, Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue,       
 Amount, PurchasePrice, STPayable, TaxID, FlagWord, SaleID, TaxCode2, CSTPayable, TaxSuffered, TaxSuffered2, ReasonID, UOM, UOMQty, UOMPrice)      
 VALUES (@INVOICE_ID, @ITEM_CODE, 0, N'', @REQUIRED_QUANTITY, @MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT,       
 @COST * @REQUIRED_QUANTITY, @STPAYABLE, @TAXID, @FLAG, @SALEID, @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @REASON_ID, @UOM, @UOMQty, @UOMPrice)      
 GOTO ALL_SAID_AND_DONE 
END

IF @FREEROW=1 
    SELECT @CNT = Count(*) FROM 
    (SELECT Distinct Batch_Code From VanStatementDetail  
    WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, '') = @BATCH_NUMBER  
       AND DocSerial = @DOCSERIAL AND IsNull(SalePrice,0) = 0) A 
ELSE  
    SELECT @CNT = Count(*) FROM 
    (SELECT Distinct Batch_Code From VanStatementDetail  
    WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, '') = @BATCH_NUMBER  
       AND DocSerial = @DOCSERIAL AND IsNull(SalePrice,0) <> 0 )A
      
IF @TRACK_BATCHES = 1      
 BEGIN      
 IF @CUSTOMER_TYPE = 1      
  BEGIN      
  DECLARE ReleaseStocks CURSOR KEYSET FOR      
  SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS, Expiry,       
  PurchasePrice, ECP, Company_Price, PKD, TaxSuffered FROM Batch_Products      
  WHERE Product_Code = @ITEM_CODE       
  And ISNULL(Batch_Number, N'') = @BATCH_NUMBER       
  And ISNULL(PTS, 0) = @SALE_PRICE       
  And (Expiry >= GetDate() OR Expiry IS NULL)      
  And IsNull(Free, 0) = @FreeRow      
  And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
  END      
 ELSE IF @CUSTOMER_TYPE = 2      
  BEGIN      
  DECLARE ReleaseStocks CURSOR KEYSET FOR      
  SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS, Expiry,       
  PurchasePrice, ECP, Company_Price, PKD, TaxSuffered FROM Batch_Products      
  WHERE Product_Code = @ITEM_CODE       
  And ISNULL(Batch_Number, N'') = @BATCH_NUMBER       
  And ISNULL(PTR, 0) = @SALE_PRICE       
  And (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow      
  And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)      
  END      
 ELSE IF @CUSTOMER_TYPE = 3      
  BEGIN      
  DECLARE ReleaseStocks CURSOR KEYSET FOR      
  SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS,       
  Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered FROM Batch_Products      
  WHERE Product_Code = @ITEM_CODE       
  And ISNULL(Batch_Number, N'') = @BATCH_NUMBER       
  And ISNULL(Company_Price, 0) = @SALE_PRICE       
  And (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow      
  And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)      
  END      
 END      
ELSE      
 BEGIN      
 IF @CUSTOMER_TYPE = 1      
  BEGIN      
  DECLARE ReleaseStocks CURSOR KEYSET FOR      
  SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS,       
  Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered FROM Batch_Products      
  WHERE Product_Code = @ITEM_CODE       
  And IsNull(PTS, 0) = @SALE_PRICE 
  And IsNull(Free, 0) = @FreeRow      
  And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)      
  END      
 ELSE IF @CUSTOMER_TYPE = 2      
  BEGIN      
  DECLARE ReleaseStocks CURSOR KEYSET FOR      
  SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS,       
  Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered FROM Batch_Products      
  WHERE Product_Code = @ITEM_CODE       
  And IsNull(PTR, 0) = @SALE_PRICE 
  And IsNull(Free, 0) = @FreeRow      
  And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)      
  END      
 ELSE IF @CUSTOMER_TYPE = 3      
  BEGIN      
  DECLARE ReleaseStocks CURSOR KEYSET FOR      
  SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS,       
  Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered FROM Batch_Products      
  WHERE Product_Code = @ITEM_CODE       
  And IsNull(Company_Price, 0) = @SALE_PRICE 
  And IsNull(Free, 0) = @FreeRow      
  And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)      
  END       
 END      
      
OPEN ReleaseStocks      
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @PTR, @PTS,       
@EXPIRY, @PURCHASEPRICE, @ECP, @SPECIAL_PRICE, @PKD_DATE, @TAXSUFFERED_ORIG      
      
IF @@FETCH_STATUS <> 0       
 BEGIN      
 SET @RETVAL = 0      
 GOTO OVERNOUT      
 END      
ELSE      
 BEGIN      
 SET @RETVAL = 1      
 IF @DAMAGES = 0      
     BEGIN      
	IF @CNT > 1     
	   BEGIN
	   IF @FREEROW=1
	     UPDATE VanstatementDetail 
	     SET Pending = Pending + @REQUIRED_QUANTITY, Quantity = Quantity + @REQUIRED_QUANTITY
	     WHERE Batch_Code = @BATCH_CODE And Product_Code = @ITEM_CODE   
	      And Batch_Number = @BATCH_NUMBER And DocSerial = @DOCSERIAL  
	      And IsNull(UOM,0) = @UOM
	   ELSE
	     UPDATE VanstatementDetail 
	     SET Pending = Pending + @REQUIRED_QUANTITY, Quantity = Quantity + @REQUIRED_QUANTITY
	     WHERE Batch_Code = @BATCH_CODE And Product_Code = @ITEM_CODE   
	      And Batch_Number = @BATCH_NUMBER And DocSerial = @DOCSERIAL  And IsNull(UOM,0) = @UOM
	      And VanTransferId in (Select DocSerial From VanTransferDetail   
				Where Product_Code = @ITEM_CODE   
				And Batch_code = @BATCH_CODE  
				And IsNull(BatchNumber,'') = @BATCH_NUMBER)
	   END
	ELSE IF @CNT=1
	   BEGIN
	   UPDATE VanstatementDetail 
	   SET Pending = Pending + @REQUIRED_QUANTITY, Quantity = Quantity + @REQUIRED_QUANTITY
    	   WHERE Batch_Code = @BATCH_CODE And Product_Code = @ITEM_CODE 
	   And IsNull(Batch_Number,'') = @BATCH_NUMBER And DocSerial = @DOCSERIAL
	   END 
        ELSE
     	   BEGIN
	   -- To insert the Record in VanStatementDetail
	   INSERT into VanStatementDetail(DocSerial, Product_Code, Batch_Code, Batch_Number, 
		Quantity, Pending, SalePrice, Amount, PurchasePrice, BFQty, PTS, PTR, ECP, 
		SpecialPrice, TransferQty, VanTransferID, TransferItemSerial, UOM, UOMQty, UOMPrice)  
	   VALUES(@DOCSERIAL, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, 		  
		@REQUIRED_QUANTITY, @REQUIRED_QUANTITY, @SALE_PRICE, @AMOUNT, @PURCHASEPRICE, 0, @PTR, @PTS, @ECP, 
		@SPECIAL_PRICE, 0, @DOCSERIAL,0, @UOM, @UOMQty, @UOMPrice)
	   END	
    INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number,       
	   Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount,       
	   PurchasePrice, STPayable, SaleID, PTR, PTS, MRP, TaxID, FlagWord, TaxCode2,       
	   CSTPayable, TaxSuffered, TaxSuffered2, ReasonID, UOM, UOMQty, UOMPrice)      
    VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @REQUIRED_QUANTITY,       
	   @SALE_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT,       
	   @COST * @REQUIRED_QUANTITY, @STPAYABLE, @SALEID, @PTR, @PTS, @ECP, @TAXID, @FLAG,       
	  @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @REASON_ID, @UOM, @UOMQty, @UOMPrice)      
    
    IF @DOCSERIAL > 0  
        BEGIN
	UPDATE InvoiceAbstract Set ReferenceNumber = @DOCSERIAL Where InvoiceID = @INVOICE_ID 
        END
    END      
End     
  
OVERNOUT:      
CLOSE ReleaseStocks      
DEALLOCATE ReleaseStocks      
IF @BackDatedTransaction = 1       
BEGIN      
 SET @DIFF = @REQUIRED_QUANTITY      
 exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @PURCHASEPRICE, @DAMAGES      
  
 IF @ADD_TAXSUFF_TO_OPDET=1  
 Begin  
  --Updating TaxSuff Percentage in OpeningDetails  
  Select @IS_VAT_ITEM=IsNull(Vat,0) From Items Where Product_Code=@Item_Code  
  If @LOCALITY = 2 AND @IS_VAT_ITEM = 1  
   Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate, @Item_Code, @Batch_Code, 0, 1  
  Else  
   Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate, @Item_Code, @Batch_Code     
 End  
 Set @ADD_TAXSUFF_TO_OPDET = 0  
END      
  
ALL_SAID_AND_DONE:      
IF @SCHEMEID <> 0      
BEGIN      
 Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SCHEMEID      
 Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags)       
 Values(@ITEM_CODE, @PRIMARY_QUANTITY, @ORIGINAL_QTY, @MODIFIED_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SCHEMEID, @INVOICE_ID, 0, @ORIGINAL_QTY, @SECONDARY_SCHEME)      
END      
SELECT @RETVAL      

