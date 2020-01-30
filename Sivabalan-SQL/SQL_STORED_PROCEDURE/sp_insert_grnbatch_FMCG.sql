CREATE PROCEDURE sp_insert_grnbatch_FMCG(@GRNID int,           
     @PRODUCT_CODE nvarchar(30),           
     @QUANTITY Decimal(18,6),          
     @SALE_PRICE Decimal(18,6),          
     @BATCH_NUMBER nvarchar(128),          
     @EXPIRY datetime,          
     @PKD nvarchar(12),          
     @FREE Decimal(18,6)=0,          
     @OpeningDate datetime = Null,          
     @BackDatedTransaction int = 0,@TaxSuff Decimal(18,6) = 0,          
     @TaxID Int = Null,    
     @Vat_locality Int=0,    
     @DocType Int=Null,           
     @PURCHASEPRICE Decimal(18,6) = 0)  
AS          
DECLARE @PURCHASE_PRICE Decimal(18,6)          
DECLARE @PKD_DATE datetime          
DECLARE @PKD_TRACKED int          
DECLARE @BATCHCODE int          
DECLARE @DIFF Decimal(18,6)          
DECLARE @GRNAPPLICABLEON int        
DECLARE @GRNPARTOFF Decimal(18,6)        
DECLARE @APPLICABLEON int        
Declare @PARTOFF Decimal(18,6)                   
DECLARE @PRICEOPTION int  
DECLARE @IS_VAT_ITEM int  
  
If @TaxSuff > 0           
Begin          
 If Not exists(Select * from Tax Where (case When Percentage = @TaxSuff then 1 When CST_Percentage = @TaxSuff Then 1 Else 0 End) = 1)          
  Set @TaxSuff = 0          
End          
        
If @GRNID>0 AND @Vat_locality=0 --IF this proc is Called From GRN
	Select TOP 1 @Vat_locality = Locality from Vendors where VendorID in (Select VendorID from GRNAbstract where GRNID=@GRNID)

If @Vat_locality=1		--LST
	SELECT @APPLICABLEON = LstApplicableOn, @PARTOFF = LstPartOff from Tax where Tax_Code= @TaxId      
Else If @Vat_locality=2 --CST
	SELECT @APPLICABLEON = CstApplicableOn, @PARTOFF = CstPartOff from Tax where Tax_Code= @TaxId      

If @GRNID> 0   
Begin      
	Select @GRNAPPLICABLEON = @APPLICABLEON
	Select @GRNPARTOFF = @PARTOFF
End  

SET @BATCH_NUMBER = Replace(@BATCH_NUMBER, CHAR(9), N',')          
--Newly added for purchase price updation  
select @PRICEOPTION = Price_Option, @PKD_TRACKED = TrackPKD from items, itemcategories Where Items.CategoryID = Itemcategories.CategoryID and Items.Product_Code = @PRODUCT_CODE    
If @PRICEOPTION = 1   
 SET @PURCHASE_PRICE = @PURCHASEPRICE   
Else  
 SELECT @PURCHASE_PRICE = Purchase_Price, @PKD_TRACKED = TrackPKD FROM Items WHERE Product_Code = @PRODUCT_CODE          
IF @PKD_TRACKED = 1          
BEGIN          
SET @PKD_DATE = N'1/' + substring(@PKD, 1, 2) + N'/' + substring(@PKD, 4, 4)          
IF ISNULL(@BATCH_NUMBER, N'') = N'' SET @BATCH_NUMBER = @PKD          
END          
ELSE          
 SET @PKD_DATE = Null          
          
IF @BackDatedTransaction = 1           
BEGIN          
SET @DIFF = @QUANTITY          
exec sp_update_opening_stock @PRODUCT_CODE, @OpeningDate, @DIFF, 0, @PURCHASE_PRICE          
END          
INSERT INTO Batch_Products(Batch_Number,          
      Product_Code,          
      GRN_ID,          
      Expiry,          
      Quantity,          
      SalePrice,          
      PurchasePrice,          
      QuantityReceived,          
      PKD,          
      Free,TaxSuffered , GRNTaxSuffered, GRNTaxID, GrnApplicableOn, GrnPartOff,  
      ApplicableOn, PartOfPercentage, Vat_locality, DocType)          
VALUES (@BATCH_NUMBER,          
  @PRODUCT_CODE,          
  @GRNID,          
  @EXPIRY,          
  @QUANTITY,          
  @SALE_PRICE,          
  @PURCHASE_PRICE,          
  @QUANTITY,          
  @PKD_DATE,          
  0,@TaxSuff , @TaxSuff, @TaxID, @GRNAPPLICABLEON, @GRNPARTOFF,  
  @ApplicableOn, @PartOff, @Vat_locality,@DocType)          
Select @BATCHCODE = @@IDENTITY          
If @FREE > 0           
Begin          
INSERT INTO Batch_Products(Batch_Number,          
      Product_Code,          
      GRN_ID,          
      Expiry,          
      Quantity,          
      SalePrice,  
      PurchasePrice,          
      QuantityReceived,          
      PKD,          
      Free,     
      BatchReference,TaxSuffered,GRNTaxSuffered,GRNTaxID,GRNApplicableOn,GRNPartOff,   
    ApplicableOn, PartOfPercentage,Vat_locality, DocType)          
VALUES (@BATCH_NUMBER,          
  @PRODUCT_CODE,          
  @GRNID,          
  @EXPIRY,          
  @FREE,          
  0,          
  0,          
  @FREE,          
  @PKD_DATE,          
  1,          
  @BATCHCODE,@TaxSuff,@TaxSuff,@TaxID,@GRNAPPLICABLEON,@GRNPARTOFF,  
  @ApplicableOn, @PartOff,@Vat_locality,@DocType)          
IF @BackDatedTransaction = 1           
BEGIN          
SET @DIFF = @FREE          
exec sp_update_opening_stock @PRODUCT_CODE, @OpeningDate, @DIFF, 1, 0          
END          
End          
If @GRNID>0 --IF this proc is Called From GRN
Begin
	--Updating TaxSuff Percentage in OpeningDetails
	Select @IS_VAT_ITEM = IsNull(Vat,0) from Items Where Product_Code=@Product_Code
	If @Vat_Locality = 2 AND @IS_VAT_ITEM = 1
		Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @OpeningDate, @Product_Code, @BatchCode, 0, 1
	Else
		Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @OpeningDate, @Product_Code, @BatchCode
End

declare @track_csp int
select @track_csp = price_option from itemcategories, items 
where itemcategories.categoryid = items.categoryid
and items.product_code = @product_Code
if @track_csp = 1 

begin
	update items set sale_price = @sale_price, purchase_price = @purchase_price  where items.product_code = @product_Code
end

else
-- For NONCSP items prices is updated in batch_product
Begin
	UPDATE Batch_Products SET SalePrice = IT.SALE_PRICE
	From Batch_Products BP,Items IT WHERE BP.Product_Code = It.Product_code
	and BP.Product_code = @Product_code And isnull(free,0) <> 1
End

Select @BATCHCODE          



