Create Procedure sp_save_invoice_detail_CSP_MUOM_ITC(@INVOICE_ID int,  
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
	@BackDatedTransaction int = 0,  
	@UOM int = 0,  
	@UOMQty Decimal(18,6) = 0,  
	@UOMPrice Decimal(18,6) = 0,
	@OtherCG_Item int = 0,
	@QuotationID int = 0,
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
	@GenericPTR Decimal(18,6) = 0
)   
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
DECLARE @BATCHMRPPERPACK Decimal(18,6)
Declare @HSNNumber nvarchar(50)
Declare @CategorizationID int

/* In some Invoices Batch_Code ,PTS,PTR,ECP saved as 0 even for Track Inventory True Item,  this is possible 
   only when @TRACK_INVENTORY is passed as zero for  Track Inventory True Item ,This has been handled */
If (Select isNull(IC.Track_Inventory,0) From Items I,ItemCategories IC 
    Where I.Product_Code = @ITEM_CODE And I.CategoryID = IC.CategoryID) <> @TRACK_INVENTORY
Begin
	Set @RETVAL = 0
	GOTO ALL_SAID_AND_DONE
End

--Select @LOCALITY = IsNull(Customer.Locality, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceID = @INVOICE_ID  
--IF Isnull(@LOCALITY,0) = 0 SET @LOCALITY = 1  
--IF @LOCALITY = 1  
--	SELECT Top 1 @TAXID = Tax_Code FROM Tax WHERE Isnull(Percentage,0) = Isnull(@TAXCODE,0)  
--	And tax_code in (Select Top 1 Isnull(Sale_Tax,0) from Items Where Product_Code = @ITEM_CODE)
--ELSE  
--	SELECT Top 1 @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = Isnull(@TAXCODE2,0)
--	And tax_code in (Select Top 1 Isnull(Sale_Tax,0) from Items Where Product_Code = @ITEM_CODE)

Set @TAXID = @GSTTaxID
Set @LOCALITY = @GSTLocality

--			/* IF SalePrice is 0 and TaxPercentage is 0 then Not required to validate the Tax */
--
--			If isnull(@SALE_PRICE,0) > 0 And (Case When Isnull(@LOCALITY,0) = 1 Then Isnull(@TAXCODE,0) Else Isnull(@TAXCODE2,0) End) <> 0
--			Begin
--				/* Below logic is wrong and we are commenting it as Quoted_LSTTax column always stores value as 0 in QuotationItems Table and Category wise quotation is not at all considered below*/
--			--	If (Isnull(@QuotationID,0) <> 0)
--			--	Begin
--			--		
--			--		IF (Select Top 1 case when @LOCALITY= 1 then Isnull(Quoted_LSTTax,0) else Isnull(Quoted_CSTTax,0) end from QuotationItems Where QuotationID = Isnull(@QuotationID,0) And Product_Code= @ITEM_CODE) <> Isnull(@TAXID  ,0)
--			--		Begin
--			----			Set @TAXID = (Select Top 1 Isnull(Quoted_LSTTax,0) LST from QuotationItems Where QuotationID = Isnull(@QuotationID,0) And Product_Code= @ITEM_CODE)
--			--			
--			--			Goto Out
--			--		End
--			--	End
--			--	Else
--				If (Isnull(@QuotationID,0) = 0)
--				Begin
--			/*		while save sales Invoice the Item Tax Suffered is not validated. Due to some WD's have diffrent taxsuffered and saleTax for items.
--					IF ((Select Top 1 Isnull(TaxSuffered,0) from Items Where Product_Code = @ITEM_CODE) <> Isnull(@TAXID  ,0))
--			*/		
--
--
--					IF ((Select Top 1 Isnull(Sale_Tax,0) from Items Where Product_Code = @ITEM_CODE) <> Isnull(@TAXID  ,0)) 
--					Begin
--			--			Set @TAXID = ((Select Top 1 Isnull(TaxSuffered,0) from Items Where Product_Code = @ITEM_CODE) <> Isnull(@TAXID  ,0))
--						
--						Goto Out
--					End
--				End
--			End
  
SET @ORIGINAL_QTY = @REQUIRED_QUANTITY  
SELECT @COST = Purchase_Price, @MRP = MRP, @SALEID = SaleID, @HSNNumber = isnull(HSNNumber,''), @CategorizationID = isnull(CategorizationID,0)
	FROM Items WHERE Product_code = @ITEM_CODE  
SET @COST = @COST  
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @REQUIRED_QUANTITY 
IF @TRACK_INVENTORY = 0  
BEGIN  
	SET @RETVAL = 1  
	
	IF IsNull(@MRPPERPACK,0) = 0
		Select  @MRPPERPACK = IsNull(MRPPerPack,0) From Items Where Product_Code = @ITEM_CODE
	INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number, Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount, PurchasePrice, STPayable, TaxID,   
	FlagWord, SaleID, TaxCode2, CSTPayable, TaxSuffered, TaxSuffered2, UOM, UOMQty, UOMPrice, OtherCG_Item,QuotationID,MultipleSchemeID,TotSchemeAmount,MultipleSchemeDetails
	,MultipleRebateID,RebateRate,MultipleRebateDet,GroupID,MRPPerPack,TAXONQTY,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)    
	VALUES (@INVOICE_ID, @ITEM_CODE, 0, N'', @REQUIRED_QUANTITY, @MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT, @COST * @REQUIRED_QUANTITY, @STPAYABLE, @TAXID,   
	@FLAG, @SALEID, @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @UOM, @UOMQty, @UOMPrice, @OtherCG_Item,@QuotationID,@MultiSchID,@TotSchAmount,@MultiSchIDAndCost
	,@MultipleRebateID,@RebateRate,@MultipleRebateDet,@GroupID,@MRPPERPACK,@TAXONQTY,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)
  
	GOTO ALL_SAID_AND_DONE  
END  
IF @TRACK_BATCHES = 1  
	BEGIN  
	IF @CUSTOMER_TYPE = 1  
		SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
		WHERE Product_Code = @ITEM_CODE AND   
		ISNULL(Batch_Number, N'') = @BATCH_NUMBER AND   
		ISNULL(PTS, 0) = @SALE_PRICE AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK AND (Expiry >= GetDate() OR Expiry IS NULL)   
		And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
	ELSE IF @CUSTOMER_TYPE = 2  
		SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
		WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER  
		AND ISNULL(PTR, 0) = @GenericPTR AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK AND (Expiry >= GetDate() OR Expiry IS NULL)   
		And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
	ELSE IF @CUSTOMER_TYPE = 3  
		SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
		WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
		AND ISNULL(Company_Price, 0) = @SALE_PRICE AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK AND   
		(Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0   
		And isnull(Free, 0) = @FreeRow  
	ELSE IF @CUSTOMER_TYPE = 4   
		SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products     
		WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER       
		AND ISNULL(SalePrice, 0) = @SALE_PRICE AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK AND     
		(Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0     
		And isnull(Free, 0) = @FreeRow      
  
  
	IF @CUSTOMER_TYPE = 1  
	BEGIN  
		DECLARE ReleaseStocks CURSOR KEYSET FOR  
		SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP,MRPPERPACK  
		FROM Batch_Products  
		WHERE Product_Code = @ITEM_CODE   
		and ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
		and ISNULL(PTS, 0) = @SALE_PRICE AND ISNULL(Quantity, 0) > 0 AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK  
		AND (Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0  
		And isnull(Free, 0) = @FreeRow  
	END  
	ELSE IF @CUSTOMER_TYPE = 2  
	BEGIN  
		DECLARE ReleaseStocks CURSOR KEYSET FOR  
		SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP,MRPPERPACK  
		FROM Batch_Products  
		WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
		and ISNULL(PTR, 0) = @GenericPTR AND ISNULL(Quantity, 0) > 0 AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK  
		AND (Expiry >= GetDate() OR Expiry IS NULL)   
		And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
	END  
	ELSE IF @CUSTOMER_TYPE = 3  
	BEGIN  
		DECLARE ReleaseStocks CURSOR KEYSET FOR  
		SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP,MRPPERPACK  
		FROM Batch_Products  
		WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
		and ISNULL(Company_Price, 0) = @SALE_PRICE AND ISNULL(Quantity, 0) > 0 AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK  
		AND (Expiry >= GetDate() OR Expiry IS NULL)   
		And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
	END  
	ELSE IF @CUSTOMER_TYPE = 4    
	BEGIN    
		DECLARE ReleaseStocks CURSOR KEYSET FOR      
		SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP,MRPPERPACK     
		FROM Batch_Products      
		WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER     
		and ISNULL(SalePrice, 0) = @SALE_PRICE AND ISNULL(Quantity, 0) > 0 AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK    
		AND (Expiry >= GetDate() OR Expiry IS NULL)     
		And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow      
	END    
	END  
ELSE  
 BEGIN  
 IF @CUSTOMER_TYPE = 1  
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
  WHERE Product_Code = @ITEM_CODE AND ISNULL(PTS, 0) = @SALE_PRICE AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK  
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
 ELSE IF @CUSTOMER_TYPE = 2  
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
  WHERE Product_Code = @ITEM_CODE AND ISNULL(PTR, 0) = @GenericPTR  AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK 
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
 ELSE IF @CUSTOMER_TYPE = 3  
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
  WHERE Product_Code = @ITEM_CODE AND ISNULL(Company_Price, 0) = @SALE_PRICE  AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK 
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
 ELSE IF @CUSTOMER_TYPE = 4    
  SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products     
  WHERE Product_Code = @ITEM_CODE AND ISNULL(SalePrice, 0) = @SALE_PRICE  AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow    
  
  
 IF @CUSTOMER_TYPE = 1  
  BEGIN  
  DECLARE ReleaseStocks CURSOR KEYSET FOR  
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP, MRPPERPACK  
  FROM Batch_Products  
  WHERE Product_Code = @ITEM_CODE AND ISNULL(PTS, 0) = @SALE_PRICE AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK  
  AND ISNULL(Quantity, 0) > 0   
  And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
  END  
 ELSE IF @CUSTOMER_TYPE = 2  
  BEGIN  
  DECLARE ReleaseStocks CURSOR KEYSET FOR  
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP, MRPPERPACK  
  FROM Batch_Products  
  WHERE Product_Code = @ITEM_CODE AND ISNULL(PTR, 0) = @GenericPTR AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK  
  AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0   
  And isnull(Free, 0) = @FreeRow  
  END  
 ELSE IF @CUSTOMER_TYPE = 3  
  BEGIN  
  DECLARE ReleaseStocks CURSOR KEYSET FOR  
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP, MRPPERPACK  
  FROM Batch_Products  
  WHERE Product_Code = @ITEM_CODE AND ISNULL(Company_Price, 0) = @SALE_PRICE AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK  
  AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0   
  And isnull(Free, 0) = @FreeRow  
  END  
 ELSE IF @CUSTOMER_TYPE = 4    
  BEGIN    
  DECLARE ReleaseStocks CURSOR KEYSET FOR      
  SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP, MRPPERPACK     
  FROM Batch_Products      
  WHERE Product_Code = @ITEM_CODE AND ISNULL(SalePrice, 0) = @SALE_PRICE AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK    
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
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @PTR, @PTS, @MRP,@BATCHMRPPERPACK  
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
--	IF @BATCHMRPPERPACK = 0
--		Select  @BATCHMRPPERPACK = IsNull(MRPPerPack,0) From Items Where Product_Code = @ITEM_CODE
--    --SELECT @MRPPERPACK = ISNULL(MRPPerPack,0) FROM Batch_Products WHERE  Batch_Code = @BATCH_CODE  
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
 TaxCode2, CSTPayable, TaxSuffered, TaxSuffered2, UOM, UOMQty, UOMPrice, OtherCG_Item,
 QuotationID,MultipleSchemeID,TotSchemeAmount,MultipleSchemeDetails,MultipleRebateID,RebateRate,MultipleRebateDet,GroupID,MRPPerPack,
 TAXONQTY,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)
 VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @REQUIRED_QUANTITY,   
 @MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT,   
 @REQUIRED_QUANTITY * @COST, @STPAYABLE, @PTR, @PTS, @MRP, @TAXID, @FLAG,   
 @SALEID, @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @UOM, @UOMQty, @UOMPrice, @OtherCG_Item,
 @QuotationID,@MultiSchID,@TotSchAmount,@MultiSchIDAndCost,@MultipleRebateID,@RebateRate,@MultipleRebateDet,@GroupID,@BATCHMRPPERPACK,
 @TAXONQTY,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)
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
 UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE  
 IF @@ROWCOUNT = 0  
 BEGIN  
  SET @RETVAL = 1  
  GOTO OVERNOUT  
 END  

 INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number,   
 Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount,   
 PurchasePrice, STPayable, PTR, PTS, MRP, TaxID, FlagWord, SaleID, TaxCode2,   
 CSTPayable, TaxSuffered, TaxSuffered2, UOM, UOMQty, UOMPrice, OtherCG_Item,
 QuotationID,MultipleSchemeID,TotSchemeAmount,MultipleSchemeDetails,MultipleRebateID,RebateRate,MultipleRebateDet,GroupID,MRPPerPack,
 TAXONQTY,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)
 VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @QUANTITY,   
 @MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT, @AMOUNT,   
 @COST * @QUANTITY, @STPAYABLE, @PTR, @PTS, @MRP, @TAXID, @FLAG, @SALEID,   
 @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @UOM, @UOMQty, @UOMPrice, @OtherCG_Item,@QuotationID,
 @MultiSchID,@TotSchAmount,@MultiSchIDAndCost,@MultipleRebateID,@RebateRate,@MultipleRebateDet,@GroupID,@BATCHMRPPERPACK,
 @TAXONQTY,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)
 SET @TAXCODE = 0  
 SET @DISCOUNTPERCENTAGE = 0  
 SET @DISCOUNTAMOUNT = 0  
 SET @AMOUNT = 0  
 SET @STPAYABLE = 0  
 SET @CSTPAYABLE = 0  
 SET @TAXCODE2 = 0  
 SET @TAXSUFFERED = 0  
 SET @TAXSUFFERED2 = 0  
 SET @UOMQty = 0  
 IF @BackDatedTransaction = 1   
 BEGIN  
 SET @DIFF = 0 - @QUANTITY  
 exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @COST, 0, 0, @BATCH_CODE
 END  
 END   
    FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @PTR, @PTS, @MRP, @BATCHMRPPERPACK  
END  
OVERNOUT:  
CLOSE ReleaseStocks  
DEALLOCATE ReleaseStocks  
ALL_SAID_AND_DONE:  

 If @RETVAL = 1
 Begin
	 If @NewSchFunctionality = 1 
	 Begin
		if isNull(@MultiSchID,N'') <> N'' And isNull(@MultiSchID,N'') <> '0' 
		Begin
			Exec mERP_sp_Insert_SchemeSale @ITEM_CODE,@PRIMARY_QUANTITY,@ORIGINAL_QTY,@MODIFIED_PRICE,@INVOICE_ID,@MultiSchIDAndCost,0,0
	--		Insert Into tbl_mERP_SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending,MultipleSchemeID)   
	--		Values(@ITEM_CODE, @PRIMARY_QUANTITY, @ORIGINAL_QTY, @MODIFIED_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SCHEMEID, @INVOICE_ID, 0, @ORIGINAL_QTY,@MultiSchID)  

		End
	 End	
	 Else
	 Begin	
		IF @SCHEMEID <> 0  
		BEGIN  
			Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SCHEMEID  
			Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags)   
			Values(@ITEM_CODE, @PRIMARY_QUANTITY, @ORIGINAL_QTY, @MODIFIED_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SCHEMEID, @INVOICE_ID, 0, @ORIGINAL_QTY, @SECONDARY_SCHEME)  
	 
		END  
	 End
  End

SELECT @RETVAL  
OUT:
Select 'InvalidTax'
