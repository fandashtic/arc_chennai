CREATE PROCEDURE sp_insert_grnbatch_FMCG_MUOM(@GRNID int,             
     @PRODUCT_CODE nvarchar(15),               
     @QUANTITY Decimal(18,6),              
     @SALE_PRICE Decimal(18,6),              
     @BATCH_NUMBER nvarchar(128),              
     @EXPIRY datetime,              
     @PKD nvarchar(12),              
     @FREE decimal(18,6)=0,              
     @OpeningDate datetime = Null,              
     @BackDatedTransaction int = 0,            
     @UOM int=0,            
     @UOMQty Decimal(18,6)=0,            
     @UOMPrice Decimal(18,6)=0,@TaxSuff Decimal(18,6) = 0,        
     @TaxID Int = NULL,  
     @PURCHASEPRICE Decimal(18,6) = 0,  
	 @Vat_Locality Int=0,  
     @DocType Int=Null)    
AS              
DECLARE @PURCHASE_PRICE Decimal(18,6)              
DECLARE @PKD_DATE datetime              
DECLARE @PKD_TRACKED int              
DECLARE @BATCHCODE int              
DECLARE @DIFF Decimal(18,6)              
DECLARE @ConvFactor int              
DECLARE @FreeUOMQty Decimal(18,6)        
DECLARE @GRNAPPLICABLEON int      
DECLARE @GRNPARTOFF Decimal(18,6)      
DECLARE @APPLICABLEON int      
DECLARE @PARTOFF Decimal(18,6)      
DECLARE @PRICEOPTION int    
DECLARE @IS_VAT_ITEM Int  
      
If @TaxSuff > 0         
Begin        
 If Not exists(Select * from Tax Where (case When Percentage = @TaxSuff then 1 When CST_Percentage = @TaxSuff Then 1 Else 0 End) = 1)        
  Set @TaxSuff = 0        
End        
  
If @GRNID>0 AND @Vat_locality=0 --IF this proc is Called From GRN  
 Select TOP 1 @Vat_locality = Locality from Vendors where VendorID in (Select VendorID from GRNAbstract where GRNID=@GRNID)  
  
If @Vat_locality=1  --LST  
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
 SET @UOMPrice = @PURCHASE_PRICE * (@QUANTITY / @UOMQty)               
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
      Free,            
      UOM,            
      UOMQty,            
      UOMPrice,TaxSuffered,GRNTaxSuffered, GRNTaxID, GRNApplicableOn, GRNPartOff,  
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
  0,            
  @UOM,            
  @UOMQty,            
  @UOMPrice,@TaxSuff,@TaxSuff,@TaxID,@GRNAPPLICABLEON,@GRNPARTOFF,  
  @APPLICABLEON, @PARTOFF, @Vat_Locality, @DocType)   
Select @BATCHCODE = @@IDENTITY              
If @FREE > 0           
Begin              
Select @FreeUOMQty = (Case @UOM          
When Items.UOM1 Then          
 @FREE / Items.UOM1_Conversion          
When Items.UOM2 Then          
 @FREE / Items.UOM2_Conversion          
Else          
 @FREE          
End)          
From Items Where Product_Code = @PRODUCT_CODE          
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
      BatchReference,            
      UOM,            
      UOMQty,            
      UOMPRice,TaxSuffered,GRNTaxSuffered,GRNTaxID,GRNApplicableOn,GRNPartOff,   
  ApplicableOn, PartOfPercentage, Vat_locality, DocType)              
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
  @BATCHCODE,            
  @UOM,            
  @FreeUOMQty,        
  0,@TaxSuff,@TaxSuff,@TaxID,@GRNAPPLICABLEON,@GRNPARTOFF,   
  @APPLICABLEON, @PARTOFF, @Vat_Locality, @DocType)   
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
begin  
 Update Batch_Products set SalePrice = (Select Sale_Price from items where Product_code like @product_code )Where   
 Product_code = @Product_Code And isnull(free,0) <> 1  
end  
  
Select @BATCHCODE              
  

