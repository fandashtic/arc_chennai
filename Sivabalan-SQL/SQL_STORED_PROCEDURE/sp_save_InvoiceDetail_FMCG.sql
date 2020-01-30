CREATE procedure [dbo].[sp_save_InvoiceDetail_FMCG]
                            (@INVOICEID INT,
		 	     @PRODUCTCODE NVARCHAR(30),
 		 	     @BATCH_CODE INT,
	     	     @BATCH_NUMBER NVARCHAR(15),
		 	     @QUANTITY Decimal(18,6), 
		 	     @SALEPRICE Decimal(18,6), 
		 	     @TAXCODE Decimal(18,6),
		 	     @DISCOUNTPERCENTAGE Decimal(18,6),
		 	     @DISCOUNTVALUE Decimal(18,6),
                 @AMOUNT Decimal(18,6),
			     @STPAYABLE Decimal(18,6),
			     @SCHEMEID int,
			     @PRIMARY_QUANTITY Decimal(18,6),
			     @SCHEME_COST Decimal(18,6),
			     @FLAG int,
			     @TAXCODE2 Decimal(18,6),
			     @CSTPAYABLE Decimal(18,6),
			     @TAXSUFFERED Decimal(18,6) = 0,
			     @TAXSUFFERED2 Decimal(18,6) = 0)
AS
DECLARE @COST Decimal(18,6)
DECLARE @SALEID int
DECLARE @ORIGINAL_QUANTITY Decimal(18,6)
DECLARE @MRP Decimal(18,6)
DECLARE @TAXID int
DECLARE @LOCALITY int
DECLARE @SECONDARY_SCHEME int

Select @LOCALITY = IsNull(case InvoiceType When 2 Then 1 Else Locality End, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID *= Customer.CustomerID And InvoiceID = @INVOICEID
IF @LOCALITY = 0 SET @LOCALITY = 1
IF @LOCALITY = 1
	SELECT @TAXID = Tax_Code FROM Tax WHERE Percentage = @TAXCODE
ELSE
	SELECT @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = @TAXCODE2

SET @ORIGINAL_QUANTITY = @QUANTITY
SELECT @COST = Purchase_Price, @SALEID = SaleID, @MRP = MRP FROM Items where Product_Code = @PRODUCTCODE
SET @COST = @COST * @QUANTITY
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST
INSERT INTO InvoiceDetail
                (InvoiceID,
		 Product_Code,
		 Batch_Code,
		 Batch_Number,
		 Quantity,
		 SalePrice,
		 TaxCode,
		 DiscountPercentage,
		 DiscountValue,
		 Amount,
		 PurchasePrice,
		 STPayable,
		 SaleID,
		 MRP,
		 TaxID,
		 FlagWord,
		 TaxCode2,
		 CSTPayable,
		 TaxSuffered,
		 TaxSuffered2)
VALUES	
                     (@INVOICEID, 
	         @PRODUCTCODE,
	         @BATCH_CODE,
	         @BATCH_NUMBER,
	         @QUANTITY, 
	         @SALEPRICE, 
	         @TAXCODE, 
	         @DISCOUNTPERCENTAGE, 
	         @DISCOUNTVALUE, 
	         @AMOUNT,
		 @COST,
		 @STPAYABLE,
		 @SALEID,
		 @MRP,
		 @TAXID,
		 @FLAG,
		 @TAXCODE2,
		 @CSTPAYABLE,
		 @TAXSUFFERED,
		 @TAXSUFFERED2)

IF @SCHEMEID <> 0
BEGIN
	Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SCHEMEID
	Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags) 
	Values(@PRODUCTCODE, @PRIMARY_QUANTITY, @ORIGINAL_QUANTITY, @SALEPRICE * @ORIGINAL_QUANTITY, @SCHEME_COST, @SCHEMEID, @INVOICEID, 0, @ORIGINAL_QUANTITY, @SECONDARY_SCHEME)
END
SELECT 1
