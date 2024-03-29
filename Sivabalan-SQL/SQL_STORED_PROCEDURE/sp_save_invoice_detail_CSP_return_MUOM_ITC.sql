CREATE Procedure sp_save_invoice_detail_CSP_return_MUOM_ITC(@INVOICE_ID int,
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
@DOCSERIAL Int = 0,
@OtherCG_Item int = 0,
@TSCODE Int = 0,
@TSApplicableOn int = 0,
@TSPartOff decimal(18,6) = 0,
@QuotationID int =0,
@GroupID int = 0,
@NewSchFunctionality Int = 0,
@MultipleSchemeDetails nVarchar(4000)='',
@MultipleSplCategorySchDetail nVarchar(4000)='',
@MRPPERPACK Decimal(18,6) = 0,
@TAXONQTY int = 0,
@GSTTaxID int = 0,
@GSTFlag int = 0,
@GSTCSTaxCode int = 0,
@GSTLocality int = 0,
@CustomerID nvarchar(15) = '',
@GenericPTR Decimal(18,6) = 0,
@InvoiceID int = 0,
@SRBatchAvailFlag int = 0,
@SerialNo int = 0
)
AS
Declare @InvDate Datetime
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
DECLARE @TAX_TYPE int
DECLARE @BATCHMRPPERPACK Decimal(18,6)
DECLARE @TOQ AS Int
Declare @HSNNumber nvarchar(50)
Declare @CategorizationID int
Declare @GSTTaxType int
Declare @BatchTaxGSTFlag int
Declare @BatchTaxCSCode int
Declare @BatchTaxPercentage Decimal (18,6)
Declare @PFM Decimal(18,6)
Declare @GRNID int

Set @ADD_TAXSUFF_TO_OPDET = 0
Select @INVDate=InvoiceDate from Invoiceabstract where invoiceid=@INVOICE_ID
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

Select @BatchTaxGSTFlag = isnull(GSTFlag,0), @BatchTaxCSCode = isnull(CS_TaxCode,0), @BatchTaxPercentage = Percentage
From Tax Where Tax_Code = @TAXID
Set @GSTCSTaxCode = isnull(@BatchTaxCSCode,0)
Set @GSTFlag = isnull(@BatchTaxGSTFlag,0)


Create Table #TmpInvBatch (Batch_Code int)

IF Exists(Select 'x' From InvoiceAbstract Where InvoiceID = @InvoiceID and isnull(Status,0) & 16 <> 0)
Insert Into #TmpInvBatch(Batch_Code)
Select VD.Batch_Code From InvoiceDetail ID
Inner Join VanStatementDetail VD ON ID.Batch_Code = VD.ID and ID.Product_Code = VD.Product_Code
Where ID.InvoiceID = @InvoiceId and ID.Product_Code = @ITEM_CODE
and ID.Serial = @SerialNo
Else
Insert Into #TmpInvBatch(Batch_Code)
Select Batch_Code From InvoiceDetail where InvoiceID = @InvoiceId and Product_Code = @ITEM_CODE
and Serial = @SerialNo

EXEC sp_update_openingdetails_firsttime @ITEM_CODE
-- IF NOT EXISTS (SELECT MessageID FROM StockAdjustmentReason WHERE Message = @DAMAGESREASON)
-- BEGIN
--  	INSERT INTO StockAdjustmentReason(Message, Active) Values (@DAMAGESREASON, 1)
-- END
--
-- SELECT @REASON_ID = ISNULL(MessageID, 0) FROM StockAdjustmentReason WHERE Message = @DAMAGESREASON

SELECT @REASON_ID = ISNULL(Reason_Type_ID, 0) FROM ReasonMaster
WHERE Reason_Description = @DAMAGESREASON
And Reason_SubType = Case When @DAMAGES = 0 Then 1 when @DAMAGES = 1 Then 2 Else 0 End

SET @ORIGINAL_QTY = @REQUIRED_QUANTITY
SELECT @COST = Purchase_Price, @MRP = MRP, @SALEID = SaleID, @HSNNumber = isnull(HSNNumber,'') , @CategorizationID = isnull(CategorizationID,0)
FROM Items WHERE Product_code = @ITEM_CODE
SET @COST = @COST
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @REQUIRED_QUANTITY
IF @TRACK_INVENTORY = 0
BEGIN
SET @RETVAL = 1

IF IsNull(@MRPPERPACK,0) = 0
SELECT  @MRPPERPACK = Isnull(MRPPerPack,0) FROM Items WHERE Product_Code = @ITEM_CODE

INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number, Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue,
Amount, PurchasePrice, STPayable, TaxID, FlagWord, SaleID, TaxCode2, CSTPayable, TaxSuffered, TaxSuffered2, ReasonID, UOM, UOMQty,
UOMPrice, OtherCG_Item,QuotationID,GroupID,MultipleSchemeDetails,MultipleSplCategorySchDetail,MRPPerPack,TAXONQTY,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)
VALUES (@INVOICE_ID, @ITEM_CODE, 0, N'', @REQUIRED_QUANTITY, @MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE, @DISCOUNTAMOUNT,
@AMOUNT,@COST * @REQUIRED_QUANTITY, @STPAYABLE, @TAXID, @FLAG, @SALEID, @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @REASON_ID, @UOM, @UOMQty,
@UOMPrice, @OtherCG_Item,@QuotationID,@GroupID,@MultipleSchemeDetails,@MultipleSplCategorySchDetail,@MRPPERPACK,@TAXONQTY,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)
GOTO ALL_SAID_AND_DONE
END
IF @SRBatchAvailFlag = 1
Begin
IF @TRACK_BATCHES = 1
BEGIN
IF @CUSTOMER_TYPE = 1
BEGIN
if (@DAMAGES=1)
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), BP.Batch_Code, Quantity, PurchasePrice, PTR, PTS, Expiry,
PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID  FROM Batch_Products BP
Join #TmpInvBatch InvBP On BP.batch_code = InvBP.batch_code
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(PTS, 0) = @SALE_PRICE AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
--AND (Expiry >= GetDate() OR Expiry IS NULL)
And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
ELSE
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), BP.Batch_Code, Quantity, PurchasePrice, PTR, PTS, Expiry,
PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID  FROM Batch_Products BP
Join #TmpInvBatch InvBP On BP.batch_code = InvBP.batch_code
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(PTS, 0) = @SALE_PRICE AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
AND (Expiry >= GetDate() OR Expiry IS NULL)
And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
END
ELSE IF @CUSTOMER_TYPE = 2
BEGIN
IF (@DAMAGES = 1)
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), BP.Batch_Code, Quantity, PurchasePrice, PTR, PTS, Expiry,
PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products BP
Join #TmpInvBatch InvBP On BP.batch_code = InvBP.batch_code
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(PTR, 0) = @GenericPTR AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
--AND (Expiry >= GetDate() OR Expiry IS NULL)
And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
ELSE
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), BP.Batch_Code, Quantity, PurchasePrice, PTR, PTS, Expiry,
PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products BP
Join #TmpInvBatch InvBP On BP.batch_code = InvBP.batch_code
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(PTR, 0) = @GenericPTR AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
AND (Expiry >= GetDate() OR Expiry IS NULL)
And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
END
ELSE IF @CUSTOMER_TYPE = 3
BEGIN
IF (@DAMAGES = 1)
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), BP.Batch_Code, Quantity, PurchasePrice, PTR, PTS,
Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products BP
Join #TmpInvBatch InvBP On BP.batch_code = InvBP.batch_code
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(Company_Price, 0) = @SALE_PRICE  AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
--AND (Expiry >= GetDate() OR Expiry IS NULL)
And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
ELSE
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), BP.Batch_Code, Quantity, PurchasePrice, PTR, PTS,
Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products BP
Join #TmpInvBatch InvBP On BP.batch_code = InvBP.batch_code
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(Company_Price, 0) = @SALE_PRICE  AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
END
END
ELSE
BEGIN
IF @CUSTOMER_TYPE = 1
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), BP.Batch_Code, Quantity, PurchasePrice, PTR, PTS,
Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products BP
Join #TmpInvBatch InvBP On BP.batch_code = InvBP.batch_code
WHERE Product_Code = @ITEM_CODE
AND ISNULL(PTS, 0) = @SALE_PRICE And isnull(Free, 0) = @FreeRow AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
ELSE IF @CUSTOMER_TYPE = 2
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), BP.Batch_Code, Quantity, PurchasePrice, PTR, PTS,
Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products BP
Join #TmpInvBatch InvBP On BP.batch_code = InvBP.batch_code
WHERE Product_Code = @ITEM_CODE
AND ISNULL(PTR, 0) = @GenericPTR And isnull(Free, 0) = @FreeRow AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
ELSE IF @CUSTOMER_TYPE = 3
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), BP.Batch_Code, Quantity, PurchasePrice, PTR, PTS,
Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products BP
Join #TmpInvBatch InvBP On BP.batch_code = InvBP.batch_code
WHERE Product_Code = @ITEM_CODE
AND ISNULL(Company_Price, 0) = @SALE_PRICE And isnull(Free, 0) = @FreeRow AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
END
End
Else--@SRBatchAvailFlag
Begin
IF @TRACK_BATCHES = 1
BEGIN
IF @CUSTOMER_TYPE = 1
BEGIN
if (@DAMAGES=1)
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS, Expiry,
PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID  FROM Batch_Products
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(PTS, 0) = @SALE_PRICE AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
--AND (Expiry >= GetDate() OR Expiry IS NULL)
And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
ELSE
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS, Expiry,
PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID  FROM Batch_Products
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(PTS, 0) = @SALE_PRICE AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
AND (Expiry >= GetDate() OR Expiry IS NULL)
And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
END
ELSE IF @CUSTOMER_TYPE = 2
BEGIN
IF (@DAMAGES = 1)
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS, Expiry,
PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(PTR, 0) = @GenericPTR AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
--AND (Expiry >= GetDate() OR Expiry IS NULL)
And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
ELSE
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS, Expiry,
PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(PTR, 0) = @GenericPTR AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
AND (Expiry >= GetDate() OR Expiry IS NULL)
And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
END
ELSE IF @CUSTOMER_TYPE = 3
BEGIN
IF (@DAMAGES = 1)
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS,
Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(Company_Price, 0) = @SALE_PRICE  AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
--AND (Expiry >= GetDate() OR Expiry IS NULL)
And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
ELSE
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS,
Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products
WHERE Product_Code = @ITEM_CODE
and ISNULL(Batch_Number, N'') = @BATCH_NUMBER
and ISNULL(Company_Price, 0) = @SALE_PRICE  AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
AND (Expiry >= GetDate() OR Expiry IS NULL) And isnull(Free, 0) = @FreeRow
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
END
END
ELSE
BEGIN
IF @CUSTOMER_TYPE = 1
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS,
Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products
WHERE Product_Code = @ITEM_CODE
AND ISNULL(PTS, 0) = @SALE_PRICE And isnull(Free, 0) = @FreeRow AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
ELSE IF @CUSTOMER_TYPE = 2
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS,
Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products
WHERE Product_Code = @ITEM_CODE
AND ISNULL(PTR, 0) = @GenericPTR And isnull(Free, 0) = @FreeRow AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
ELSE IF @CUSTOMER_TYPE = 3
BEGIN
DECLARE ReleaseStocks CURSOR KEYSET FOR
SELECT IsNull(Batch_Number,''), Batch_Code, Quantity, PurchasePrice, PTR, PTS,
Expiry, PurchasePrice, ECP, Company_Price, PKD, TaxSuffered, IsNull(TaxType,1),MRPPERPACK, GSTTaxType,PFM,GRN_ID FROM Batch_Products
WHERE Product_Code = @ITEM_CODE
AND ISNULL(Company_Price, 0) = @SALE_PRICE And isnull(Free, 0) = @FreeRow AND ISNULL(MRPPERPACK, 0) = @MRPPERPACK
And (IsNull(Damage, 0) = @DAMAGES Or @DAMAGES = 1)
END
END
End
OPEN ReleaseStocks
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @PTR, @PTS,
@EXPIRY, @PURCHASEPRICE, @ECP, @SPECIAL_PRICE, @PKD_DATE, @TAXSUFFERED_ORIG, @TAX_TYPE ,@BATCHMRPPERPACK,@GSTTaxType,@PFM,@GRNID

IF @@FETCH_STATUS <> 0
BEGIN
SET @RETVAL = 0
GOTO OVERNOUT
END
ELSE
BEGIN
SET @RETVAL = 1
--SELECT @MRPPERPACK = ISNULL(MRPPerPack,0) FROM Batch_Products WHERE Batch_Code = @BATCH_CODE

--	IF IsNull(@BATCHMRPPERPACK,0) = 0
--		SELECT  @BATCHMRPPERPACK = Isnull(MRPPerPack,0) FROM Items WHERE Product_Code = @ITEM_CODE

IF @DAMAGES = 0
BEGIN
IF Exists (Select * from Batch_Products Where Batch_Code = @Batch_Code And IsNull(DocType,0) = 3 And IsNull(DocID,0) = 0 AND IsNull(QuantityReceived,0)=0)
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
PurchasePrice, STPayable, PTR, PTS, MRP, TaxID, FlagWord, SaleID, TaxCode2,
CSTPayable, TaxSuffered, TaxSuffered2, ReasonID, UOM, UOMQty, UOMPrice, OtherCG_Item,
QuotationID,GroupID,MultipleSchemeDetails,MultipleSplCategorySchDetail,MRPPerPack,TAXONQTY,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)
VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER,
@REQUIRED_QUANTITY, @MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE,
@DISCOUNTAMOUNT, @AMOUNT, @REQUIRED_QUANTITY * @COST, @STPAYABLE, @PTR,
@PTS, @ECP, @TAXID, @FLAG, @SALEID, @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED,
@TAXSUFFERED2, @REASON_ID, @UOM, @UOMQty, @UOMPrice, @OtherCG_Item,
@QuotationID,@GroupID,@MultipleSchemeDetails,@MultipleSplCategorySchDetail,@BATCHMRPPERPACK,@TAXONQTY,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)
END
ELSE
BEGIN
SELECT @TOQ = IsNull(TOQ,0) From  Batch_Products  WHERE Batch_Code = @BATCH_CODE

IF isnull(@BatchTaxCSCode,0) > 0
Begin
Set @TAXSUFFERED_ORIG = @TAXCODE + @TAXCODE2
Set @TAX_TYPE = 5
Set @GSTTaxType = @LOCALITY
End

INSERT INTO Batch_Products(Product_Code, Batch_Number, Expiry, Quantity,
PurchasePrice, SalePrice, PTS, PTR, ECP, Company_Price, Free,
Damage, DamagesReason, PKD, TaxSuffered,DocType, DocID,ApplicableOn,PartofPercentage, TaxType,DocDate,QuantityReceived,
MRPPerPack,TOQ,GRNTaxID,GSTTaxType,PFM,GRN_ID)
VALUES(@ITEM_CODE, @BATCH_NUMBER, @EXPIRY, @REQUIRED_QUANTITY, @PURCHASEPRICE, @ECP, @PTS, @PTR, @ECP, @SPECIAL_PRICE, @FreeRow,
2, @REASON_ID, @PKD_DATE, @TAXSUFFERED_ORIG,1,@INVOICE_ID,@TSApplicableOn,@TSPartOff, @TAX_TYPE,@INVDate,@REQUIRED_QUANTITY,
@BATCHMRPPERPACK,@TOQ,@TaxID,@GSTTaxType,@PFM,@GRNID)

INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code,
Batch_Number, Quantity, SalePrice, TaxCode, DiscountPercentage,
DiscountValue, Amount, PurchasePrice, STPayable, PTR, PTS, MRP, TaxID,
FlagWord, SaleID, TaxCode2, CSTPayable, TaxSuffered, TaxSuffered2, ReasonID,
UOM, UOMQty, UOMPrice, OtherCG_Item,QuotationID,GroupID,MultipleSchemeDetails,
MultipleSplCategorySchDetail,MRPPerPack,TAXONQTY,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)
VALUES (@INVOICE_ID, @ITEM_CODE, @@IDENTITY, @BATCH_NUMBER,
@REQUIRED_QUANTITY, @MODIFIED_PRICE, @TAXCODE, @DISCOUNTPERCENTAGE,
@DISCOUNTAMOUNT, @AMOUNT, @REQUIRED_QUANTITY * @COST, @STPAYABLE, @PTR,
@PTS, @ECP, @TAXID, @FLAG, @SALEID, @TAXCODE2, @CSTPAYABLE, @TAXSUFFERED,
@TAXSUFFERED2, @REASON_ID, @UOM, @UOMQty, @UOMPrice, @OtherCG_Item,@QuotationID,@GroupID,@MultipleSchemeDetails,
@MultipleSplCategorySchDetail,@BATCHMRPPERPACK,@TAXONQTY,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)

IF @DOCSERIAL > 0
BEGIN
UPDATE InvoiceAbstract Set ReferenceNumber = @DOCSERIAL Where InvoiceID = @INVOICE_ID
END
END
END

OVERNOUT:
CLOSE ReleaseStocks
DEALLOCATE ReleaseStocks
IF @BackDatedTransaction = 1
BEGIN
SET @DIFF = @REQUIRED_QUANTITY
exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @PURCHASEPRICE, @DAMAGES, 0, @BATCH_CODE

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
If @RETVAL = 1
Begin
IF @SCHEMEID <> 0
BEGIN
Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SCHEMEID
Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags)
Values(@ITEM_CODE, @PRIMARY_QUANTITY, @ORIGINAL_QTY, @MODIFIED_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SCHEMEID, @INVOICE_ID, 0, @ORIGINAL_QTY, @SECONDARY_SCHEME)
END
End
SELECT @RETVAL

Drop table #TmpInvBatch

