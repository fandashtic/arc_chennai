CREATE Procedure sp_save_invoice_detail_CSP_return_FMCG(@INVOICE_ID int,  
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
          @SCHEMEID int,  
          @PRIMARY_QUANTITY Decimal(18,6),  
          @SCHEME_COST Decimal(18,6),  
          @MODIFIED_PRICE Decimal(18,6),  
          @FLAG int,  
          @TAXCODE2 float,  
          @CSTPAYABLE Decimal(18,6),  
          @TAXSUFFERED Decimal(18,6) = 0,  
          @TAXSUFFERED2 Decimal(18,6) = 0,  
          @DAMAGES Decimal(18,6) = 0,  
          @DAMAGESREASON nvarchar(50),  
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
DECLARE @MRP Decimal(18,6)  
DECLARE @TAXID int  
DECLARE @SALEID int  
DECLARE @EXPIRY datetime  
DECLARE @REASON_ID int  
DECLARE @PKD_DATE datetime  
DECLARE @DIFF Decimal(18,6)  
DECLARE @LOCALITY int  
DECLARE @TAXSUFFERED_ORIG Decimal(18, 6)  
DECLARE @SECONDARY_SCHEME int 
DECLARE @IS_VAT_ITEM Int
DECLARE @ADD_TAXSUFF_TO_OPDET int
Set @ADD_TAXSUFF_TO_OPDET = 0

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

SELECT @REASON_ID = ISNULL(MessageID, 0) FROM StockAdjustmentReason   
WHERE Message = @DAMAGESREASON  

SET @ORIGINAL_QTY = @REQUIRED_QUANTITY  
SELECT @COST = Purchase_Price, @MRP = MRP, @SALEID = SaleID FROM Items   
WHERE Product_code = @ITEM_CODE  

SET @COST = @COST  
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @REQUIRED_QUANTITY  
IF @TRACK_INVENTORY = 0  
BEGIN  
	SET @RETVAL = 1  
	INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number,   
	Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount,   
	PurchasePrice, STPayable, MRP, TaxID, FlagWord, SaleID, TaxCode2, CSTPayable,   
	TaxSuffered, TaxSuffered2, ReasonID)  
	VALUES (@INVOICE_ID, @ITEM_CODE, 0, N'', @REQUIRED_QUANTITY, @MODIFIED_PRICE,   
	@TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT, @COST * @REQUIRED_QUANTITY,   
	@STPAYABLE, @MRP, @TAXID, @FLAG, @SALEID, @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED,   
	@TAXSUFFERED2, @REASON_ID)  
	GOTO ALL_SAID_AND_DONE  
END  
IF @TRACK_BATCHES = 1  
	BEGIN  
	DECLARE ReleaseStocks CURSOR KEYSET FOR  
	SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, Expiry, PKD, TaxSuffered  
	FROM Batch_Products  
	WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
	and ISNULL(SalePrice, 0) = @SALE_PRICE   
	AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow  
	And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)  
	END  
ELSE  
	BEGIN  
	DECLARE ReleaseStocks CURSOR KEYSET FOR  
	SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, Expiry, PKD, TaxSuffered  
	FROM Batch_Products  
	WHERE Product_Code = @ITEM_CODE AND ISNULL(SalePrice, 0) = @SALE_PRICE   
	And isnull(Free, 0) = @FreeRow  
	And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)  
	END  
  
OPEN ReleaseStocks  
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @EXPIRY, @PKD_DATE, @TAXSUFFERED_ORIG  
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
		If Exists (Select * from Batch_Products Where Batch_Code = @Batch_Code And IsNull(DocType,0) = 3 And IsNull(DocID,0) = 0 AND IsNull(QuantityReceived,0)=0)
		Begin 
			Set @ADD_TAXSUFF_TO_OPDET=1
			Update Batch_Products Set Quantity = Quantity + @REQUIRED_QUANTITY, 
			QuantityReceived = @REQUIRED_QUANTITY, DocId=@INVOICE_ID
			WHERE Batch_Code = @BATCH_CODE  
		End 
		Else
		Begin
			UPDATE Batch_Products SET Quantity = Quantity + @REQUIRED_QUANTITY   
			WHERE Batch_Code = @BATCH_CODE  
		End

		INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number,   
		Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount,   
		PurchasePrice, STPayable, MRP, TaxID, FlagWord, SaleID, TaxCode2, CSTPayable,   
		TaxSuffered, TaxSuffered2, ReasonID)  
		VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @REQUIRED_QUANTITY,   
		@MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT,   
		@REQUIRED_QUANTITY * @COST, @STPAYABLE, @MRP, @TAXID, @FLAG, @SALEID, @TAXCODE2,   
		@CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @REASON_ID)  
		END  
	ELSE  
		BEGIN  
		IF @COST = 0  
		BEGIN  
			Select @COST = PurchasePrice From Batch_Products Where Product_Code = @ITEM_CODE And PurchasePrice > 0  
			Set @COST = IsNull(@COST, 0)  
		END  
		INSERT INTO Batch_Products(Product_Code, Batch_Number, Expiry, Quantity,   
		PurchasePrice, SalePrice, Damage, DamagesReason, PKD, TaxSuffered, DocType, DocID)   
		VALUES(@ITEM_CODE, @BATCH_NUMBER, @EXPIRY, @REQUIRED_QUANTITY, @COST,   
		@MODIFIED_PRICE, 2, @REASON_ID, @PKD_DATE, @TAXSUFFERED_ORIG,1,@INVOICE_ID)  
		
		INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number,   
		Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount,   
		PurchasePrice, STPayable, MRP, TaxID, FlagWord, SaleID, TaxCode2, CSTPayable,   
		TaxSuffered, TaxSuffered2, ReasonID)  
		VALUES (@INVOICE_ID, @ITEM_CODE, @@IDENTITY, @BATCH_NUMBER, @REQUIRED_QUANTITY,   
		@MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT,   
		@REQUIRED_QUANTITY * @COST, @STPAYABLE, @MRP, @TAXID, @FLAG, @SALEID, @TAXCODE2,   
		@CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @REASON_ID)  
		END  
	END  

OVERNOUT:  
CLOSE ReleaseStocks  
DEALLOCATE ReleaseStocks  
IF @BackDatedTransaction = 1   
BEGIN  
	SET @DIFF = @REQUIRED_QUANTITY  
	exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @COST, @DAMAGES  
	
	IF @ADD_TAXSUFF_TO_OPDET=1
	Begin
		--Updating TaxSuff Percentage in OpeningDetails
		Select @IS_VAT_ITEM=IsNull(Vat,0) From Items Where Product_Code=@Item_Code
		If @LOCALITY = 2 AND @IS_VAT_ITEM = 1
			Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @OpeningDate, @Item_Code, @Batch_Code, 0, 1
		Else
			Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @OpeningDate, @Item_Code, @Batch_Code
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


