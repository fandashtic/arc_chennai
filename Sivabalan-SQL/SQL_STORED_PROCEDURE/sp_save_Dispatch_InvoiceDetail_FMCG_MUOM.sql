CREATE procedure [dbo].[sp_save_Dispatch_InvoiceDetail_FMCG_MUOM] (@INVOICEID INT,
		 	     @PRODUCTCODE nvarchar(15),
 		 	     @DISPATCHID nvarchar(50),
	   	     	     @BATCH_NUMBER nvarchar(15),
		 	     @QUANTITY Decimal(18,6), 
		 	     @SALEPRICE Decimal(18,6), 
		 	     @TAXCODE FLOAT,
		 	     @DISCOUNTPERCENTAGE Decimal(18,6),
		 	     @DISCOUNTVALUE Decimal(18,6),
        	             @AMOUNT Decimal(18,6),
			     @STPAYABLE Decimal(18,6),
			     @SCHEMEID int,
			     @PRIMARY_QUANTITY int,
			     @SCHEME_COST Decimal(18,6),
			     @FLAG int,
			     @TAXCODE2 FLOAT,
			     @CSTPAYABLE Decimal(18,6),
			     @TAXSUFFERED Decimal(18,6) = 0,
			     @TAXSUFFERED2 Decimal(18,6) = 0,
	  		     @UOM INT = 0,
			     @UOMQTY INT = 0,
			     @UOMPRICE Decimal(18,6) = 0,
			     @ORIGINALPRICE Decimal(18,6) = 0)  
AS
DECLARE @COST Decimal(18,6)
DECLARE @SALEID int
DECLARE @ORIGINAL_QUANTITY Decimal(18,6)
DECLARE @MRP Decimal(18,6)
DECLARE @TAXID int
DECLARE @LOCALITY int
DECLARE @SECONDARY_SCHEME int
DECLARE @BATCH_CODE Int
DECLARE @PURPRICE Decimal(18,6)
DECLARE @DispatchTable Table(DispatchID Int)
DECLARE @START Int
DECLARE @END Int

SET @START = 1
While @START <= Len(@DISPATCHID)
Begin
	Set @END = CharIndex(N',', @DISPATCHID, @START)
	If @END = 0
		SET @END = Len(@DISPATCHID) + 1
	Insert Into @DispatchTable Values (SubString(@DISPATCHID, @START, @END - @START))
	SET @START = @END + 1
End
Select @LOCALITY = IsNull(case InvoiceType When 2 Then 1 Else Locality End, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID *= Customer.CustomerID And InvoiceID = @INVOICEID
IF @LOCALITY = 0 SET @LOCALITY = 1
IF @LOCALITY = 1
	SELECT @TAXID = Tax_Code FROM Tax WHERE Percentage = @TAXCODE
ELSE
	SELECT @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = @TAXCODE2

SET @ORIGINAL_QUANTITY = @QUANTITY
SELECT @COST = Purchase_Price, @SALEID = SaleID, @MRP = MRP FROM Items where Product_Code = @PRODUCTCODE
SET @PURPRICE = @COST
SET @COST = @COST * @QUANTITY
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST
DECLARE ReleaseStocks CURSOR KEYSET FOR
Select DispatchDetail.Batch_Code, DispatchDetail.Quantity, DispatchDetail.UOM, 
DispatchDetail.UOMQty, DispatchDetail.UOMPrice
From DispatchDetail
Left Outer Join Batch_Products on DispatchDetail.Batch_Code = Batch_Products.Batch_Code	
Where 
DispatchID In (Select DispatchID From @DispatchTable) And 
DispatchDetail.SalePrice = @ORIGINALPRICE And
DispatchDetail.Product_Code = @ProductCode And
Isnull(Batch_Products.Batch_Number,N'') = @BATCH_NUMBER
Open ReleaseStocks
Fetch From ReleaseStocks Into @BATCH_CODE, @QUANTITY, @UOM, @UOMQty, @UOMPrice
While @@Fetch_Status = 0
Begin
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
		 TaxSuffered2,
		 UOM,
		 UOMQty,
		 UOMPrice)
	VALUES	
        (@INVOICEID, 
	     @PRODUCTCODE,
	     @BATCH_CODE,
	     @BATCH_NUMBER,
	     @QUANTITY, 
	     @SALEPRICE, 
	     @TAXCODE, 
	     @DISCOUNTPERCENTAGE, 
	     @DISCOUNTVALUE * @QUANTITY, 
	     @AMOUNT * @QUANTITY,
		 @COST * @QUANTITY,
		 @STPAYABLE * @QUANTITY,
		 @SALEID,
		 @MRP,
		 @TAXID,
		 @FLAG,
		 @TAXCODE2,
		 @CSTPAYABLE * @QUANTITY,
		 @TAXSUFFERED,
		 @TAXSUFFERED2,
		 @UOM,
		 @UOMQTY,
		 @UOMPRICE)
	Fetch Next From ReleaseStocks Into @BATCH_CODE, @QUANTITY, @UOM, @UOMQty, @UOMPrice
End
Close ReleaseStocks
DeAllocate ReleaseStocks
IF @SCHEMEID <> 0
BEGIN
	Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SCHEMEID
	Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags) 
	Values(@PRODUCTCODE, @PRIMARY_QUANTITY, @ORIGINAL_QUANTITY, @SALEPRICE * @ORIGINAL_QUANTITY, @SCHEME_COST, @SCHEMEID, @INVOICEID, 0, @ORIGINAL_QUANTITY, @SECONDARY_SCHEME)
END
SELECT 1
