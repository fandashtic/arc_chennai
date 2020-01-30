CREATE PROCEDURE sp_insert_batch_MUOM(@PRODUCT_CODE nvarchar(15),  
     @BATCH_NUMBER nvarchar(128),  
     @EXPIRY datetime,  
     @QUANTITY Decimal(18,6),  
     @VALUE Decimal(18,6),  
     @SALE_PRICE Decimal(18,6),  
     @SALE_TAX Decimal(18,6),  
     @PRICE_OPTION int,  
     @PTR Decimal(18,6),  
     @PTS Decimal(18,6),  
     @SPECIAL_PRICE Decimal(18,6),  
     @PURCHASE_PRICE Decimal(18,6),  
     @PKD datetime = Null,  
     @TAXSUFFERED Decimal(18,6),  
     @TAXTYPE Int = 0, --1=LST, 2=CST  
     @TAXCODE Int = 0,
	 @PFM Decimal(18,6) = 0,@MRPFORTAX Decimal(18,6) =0)  
AS  
DECLARE @PRICE Decimal(18,6)  
Declare @UOM Int  
DECLARE @APPLICABLEON Int  
DECLARE @PARTOFF Decimal(18,6)  
Set @APPLICABLEON = 0  
Set @PARTOFF = 0  
  
If @TAXTYPE = 2   --CST  
 Select @APPLICABLEON=CstApplicableOn, @PARTOFF=CstPartOff from Tax Where Tax_Code=@TAXCODE  
Else If @TAXTYPE = 1 --LST  
 Select @APPLICABLEON=LstApplicableOn, @PARTOFF=LstPartOff from Tax Where Tax_Code=@TAXCODE  
  
IF @PRICE_OPTION = 1 SET @PRICE = @PURCHASE_PRICE ELSE SET @PRICE = @VALUE / @QUANTITY  
Select @UOM = UOM From Items Where Product_Code = @PRODUCT_CODE  
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
    UOM,  
    UOMQty,  
    UOMPrice,  
    ApplicableOn,  
    PartOfPercentage,  
    DocType, Vat_Locality, 
    TaxType,PFM,MRPFORTAX)  
VALUES (@BATCH_NUMBER,  
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
  @UOM,  
  @QUANTITY,  
  @PRICE,  
  @APPLICABLEON,  
  @PARTOFF,  
  6, (Case @TAXTYPE When 2 Then 2 Else 1 End), @TAXTYPE,@PFM,@MRPFORTAX)  
IF @PRICE_OPTION = 1   
 UPDATE Items SET Sale_Price = @SALE_PRICE WHERE Product_Code = @PRODUCT_CODE  
ELSE  
--For NonCSP items Price Updation in Batch_Products  
 UPDATE Batch_Products SET SalePrice = Item.SALE_PRICE,ECP = Item.ECP from Batch_Products Batch, Items Item  
 WHERE Batch.Product_Code = Item.PRODUCT_CODE and Batch.Product_Code = @PRODUCT_CODE   
 and  Isnull(Batch.[free],0) <> 1  

