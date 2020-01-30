CREATE procedure [dbo].[SP_Save_RetailInvoiceDetail_CSP](@INVOICE_ID int,
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
				      @TAXSUFFERED float = 0,
				      @TAXSUFFERED2 float,
				      @FreeRow Decimal(18,6) = 0,
				      @OpeningDate datetime = Null,
				      @BackDatedTransaction int = 0)
AS
DECLARE @BATCH_CODE int 
DECLARE @COST Decimal(18,6)
DECLARE @SALEID int
DECLARE @PTR Decimal(18,6)
DECLARE @PTS Decimal(18,6)
DECLARE @MRP Decimal(18,6)
DECLARE @TAXID int
DECLARE @DIFF Decimal(18,6)
DECLARE @LOCALITY int
DECLARE @SECONDARY_SCHEME int

Select @LOCALITY = IsNull(case InvoiceType When 2 Then 1 Else Locality End, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID *= Customer.CustomerID And InvoiceID = @INVOICE_ID
IF @LOCALITY = 0 SET @LOCALITY = 1
IF @LOCALITY = 1
	SELECT @TAXID = Tax_Code FROM Tax WHERE Percentage = @SALE_TAX
ELSE
	SELECT @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = @TAXCODE2

SELECT @SALEID = SaleID, @COST = Purchase_Price, @MRP = MRP FROM Items WHERE Product_Code = @ITEM_CODE
SET @COST = @COST
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @REQUIRED_QUANTITY
IF @TRACK_BATCHES = 1
Begin
	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number,  Batch_Code , PurchasePrice, PTR, PTS, ECP
	FROM Batch_Products
	WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
	and ISNULL(ECP, 0) = @BATCH_PRICE 
	AND (Expiry >= GetDate() OR Expiry IS NULL)
	And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
End
Else
Begin
	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number, Batch_Code, PurchasePrice, PTR, PTS, ECP
	FROM Batch_Products
	WHERE Product_Code = @ITEM_CODE AND ISNULL(ECP, 0) = @BATCH_PRICE 
	And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
End
Open ReleaseStocks
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @COST, @PTR, @PTS, @MRP
UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY
WHERE Batch_Code = @BATCH_CODE
If @@RowCount = 0 And @FreeRow = 1
Begin
	Close ReleaseStocks
	DeAllocate ReleaseStocks
	IF @TRACK_BATCHES = 1
	Begin
		DECLARE ReleaseStocks CURSOR KEYSET FOR
		SELECT Batch_Number,  Batch_Code , PurchasePrice, PTR, PTS, ECP
		FROM Batch_Products
		WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
		and ISNULL(ECP, 0) = @BATCH_PRICE AND (Expiry >= GetDate() OR Expiry IS NULL)
		And ISNULL(Damage, 0) = 0 
	End
	Else
	Begin
		DECLARE ReleaseStocks CURSOR KEYSET FOR
		SELECT Batch_Number, Batch_Code, PurchasePrice, PTR, PTS, ECP
		FROM Batch_Products
		WHERE Product_Code = @ITEM_CODE AND ISNULL(ECP, 0) = @BATCH_PRICE 
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
CSTPayable, TaxSuffered, TaxSuffered2) 
VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @REQUIRED_QUANTITY, 
@SALE_PRICE, @SALE_TAX, @DISCOUNT_PER, @DISCOUNT_AMOUNT, @AMOUNT, 
@COST * @REQUIRED_QUANTITY, @STPAYABLE, @SALEID, @PTR, @PTS, @MRP, @TAXID, @FLAG, 
@TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2)

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
Select 1
OvernOut:
Close ReleaseStocks
DeAllocate ReleaseStocks
