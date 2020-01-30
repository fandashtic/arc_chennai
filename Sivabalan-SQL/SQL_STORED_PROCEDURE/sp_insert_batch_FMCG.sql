CREATE PROCEDURE sp_insert_batch_FMCG(@PRODUCT_CODE nvarchar(15),    
     @BATCH_NUMBER nvarchar(128),    
     @EXPIRY datetime,    
     @QUANTITY Decimal(18,6),    
     @VALUE Decimal(18,6),    
     @SALE_PRICE Decimal(18,6),    
     @SALE_TAX int,    
     @PRICE_OPTION int,    
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
    
If @TAXTYPE = 2   --CST    
 Select @APPLICABLEON=CstApplicableOn, @PARTOFF=CstPartOff from Tax Where Tax_Code=@TAXCODE    
Else If @TAXTYPE = 1 --LST    
 Select @APPLICABLEON=LstApplicableOn, @PARTOFF=LstPartOff from Tax Where Tax_Code=@TAXCODE    
    
IF @PRICE_OPTION = 1 SET @PRICE = @PURCHASE_PRICE     
ELSE     
SET @PRICE = @VALUE / @QUANTITY    

INSERT INTO Batch_Products(Batch_Number,    
      Product_Code,    
      Expiry,    
      Quantity,    
      PurchasePrice,    
      SalePrice,    
      TaxCode,    
      PKD,    
    QuantityReceived,    
      TaxSuffered,    
    ApplicableOn,    
    PartOfPercentage,    
    DocType,    
    Vat_Locality)    
VALUES (@BATCH_NUMBER,    
  @PRODUCT_CODE,    
  @EXPIRY,    
  @QUANTITY,    
  @PRICE,    
  @SALE_PRICE,    
  @SALE_TAX,    
  @PKD,    
  @QUANTITY,    
  @TAXSUFFERED,    
  @APPLICABLEON,    
  @PARTOFF,    
  6, @TAXTYPE)    
IF @PRICE_OPTION = 1   
UPDATE Items SET Sale_Price = @SALE_PRICE,Purchase_Price = @PRICE WHERE Product_Code = @PRODUCT_CODE    
else
	Update Batch_Products set SalePrice = @Sale_Price Where 
	Product_code = @PRODUCT_CODE And isnull(free,0) <> 1



