CREATE PROCEDURE sp_insert_batch(@PRODUCT_CODE nvarchar(15),
				 @BATCH_NUMBER nvarchar(128),
				 @EXPIRY datetime,
				 @QUANTITY Decimal(18,6),
				 @VALUE Decimal(18,6),
				 @SALE_PRICE Decimal(18,6),
				 @SALE_TAX int,
				 @PRICE_OPTION int,
				 @PTR Decimal(18,6),
				 @PTS Decimal(18,6),
				 @SPECIAL_PRICE Decimal(18,6),
				 @PURCHASE_PRICE Decimal(18,6),
				 @PKD datetime = Null,
				 @TAXSUFFERED Decimal(18,6),
				 @TAXTYPE Int = 0, --1=LST, 2=CST
				 @TAXCODE Int = 0)
AS
DECLARE @PRICE Decimal(18,6)
DECLARE @APPLICABLEON Int
DECLARE @PARTOFF Decimal(18,6)
Set @APPLICABLEON = 0
Set @PARTOFF = 0

If @TAXTYPE = 2 		--CST
	Select @APPLICABLEON=CstApplicableOn, @PARTOFF=CstPartOff from Tax Where Tax_Code=@TAXCODE
Else If @TAXTYPE = 1 --LST
	Select @APPLICABLEON=LstApplicableOn, @PARTOFF=LstPartOff from Tax Where Tax_Code=@TAXCODE

IF @PRICE_OPTION = 1 
SET @PRICE = @PURCHASE_PRICE 
ELSE SET @PRICE = @VALUE / @QUANTITY

INSERT INTO Batch_Products(Batch_Number,
			   Product_Code,
			   Expiry,
			   Quantity,
			   PurchasePrice,
			   SalePrice,
			   TaxCode,
			   PTR,
			   PTS,
			   Company_Price,
			   ECP,
			   PKD,
			   QuantityReceived,
				TaxSuffered,
				ApplicableOn,
				PartOfPercentage,
				DocType,
				Vat_Locality)
VALUES	(@BATCH_NUMBER,
	 @PRODUCT_CODE,
	 @EXPIRY,
	 @QUANTITY,
	 @PRICE,
	 @SALE_PRICE,
	 @SALE_TAX,
	 @PTR,
	 @PTS,
	 @SPECIAL_PRICE,
	 @SALE_PRICE,
	 @PKD, 
  	 @QUANTITY, 
	 @TAXSUFFERED,
	 @APPLICABLEON,
	 @PARTOFF,
	 6, @TAXTYPE)

IF @PRICE_OPTION = 1 
	UPDATE Items SET Sale_Price = @SALE_PRICE WHERE Product_Code = @PRODUCT_CODE
ELSE
--For NonCSP items Price Updations
	UPDATE Batch_Products SET SalePrice = Item.SALE_PRICE,ECP = Item.ECP from Batch_Products Batch,Items Item
	WHERE Batch.Product_Code = Item.PRODUCT_CODE and Batch.Product_Code = @PRODUCT_CODE 
	and  Isnull(Batch.[free],0) <> 1



