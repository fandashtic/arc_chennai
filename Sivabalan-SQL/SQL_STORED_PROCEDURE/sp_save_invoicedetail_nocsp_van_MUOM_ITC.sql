CREATE Procedure sp_save_invoicedetail_nocsp_van_MUOM_ITC (@INVOICE_ID int,
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
	 			      @SCHEMEID int,
			     	  @PRIMARY_QUANTITY Decimal(18,6),
				      @SCHEME_COST Decimal(18,6),
				      @FLAG int,
				      @TAXCODE2 Decimal(18,6),
				      @CSTPAYABLE Decimal(18,6),
				      @TAXSUFFERED Decimal(18,6) = 0,
				      @TAXSUFFERED2 Decimal(18,6) = 0,
				      @VANSTMTID int = 0,
				      @UNUSED2 nvarchar(50) = N'',
				      @FreeRow Decimal(18,6) = 0,
				      @OpeningDate datetime = Null,
				      @BackDatedTransaction int = 0,
 				      @UOM int,
			          @UOMQty Decimal(18, 6), 
			  	      @UOMPrice Decimal(18, 6),
					  @OtherCG_Item int  = 0,
					  @QuotationID int = 0 ,
 					  @NewSchFunctionality Int = 0,
					  @MultiSchID nVarchar(255)= N'',
					  @TotSchAmount as Decimal(18,6) = 0,
					  @MultiSchIDAndCost as nVarchar(2550) = N'',
					  @MultipleRebateID nVarchar(2000) = N'',
					  @RebateRate Decimal(18,6) = 0,
					  @MultipleRebateDet nVarchar(2550) = N'',
					  @GroupID int = 0,
					  @MRPPERPACK Decimal(18,6) = 0,
					  @TAXONQTY int = 0,
					  @GSTTaxID int = 0,
					  @GSTFlag int = 0,
					  @GSTCSTaxCode int = 0,
					  @GSTLocality int = 0,
					  @CustomerID nvarchar(15) = '',
					  @GenericPTR Decimal(18,6) = 0)   
AS
DECLARE @BATCH_CODE int 
DECLARE @QUANTITY Decimal(18,6)
DECLARE @RETVAL Decimal(18,6)
DECLARE @TOTAL_QUANTITY Decimal(18,6)
DECLARE @COST Decimal(18,6)
DECLARE @SALEID int
DECLARE @ORIGINAL_QTY Decimal(18,6)
DECLARE @MRP Decimal(18,6)
DECLARE @TAXID int
DECLARE @ROWID int
DECLARE @PTS Decimal(18,6)
DECLARE @PTR Decimal(18,6)
DECLARE @DIFF Decimal(18,6)
DECLARE @LOCALITY int
DECLARE @SECONDARY_SCHEME int
DECLARE @TEMPID int
DECLARE @BATCHMRPPERPACK Decimal(18,6)
DECLARE @ITEMMRPPERPACK Decimal(18,6)
Declare @HSNNumber nvarchar(50)
Declare @CategorizationID int

/* In some Invoices Batch_Code ,PTS,PTR,ECP saved as 0 even for Track Inventory True Item,  this is possible 
only when @TRACK_INVENTORY is passed as zero for  Track Inventory True Item ,This has been handled */
If (Select isNull(IC.Track_Inventory,0) From Items I,ItemCategories IC 
    Where I.Product_Code = @ITEM_CODE And I.CategoryID = IC.CategoryID) <> isNull(@TRACK_INVENTORY,0)
Begin
	Set @RETVAL = 0
	GOTO ALL_SAID_AND_DONE
End

--Select @LOCALITY = IsNull(Locality, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceID = @INVOICE_ID
--IF @LOCALITY = 0 SET @LOCALITY = 1
--IF @LOCALITY = 1
--	SELECT @TAXID = Tax_Code FROM Tax WHERE Percentage = @TAXCODE
--ELSE
--	SELECT @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = @TAXCODE2

Set @TAXID = @GSTTaxID
Set @LOCALITY = @GSTLocality

SET @ORIGINAL_QTY = @REQUIRED_QUANTITY
SELECT @COST = Purchase_Price, @SALEID = SaleID, @MRP = MRP, @PTS = PTS, @PTR = PTR,@ITEMMRPPERPACK = ISNULL(MRPPerPack,0), @HSNNumber = isnull(HSNNumber,'') , @CategorizationID = isnull(CategorizationID,0)
FROM Items WHERE Product_code = @ITEM_CODE
SET @COST = @COST
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @REQUIRED_QUANTITY
IF @TRACK_INVENTORY = 0
BEGIN
	SET @RETVAL = 1
	SELECT @TEMPID = [ID] FROM VanStatementDetail,Batch_Products
	WHERE DocSerial = @VANSTMTID AND VanStatementDetail.Product_Code = @ITEM_CODE AND 
	ISNULL(VanStatementDetail.Batch_Number, N'') = @BATCH_NUMBER And ISNULL(Batch_Products.Free,0) = @FreeRow

     INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number, 
	Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount, 
	PurchasePrice, STPayable, MRP, SaleID, TaxID, FlagWord, TaxCode2, CSTPayable, 
	TaxSuffered, TaxSuffered2, PTS, PTR, UOM ,UOMQTY, UOMPRICE, OtherCG_Item,QuotationID, MultipleSchemeID,
	TotSchemeAmount,MultipleSchemeDetails,MultipleRebateID,RebateRate,MultipleRebateDet,GroupID,MRPPerPack,
	TAXONQTY,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)
	VALUES (@INVOICE_ID, @ITEM_CODE, @TEMPID, @BATCH_NUMBER, @REQUIRED_QUANTITY, @SALE_PRICE, @TAXCODE, 
	@DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT, @COST * @REQUIRED_QUANTITY, 
	@STPAYABLE, @MRP, @SALEID, @TAXID, @FLAG, @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, 
	@TAXSUFFERED2, @PTS, @PTR , @UOM , @UOMQTY, @UOMPRICE, @OtherCG_Item,@QuotationID,
	@MultiSchID, @TotSchAmount,@MultiSchIDAndCost,@MultipleRebateID,@RebateRate,@MultipleRebateDet,@GroupID,@ITEMMRPPERPACK,
	@TAXONQTY,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)
	GOTO ALL_SAID_AND_DONE
END
IF @TRACK_BATCHES = 1
	BEGIN
	SELECT @TOTAL_QUANTITY = ISNULL(SUM(Pending), 0) FROM VanStatementDetail, Batch_Products
	WHERE VanStatementDetail.Batch_Code = Batch_Products.Batch_Code And
	DocSerial = @VANSTMTID AND VanStatementDetail.Product_Code = @ITEM_CODE AND 
	ISNULL(VanStatementDetail.Batch_Number, N'') = @BATCH_NUMBER And ISNULL(Batch_Products.Free,0) = @FreeRow

	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT VanStatementDetail.Batch_Number, VanStatementDetail.Batch_Code, Pending, 
	VanStatementDetail.PurchasePrice, [ID], VanStatementDetail.PTS, VanStatementDetail.PTR, VanStatementDetail.ECP,Batch_Products.MRPPERPACK
	FROM VanStatementDetail, Batch_Products
	WHERE VanStatementDetail.Batch_Code = Batch_Products.Batch_Code And
	DocSerial = @VANSTMTID AND VanStatementDetail.Product_Code = @ITEM_CODE and 
	ISNULL(VanStatementDetail.Batch_Number, N'') = @BATCH_NUMBER AND ISNULL(Pending, 0) > 0
	And ISNULL(Batch_Products.Free,0) = @FreeRow
	END
ELSE
	BEGIN
	SELECT @TOTAL_QUANTITY = ISNULL(SUM(Pending), 0) FROM VanStatementDetail, Batch_Products
	WHERE VanStatementDetail.Batch_Code = Batch_Products.Batch_Code And
	DocSerial = @VANSTMTID AND VanStatementDetail.Product_Code = @ITEM_CODE
	And ISNULL(Batch_Products.Free,0) = @FreeRow

	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT VanStatementDetail.Batch_Number, VanStatementDetail.Batch_Code, Pending, 
	VanStatementDetail.PurchasePrice, [ID], VanStatementDetail.PTS, VanStatementDetail.PTR, VanStatementDetail.ECP,Batch_Products.MRPPerPack
	FROM VanStatementDetail, Batch_Products
	WHERE VanStatementDetail.Batch_Code = Batch_Products.Batch_Code And
	DocSerial = @VANSTMTID AND VanStatementDetail.Product_Code = @ITEM_CODE AND 
	ISNULL(Pending, 0) > 0 And ISNULL(Batch_Products.Free,0) = @FreeRow
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
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @ROWID, 
@PTS, @PTR, @MRP,@BATCHMRPPERPACK

WHILE @@FETCH_STATUS = 0
BEGIN
	--SELECT @MRPPERPACK = ISNULL(MRPPerPack,0) FROM Batch_Products WHERE  Batch_Code = @BATCH_CODE
--	IF ISNULL(@BATCHMRPPERPACK,0) = 0
--		SELECT @BATCHMRPPERPACK = ISNULL(MRPPerPack,0) FROM Items WHERE Product_code = @ITEM_CODE

    IF @QUANTITY >= @REQUIRED_QUANTITY
	BEGIN
			UPDATE VanStatementDetail SET Pending = Pending - @REQUIRED_QUANTITY
			WHERE [ID] = @ROWID

		IF @@ROWCOUNT = 0
		BEGIN
			SET @RETVAL = 0
			GOTO OVERNOUT
		END

		INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number, 
		Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount, 
		PurchasePrice, STPayable, SaleID, MRP, TaxID, FlagWord, TaxCode2, CSTPayable, 
		TaxSuffered, TaxSuffered2, PTS, PTR, UOM ,UOMQTY, UOMPRICE, OtherCG_Item,QuotationID,MultipleSchemeID, 
		TotSchemeAmount,MultipleSchemeDetails,MultipleRebateID,RebateRate,MultipleRebateDet,GroupID,
		MRPPerPack,TAXONQTY,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)
		VALUES (@INVOICE_ID, @ITEM_CODE, @ROWID, @BATCH_NUMBER, @REQUIRED_QUANTITY, 
		@SALE_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT, 
		@COST * @REQUIRED_QUANTITY, @STPAYABLE, @SALEID, @MRP, @TAXID, @FLAG, @TAXCODE2, 
		@CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @PTS, @PTR, @UOM , @UOMQTY, @UOMPRICE, @OtherCG_Item,
		@QuotationID, @MultiSchID, @TotSchAmount,@MultiSchIDAndCost,@MultipleRebateID,@RebateRate,@MultipleRebateDet,@GroupID,
		@BATCHMRPPERPACK,@TAXONQTY,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)
		IF @BackDatedTransaction = 1 
		BEGIN
			SET @DIFF = 0 - @REQUIRED_QUANTITY
			exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @COST, 0, 0, @BATCH_CODE
		END
			GOTO OVERNOUT
	END
    ELSE
	BEGIN
	set @REQUIRED_QUANTITY = @REQUIRED_QUANTITY - @QUANTITY
	UPDATE VanStatementDetail SET Pending = 0 where [ID] = @ROWID
	IF @@ROWCOUNT = 0
	BEGIN
		SET @RETVAL = 0
		GOTO OVERNOUT
	END

   	INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number, 
	Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount, 
	PurchasePrice, STPayable, SaleID, MRP, TaxID, FlagWord, TaxCode2, CSTPayable, 
	TaxSuffered, TaxSuffered2, PTS, PTR , UOM ,UOMQTY, UOMPRICE, OtherCG_Item,QuotationID,
	MultipleSchemeID, TotSchemeAmount,MultipleSchemeDetails,MultipleRebateID,RebateRate,MultipleRebateDet,GroupID,MRPPerPack,
	TAXONQTY,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)
	VALUES (@INVOICE_ID, @ITEM_CODE, @ROWID, @BATCH_NUMBER, @QUANTITY, @SALE_PRICE, 
	@TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT, @COST * @QUANTITY, 
	@STPAYABLE, @SALEID, @MRP, @TAXID, @FLAG, @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, 
	@TAXSUFFERED2, @PTS, @PTR, @UOM , @UOMQTY, @UOMPRICE, @OtherCG_Item,@QuotationID, @MultiSchID,
	@TotSchAmount,@MultiSchIDAndCost,@MultipleRebateID,@RebateRate,@MultipleRebateDet,@GroupID,@BATCHMRPPERPACK,
	@TAXONQTY,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)
	SET @AMOUNT = 0
	SET @TAXCODE = 0
	SET @DISCOUNTPERCENTAGE = 0
	SET @DISCOUNTAMOUNT = 0
	SET @STPAYABLE = 0
	SET @CSTPAYABLE = 0
	SET @TAXCODE2 = 0
	SET @TAXSUFFERED = 0
	SET @TAXSUFFERED2 = 0
	SET @UOMQTY = 0
	IF @BackDatedTransaction = 1 
	BEGIN
		SET @DIFF = 0 - @QUANTITY
		Exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @COST, 0, 0, @BATCH_CODE
	END
	END 
        FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, 
	@ROWID, @PTS, @PTR, @MRP,@BATCHMRPPERPACK
END
OVERNOUT:
CLOSE ReleaseStocks
DEALLOCATE ReleaseStocks
ALL_SAID_AND_DONE:

If @RETVAL = 1
Begin
	 If @NewSchFunctionality = 1 
	 Begin
		if @MultiSchID <> N''
		Begin
			--Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending)
			--Values(@ITEM_CODE, @PRIMARY_QUANTITY, @ORIGINAL_QTY, @SALE_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SCHEMEID, @INVOICE_ID, 0, @ORIGINAL_QTY)
			Exec mERP_sp_Insert_SchemeSale @ITEM_CODE,@PRIMARY_QUANTITY,@ORIGINAL_QTY, @SALE_PRICE,@INVOICE_ID,@MultiSchIDAndCost,0,0
		End
	 End	
	 Else
	 Begin	
		IF @SCHEMEID <> 0
		BEGIN
			Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SCHEMEID
			Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags)
			Values(@ITEM_CODE, @PRIMARY_QUANTITY, @ORIGINAL_QTY, @SALE_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SCHEMEID, @INVOICE_ID, 0, @ORIGINAL_QTY, @SECONDARY_SCHEME)
		END
	 End
End

SELECT @RETVAL
