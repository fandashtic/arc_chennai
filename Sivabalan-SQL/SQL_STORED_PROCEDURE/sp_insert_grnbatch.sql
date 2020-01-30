CREATE PROCEDURE sp_insert_grnbatch(@GRNID int,             
     @PRODUCT_CODE nvarchar(30),             
     @QUANTITY Decimal(18,6),            
     @SALE_PRICE Decimal(18,6),            
     @BATCH_NUMBER nvarchar(128),            
     @EXPIRY datetime,            
     @PTS Decimal(18,6),            
     @PTR Decimal(18,6),            
     @ECP Decimal(18,6),            
     @PRICEOPTION int,            
     @SPECIAL_PRICE Decimal(18,6),            
     @PKD nvarchar(12),            
     @FREE Decimal(18, 6),            
     @OpeningDate datetime = Null,            
     @BackDatedTransaction int = 0,          
     @TaxSuff Decimal(18,6) = 0,        
     @TaxID Int = Null,  
     @Vat_locality Int=0,  
     @DocType Int=Null,
     @TaxType Int=1)            
AS            
DECLARE @PURCHASE_PRICE Decimal(18,6)            
DECLARE @PKD_DATE datetime            
DECLARE @PKD_TRACKED int            
DECLARE @BATCHCODE int            
DECLARE @DIFF Decimal(18,6)            
DECLARE @GRNAPPLICABLEON int      
Declare @GRNPARTOFF Decimal(18,6)      
DECLARE @APPLICABLEON int      
Declare @PARTOFF Decimal(18,6)              
Declare @IS_VAT_ITEM Int
If @TaxSuff > 0         
Begin        
	If Not exists(Select * from Tax Where (case When Percentage = @TaxSuff then 1 When CST_Percentage = @TaxSuff Then 1 Else 0 End) = 1)        
	Set @TaxSuff = 0        
End        

If @GRNID>0 AND @Vat_locality=0 --IF this proc is Called From GRN
	Select TOP 1 @Vat_locality = Locality from Vendors where VendorID in (Select VendorID from GRNAbstract where GRNID=@GRNID)

/*
If @Vat_locality=1		--LST
	SELECT @APPLICABLEON = LstApplicableOn, @PARTOFF = LstPartOff from Tax where Tax_Code= @TaxId      
Else If @Vat_locality=2 --CST
	SELECT @APPLICABLEON = CstApplicableOn, @PARTOFF = CstPartOff from Tax where Tax_Code= @TaxId      
*/
IF @TaxType = 2  --CST
	SELECT @APPLICABLEON = CstApplicableOn, @PARTOFF = CstPartOff from Tax where Tax_Code= @TaxId      
Else             --LST
	SELECT @APPLICABLEON = LstApplicableOn, @PARTOFF = LstPartOff from Tax where Tax_Code= @TaxId      

If @GRNID> 0   
Begin      
	Select @GRNAPPLICABLEON = @APPLICABLEON
	Select @GRNPARTOFF = @PARTOFF
End  
         
SET @BATCH_NUMBER = Replace(@BATCH_NUMBER, CHAR(9), N',')            
IF @PRICEOPTION = 0            
 SELECT @PURCHASE_PRICE = Purchase_Price, @PKD_TRACKED = TrackPKD FROM Items WHERE Product_Code = @PRODUCT_CODE            
ELSE            
 SELECT @PURCHASE_PRICE = Case Purchased_At             
    WHEN 1 THEN @PTS            
    WHEN 2 THEN @PTR            
    ELSE Items.Purchase_Price            
    END,             
    @PKD_TRACKED = TrackPKD            
    FROM Items WHERE Product_Code = @PRODUCT_CODE            
SELECT @PKD_TRACKED = TrackPKD FROM Items WHERE Product_Code = @PRODUCT_CODE            
IF @PKD_TRACKED = 1            
BEGIN            
SET @PKD_DATE = N'1/' + substring(@PKD, 1, 2) + N'/' + substring(@PKD, 4, 4)            
IF ISNULL(@BATCH_NUMBER, N'') = N'' SET @BATCH_NUMBER = @PKD            
END            
ELSE            
 SET @PKD_DATE = Null            
            
INSERT INTO Batch_Products(Batch_Number,            
      Product_Code,            
      GRN_ID,            
      Expiry,            
      Quantity,            
      SalePrice,            
      PTS,            
      PTR,            
      ECP,            
      PurchasePrice,            
      QuantityReceived,            
      Company_Price,            
      PKD,             
      Free,TaxSuffered , GRNTaxsuffered, GRNTaxID, GRNApplicableOn,   
      GRNPartOff, ApplicableOn, PartOfPercentage, Vat_locality,DocType,TaxType)            
VALUES (@BATCH_NUMBER,            
  @PRODUCT_CODE,            
  @GRNID,            
  @EXPIRY,            
  @QUANTITY,            
  @SALE_PRICE,            
  @PTS,            
  @PTR,            
  @ECP,      
  @PURCHASE_PRICE,            
  @QUANTITY,            
  @SPECIAL_PRICE,        
  @PKD_DATE,            
  0,@TaxSuff,@TaxSuff,@TaxID,@GRNAPPLICABLEON,@GRNPARTOFF, @ApplicableOn, @PartOff,@Vat_locality,@DocType,@TaxType )            
Select @BATCHCODE = @@IDENTITY            

IF @BackDatedTransaction = 1             
BEGIN            
	SET @DIFF = @QUANTITY            
	exec sp_update_opening_stock @PRODUCT_CODE, @OpeningDate, @DIFF, 0, @PURCHASE_PRICE, 0, 0, @BATCHCODE
END

If @Free > 0             
Begin            
INSERT INTO Batch_Products(Batch_Number,            
      Product_Code,            
      GRN_ID,            
      Expiry,            
      Quantity,            
      SalePrice,            
      PTS,            
      PTR,            
      ECP,            
      PurchasePrice,            
      QuantityReceived,            
      Company_Price,            
      PKD,             
      Free,            
      BatchReference,TaxSuffered,GRNTaxSuffered,GRNTaxID,GrnApplicableOn,  
      GrnPartOff, ApplicableOn, PartOfPercentage, Vat_locality, DocType, TaxType)            
VALUES (@BATCH_NUMBER,            
  @PRODUCT_CODE,            
  @GRNID,            
  @EXPIRY,            
  @FREE,            
  0,            
  0,            
  0,            
  0,            
  0,            
  @FREE,            
  0,            
  @PKD_DATE,            
  1,            
  @BATCHCODE,@TaxSuff,@TaxSuff,@TaxID,@GRNAPPLICABLEON,
  @GRNPARTOFF, @ApplicableOn, @PartOff,@Vat_locality,@DocType,@TaxType)             
IF @BackDatedTransaction = 1             
BEGIN            
SET @DIFF = @FREE            
exec sp_update_opening_stock @PRODUCT_CODE, @OpeningDate, @DIFF, 1, 0
END            
End            
If @GRNID>0 --If this proc is Called from GRN
Begin
	--Updating TaxSuff Percentage in OpeningDetails
	Select @IS_VAT_ITEM = IsNull(Vat,0) from Items Where Product_Code=@Product_Code
	If @Vat_Locality = 2 AND @IS_VAT_ITEM = 1
		Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate, @Product_Code, @BatchCode, 0, 1
	Else
		Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate, @Product_Code, @BatchCode
End

declare @track_csp int, @purchased_at int
select @track_csp = itemcategories.price_option,@purchased_at = items.purchased_at
from itemcategories, items 	where itemcategories.categoryid = items.categoryid
and items.product_code = @product_Code

if @track_csp = 1 
	begin
		IF @PURCHASED_AT = 1 
			BEGIN
				update items set sale_price = @PTS, purchase_price = @purchase_price,
		       	PTS=@PTS,PTR=@PTR,ECP=@ECP,company_price = @Special_Price                    
		        where items.product_code = @product_Code
			END
		ELSE
			BEGIN
				update items set sale_price = @PTR, purchase_price = @purchase_price,
		       	PTS=@PTS,PTR=@PTR,ECP=@ECP,company_price = @Special_Price                    
		        where items.product_code = @product_Code
			END
	END
ELSE
--Price Updation for NonCSP items
	Begin
		UPDATE Batch_Products SET SalePrice = Item.SALE_PRICE , PTS = Item.PTS,
		PTR = Item.PTR,ECP = Item.ECP,Company_price=Item.Company_Price 
		from Batch_Products Batch,Items Item
		WHERE Batch.Product_Code = Item.PRODUCT_CODE and Batch.Product_Code = @PRODUCT_CODE 
		and  Isnull(Batch.[free],0) <> 1

	End


SELECT @BATCHCODE         







