CREATE Procedure sp_save_Invoicedetail_CSP_MUOM_ITC
(
	@INVOICE_ID int,
	@ITEM_CODE NVARCHAR(30),
	@BATCH_NUMBER NVARCHAR(255), 
	@SALE_PRICE Decimal(18,6), 
	@REQUIRED_QUANTITY Decimal(18,6),
	@SALE_TAX Decimal(18,6),
	@DISCOUNT_PER Decimal(18,6), 
	@DISCOUNT_AMOUNT Decimal(18,6),
	@AMOUNT Decimal(18,6), 	
	@TRACK_BATCHES int,
	@BATCH_PRICE Decimal(18,6),
	@STPAYABLE Decimal(18,6),
	@CUSTOMER_TYPE int,
	@SCHEMEID int,
	@PRIMARY_QUANTITY Decimal(18,6),
	@SCHEME_COST Decimal(18,6),
	@FLAG int,
	@TAXCODE2 float,
	@CSTPAYABLE Decimal(18,6),
	@TAXSUFFERED Decimal(18,6) = 0,
	@TAXSUFFERED2 Decimal(18,6),
	@FreeRow Decimal(18,6) = 0,
	@OpeningDate datetime = Null,
	@BackDatedTransaction int = 0,
	@UOM int = 0,
	@UOMQty Decimal(18,6) = 0,
	@UOMPrice Decimal(18,6) = 0,
	@OtherCG_Item int = 0,
	@QuotationID int =0,
	@NewSchFunctionality Int = 0,
	@MultiSchID nVarchar(255)= N'',
	@TotSchAmount Decimal(18,6) = 0,
	@MultiSchemeDetail nVarchar(2000) = N'',
	@MultipleRebateID nVarchar(2000) = N'',
	@RebateRate Decimal(18,6) = 0,
	@MultipleRebateDet nVarchar(2000) = N'',
	@GroupID int = 0,
	@MRPPerPackPrice Decimal(18,6) = 0,
	@TaxOnQty int = 0,
    @GSTTaxID int = 0,
    @GSTFlag int = 0,
    @GSTCSTaxCode int = 0,
    @GSTLocality int = 0,
	@CustomerID nvarchar(15) = '',
	@GenericPTR Decimal(18,6) = 0
)
AS
Declare @TmpMRPPerPAck Decimal(18,6)
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
DECLARE @TAXID int
DECLARE @DIFF Decimal(18,6)
DECLARE @LOCALITY int
DECLARE @SECONDARY_SCHEME int
DECLARE @MRPPerPack Decimal(18,6)
Declare @HSNNumber nvarchar(50)
Declare @CategorizationID int

--Select @LOCALITY = IsNull(case InvoiceType When 2 Then 1 Else Locality End, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID *= Customer.CustomerID And InvoiceID = @INVOICE_ID
--IF Isnull(@LOCALITY,0) = 0 SET @LOCALITY = 1
--IF @LOCALITY = 1
--	--SELECT @TAXID = Tax_Code FROM Tax WHERE Percentage = Isnull(@SALE_TAX,0)
--	SELECT Top 1 @TAXID = Tax_Code FROM Tax WHERE Isnull(Percentage,0) = Isnull(@SALE_TAX,0)  
--	And tax_code in (Select Top 1 Isnull(Sale_Tax,0) from Items Where Product_Code = @ITEM_CODE)
--ELSE
--	--SELECT @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = Isnull(@TAXCODE2,0)
--	SELECT Top 1 @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = Isnull(@TAXCODE2,0)
--	And tax_code in (Select Top 1 Isnull(Sale_Tax,0) from Items Where Product_Code = @ITEM_CODE)

Set @TAXID = @GSTTaxID
Set @LOCALITY = @GSTLocality

SET @ORIGINAL_QTY = @REQUIRED_QUANTITY

/* IF SalePrice is 0 and TaxPercentage is 0 then Not required to validate the Tax */

--If isnull(@SALE_PRICE,0) > 0 And (Case When Isnull(@LOCALITY,0) = 1 Then Isnull(@SALE_TAX,0) Else Isnull(@TAXCODE2,0) End) <> 0
--Begin
----	If (Isnull(@QuotationID,0) <> 0)
----	Begin
----		
----		IF (Select Top 1 case when @LOCALITY= 1 then Isnull(Quoted_LSTTax,0) else Isnull(Quoted_CSTTax,0) end from QuotationItems Where QuotationID = Isnull(@QuotationID,0) And Product_Code= @ITEM_CODE) <> Isnull(@TAXID  ,0)
----		Begin
------			Set @TAXID = (Select Top 1 Isnull(Quoted_LSTTax,0) LST from QuotationItems Where QuotationID = Isnull(@QuotationID,0) And Product_Code= @ITEM_CODE)
----			Goto Out
----		End
----	End
--	If (Isnull(@QuotationID,0) = 0)
--	Begin
--/*		while save sales Invoice the Item Tax Suffered is not validated. Due to some WD's have diffrent taxsuffered and saleTax for items.
--		IF ((Select Top 1 Isnull(TaxSuffered,0) from Items Where Product_Code = @ITEM_CODE) <> Isnull(@TAXID  ,0))
--*/		
--		IF ((Select Top 1 Isnull(Sale_Tax,0) from Items Where Product_Code = @ITEM_CODE) <> Isnull(@TAXID  ,0)) 
--		Begin
----			Set @TAXID = ((Select Top 1 Isnull(TaxSuffered,0) from Items Where Product_Code = @ITEM_CODE) <> Isnull(@TAXID  ,0))
--			Goto Out
--		End
--	End
--End

IF @TRACK_BATCHES = 1
	BEGIN
	IF @CUSTOMER_TYPE = 1 
		If @FLAG=1 
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
			AND ISNULL(PTS, 0) = @BATCH_PRICE And ISNULL(Damage, 0) = 0 
			AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
			--and isnull(MRPPerPack,0) = @MRPPerPackPrice
		Else
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
			AND ISNULL(PTS, 0) = @BATCH_PRICE And ISNULL(Damage, 0) = 0 
			AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
			and isnull(MRPPerPack,0) = @MRPPerPackPrice
	ELSE IF @CUSTOMER_TYPE = 2 
		If @FLAG=1 
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
			AND ISNULL(PTR, 0) = @GenericPTR And ISNULL(Damage, 0) = 0 
			AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
			--and isnull(MRPPerPack,0) = @MRPPerPackPrice
		Else
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
			AND ISNULL(PTR, 0) = @GenericPTR And ISNULL(Damage, 0) = 0 
			AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
			and isnull(MRPPerPack,0) = @MRPPerPackPrice
	ELSE IF @CUSTOMER_TYPE = 3 
		If @FLAG=1 
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
			AND ISNULL(Company_Price, 0) = @BATCH_PRICE And ISNULL(Damage, 0) = 0 
			AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
			--and isnull(MRPPerPack,0) = @MRPPerPackPrice
		else
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
			AND ISNULL(Company_Price, 0) = @BATCH_PRICE And ISNULL(Damage, 0) = 0 
			AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
			and isnull(MRPPerPack,0) = @MRPPerPackPrice
	ELSE IF @CUSTOMER_TYPE = 4 
		If @FLAG=1 
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
			AND ISNULL(ECP, 0) = @BATCH_PRICE And ISNULL(Damage, 0) = 0 
			AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
			--and isnull(MRPPerPack,0) = @MRPPerPackPrice
		else
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
			AND ISNULL(ECP, 0) = @BATCH_PRICE And ISNULL(Damage, 0) = 0 
			AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
			and isnull(MRPPerPack,0) = @MRPPerPackPrice

	IF @CUSTOMER_TYPE = 1
		BEGIN
			If @FLAG=1 
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number,  Batch_Code , Quantity, PurchasePrice, PTR, PTS, ECP 
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
				and ISNULL(PTS, 0) = @BATCH_PRICE AND ISNULL(Quantity, 0) > 0 
				And ISNULL(Damage, 0) = 0 AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
				--and isnull(MRPPerPack,0) = @MRPPerPackPrice
			else
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number,  Batch_Code , Quantity, PurchasePrice, PTR, PTS, ECP 
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
				and ISNULL(PTS, 0) = @BATCH_PRICE AND ISNULL(Quantity, 0) > 0 
				And ISNULL(Damage, 0) = 0 AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
				and isnull(MRPPerPack,0) = @MRPPerPackPrice
		END
	ELSE IF @CUSTOMER_TYPE = 2
		BEGIN
			If @FLAG=1 
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number,  Batch_Code , Quantity, PurchasePrice, PTR, PTS, ECP
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
				and ISNULL(PTR, 0) = @GenericPTR AND ISNULL(Quantity, 0) > 0 
				And ISNULL(Damage, 0) = 0 AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
				--and isnull(MRPPerPack,0) = @MRPPerPackPrice			
			else
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number,  Batch_Code , Quantity, PurchasePrice, PTR, PTS, ECP
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
				and ISNULL(PTR, 0) = @GenericPTR AND ISNULL(Quantity, 0) > 0 
				And ISNULL(Damage, 0) = 0 AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
				and isnull(MRPPerPack,0) = @MRPPerPackPrice
		END
	ELSE IF @CUSTOMER_TYPE = 3
		BEGIN
			If @FLAG=1 
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number,  Batch_Code , Quantity, PurchasePrice, PTR, PTS, ECP
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
				and ISNULL(Company_Price, 0) = @BATCH_PRICE AND ISNULL(Quantity, 0) > 0 
				And ISNULL(Damage, 0) = 0 AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
				--and isnull(MRPPerPack,0) = @MRPPerPackPrice
			Else
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number,  Batch_Code , Quantity, PurchasePrice, PTR, PTS, ECP
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
				and ISNULL(Company_Price, 0) = @BATCH_PRICE AND ISNULL(Quantity, 0) > 0 
				And ISNULL(Damage, 0) = 0 AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
				and isnull(MRPPerPack,0) = @MRPPerPackPrice
		END
	ELSE IF @CUSTOMER_TYPE = 4
		BEGIN
			if @FLAG=1
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number,  Batch_Code , Quantity, PurchasePrice, PTR, PTS, ECP
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
				and ISNULL(ECP, 0) = @BATCH_PRICE AND ISNULL(Quantity, 0) > 0 
				And ISNULL(Damage, 0) = 0 AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
				and isnull(MRPPerPack,0) = @MRPPerPackPrice
			else				
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number,  Batch_Code , Quantity, PurchasePrice, PTR, PTS, ECP
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
				and ISNULL(ECP, 0) = @BATCH_PRICE AND ISNULL(Quantity, 0) > 0 
				And ISNULL(Damage, 0) = 0 AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
				and isnull(MRPPerPack,0) = @MRPPerPackPrice
		END
	END
ELSE
	BEGIN
	IF @CUSTOMER_TYPE = 1 
	BEGIN
		if @FLAG=1
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(PTS, 0) = @BATCH_PRICE 
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			--and isnull(MRPPerPack,0) = @MRPPerPackPrice
		else
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(PTS, 0) = @BATCH_PRICE 
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			and isnull(MRPPerPack,0) = @MRPPerPackPrice
	END
	ELSE IF @CUSTOMER_TYPE = 2 
	BEGIN
		if @FLAG=1
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(PTR, 0) = @GenericPTR 
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			--and isnull(MRPPerPack,0) = @MRPPerPackPrice
		ELSE
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(PTR, 0) = @GenericPTR 
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			and isnull(MRPPerPack,0) = @MRPPerPackPrice
	END
	ELSE IF @CUSTOMER_TYPE = 3 
	BEGIN
		if @FLAG=1
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(Company_Price, 0) = @BATCH_PRICE 
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			--and isnull(MRPPerPack,0) = @MRPPerPackPrice
		else
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(Company_Price, 0) = @BATCH_PRICE 
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			and isnull(MRPPerPack,0) = @MRPPerPackPrice
	END
	ELSE IF @CUSTOMER_TYPE = 4 
	BEGIN
		if @FLAG=1
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(ECP, 0) = @BATCH_PRICE 
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			--and isnull(MRPPerPack,0) = @MRPPerPackPrice
		else
			SELECT @TOTAL_QUANTITY = SUM(Quantity) FROM Batch_Products 
			WHERE Product_Code = @ITEM_CODE AND ISNULL(ECP, 0) = @BATCH_PRICE 
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			and isnull(MRPPerPack,0) = @MRPPerPackPrice
	END
	IF @CUSTOMER_TYPE = 1
		BEGIN
		if @FLAG=1
			DECLARE ReleaseStocks CURSOR KEYSET FOR
			SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP
			FROM Batch_Products
			WHERE Product_Code = @ITEM_CODE AND ISNULL(PTS, 0) = @BATCH_PRICE AND 
			ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
			And isnull(Free, 0) = @FreeRow
			--and isnull(MRPPerPack,0) = @MRPPerPackPrice
		ELSE
			DECLARE ReleaseStocks CURSOR KEYSET FOR
			SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP
			FROM Batch_Products
			WHERE Product_Code = @ITEM_CODE AND ISNULL(PTS, 0) = @BATCH_PRICE AND 
			ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
			And isnull(Free, 0) = @FreeRow
			and isnull(MRPPerPack,0) = @MRPPerPackPrice
		END
	ELSE IF @CUSTOMER_TYPE = 2
		BEGIN
			if @FLAG=1
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE AND ISNULL(PTR, 0) = @GenericPTR AND 
				ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
				And isnull(Free, 0) = @FreeRow
				--and isnull(MRPPerPack,0) = @MRPPerPackPrice		
			else
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE AND ISNULL(PTR, 0) = @GenericPTR AND 
				ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
				And isnull(Free, 0) = @FreeRow
				and isnull(MRPPerPack,0) = @MRPPerPackPrice
		END
	ELSE IF @CUSTOMER_TYPE = 3
		BEGIN
			if @FLAG=1
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE AND ISNULL(Company_Price, 0) = @BATCH_PRICE 
				AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
				And isnull(Free, 0) = @FreeRow
				--and isnull(MRPPerPack,0) = @MRPPerPackPrice
			else
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP
				FROM Batch_Products
				WHERE Product_Code = @ITEM_CODE AND ISNULL(Company_Price, 0) = @BATCH_PRICE 
				AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
				And isnull(Free, 0) = @FreeRow
				and isnull(MRPPerPack,0) = @MRPPerPackPrice
		END
	ELSE IF @CUSTOMER_TYPE = 4
		BEGIN
		if @FLAG=1
			DECLARE ReleaseStocks CURSOR KEYSET FOR
			SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP
			FROM Batch_Products
			WHERE Product_Code = @ITEM_CODE AND ISNULL(ECP, 0) = @BATCH_PRICE 
			AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
			And isnull(Free, 0) = @FreeRow
			--and isnull(MRPPerPack,0) = @MRPPerPackPrice
		else
			DECLARE ReleaseStocks CURSOR KEYSET FOR
			SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, PTR, PTS, ECP
			FROM Batch_Products
			WHERE Product_Code = @ITEM_CODE AND ISNULL(ECP, 0) = @BATCH_PRICE 
			AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
			And isnull(Free, 0) = @FreeRow
			and isnull(MRPPerPack,0) = @MRPPerPackPrice		
		END
	END

SELECT @SALEID = SaleID, @COST = Purchase_Price, @MRP = MRP, @HSNNumber = isnull(HSNNumber,''), 
	@CategorizationID = isnull(CategorizationID,0) FROM Items WHERE Product_Code = @ITEM_CODE
SET @COST = @COST
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @REQUIRED_QUANTITY

OPEN ReleaseStocks
IF ISNULL(@TOTAL_QUANTITY, 0) < @REQUIRED_QUANTITY
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
	
--	IF ISNULL(@MRPPerPack,0) = 0
--		SELECT @MRPPerPack = ISNULL(MRPPerPack,0) FROM Items WHERE Product_Code = @ITEM_CODE

	
    IF @QUANTITY >= @REQUIRED_QUANTITY
	BEGIN
        UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY
        WHERE Batch_Code = @BATCH_CODE
		--If @FLAG=1
		--Select @MRPPerPackPrice = MRPPerPack From Batch_Products Where Batch_Code = @BATCH_CODE
		If @FLAG=1
		select @TmpMRPPerPAck=MRPPerPack From Batch_Products Where Batch_Code = @BATCH_CODE

        INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number, 
	Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount, 
	PurchasePrice, STPayable, SaleID, PTR, PTS, MRP, TaxID, FlagWord, TaxCode2, 
	CSTPayable, TaxSuffered, TaxSuffered2, UOM, UOMQty, UOMPrice, OtherCG_Item,QuotationID,MultipleSchemeID,TotSchemeAmount,MultipleSchemeDetails
	,MultipleRebateID,RebateRate,MultipleRebateDet,GroupID, MRPPerPack,TAXONQTY,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID) 
	VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @REQUIRED_QUANTITY, 
	@SALE_PRICE, @SALE_TAX, @DISCOUNT_PER, @DISCOUNT_AMOUNT, @AMOUNT, 
	@COST * @REQUIRED_QUANTITY, @STPAYABLE, @SALEID, @PTR, @PTS, @MRP, @TAXID, @FLAG, 
	@TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @UOM, @UOMQty, @UOMPrice, @OtherCG_Item,@QuotationID, @MultiSchID, @TotSchAmount, @MultiSchemeDetail
--	,@MultipleRebateID,@RebateRate,@MultipleRebateDet,@GroupID, @MRPPerPack)
	,@MultipleRebateID,@RebateRate,@MultipleRebateDet,@GroupID, case @flag when 1 then @TmpMRPPerPAck else @MRPPerPackPrice end,
	@TaxOnQty,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)
	
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

	--If @FLAG=1
	--Select @MRPPerPackPrice = MRPPerPack From Batch_Products Where Batch_Code = @BATCH_CODE
	
		If @FLAG=1
		select @TmpMRPPerPAck=MRPPerPack From Batch_Products Where Batch_Code = @BATCH_CODE

        INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number, 
	Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount, 
	PurchasePrice, STPayable, SaleID, PTR, PTS, MRP, TaxID, FlagWord, TaxCode2, 
	CSTPayable, TaxSuffered, TaxSuffered2, UOM, UOMQty, UOMPrice, OtherCG_Item,QuotationID,MultipleSchemeID,TotSchemeAmount,MultipleSchemeDetails
	,MultipleRebateID,RebateRate,MultipleRebateDet,GroupID, MRPPerPack,TAXONQTY,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID) 
	VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @QUANTITY, 
	@SALE_PRICE, @SALE_TAX, @DISCOUNT_PER, @DISCOUNT_AMOUNT, @AMOUNT, @COST * @QUANTITY, 
	@STPAYABLE, @SALEID, @PTR, @PTS, @MRP, @TAXID, @FLAG, @TAXCODE2, @CSTPAYABLE, 
	@TAXSUFFERED, @TAXSUFFERED2, @UOM, @UOMQty, @UOMPrice, @OtherCG_Item,@QuotationID,@MultiSchID,@TotSchAmount,@MultiSchemeDetail
--	,@MultipleRebateID,@RebateRate,@MultipleRebateDet,@GroupID, @MRPPerPack)
	,@MultipleRebateID,@RebateRate,@MultipleRebateDet,@GroupID, case @flag when 1 then @TmpMRPPerPAck else @MRPPerPackPrice end,
	@TaxOnQty,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)
	SET @AMOUNT = 0
	SET @DISCOUNT_PER = 0
	SET @DISCOUNT_AMOUNT = 0
	SET @STPAYABLE = 0
	SET @SALE_TAX = 0
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
    FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @PTR, @PTS, @MRP
END
OVERNOUT:
CLOSE ReleaseStocks
DEALLOCATE ReleaseStocks

If @NewSchFunctionality = 1 
Begin
	if @MultiSchID <> N''
	Begin
--		Insert Into tbl_mERP_SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending)
--		Values(@ITEM_CODE, @PRIMARY_QUANTITY, @ORIGINAL_QTY, @SALE_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SCHEMEID, @INVOICE_ID, 0, @ORIGINAL_QTY) 
		Exec mERP_sp_Insert_SchemeSale @ITEM_CODE,@PRIMARY_QUANTITY,@ORIGINAL_QTY,@SALE_PRICE,@INVOICE_ID,@MultiSchemeDetail,0,0
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
SELECT @RETVAL
OUT:
Select 'InvalidTax'
