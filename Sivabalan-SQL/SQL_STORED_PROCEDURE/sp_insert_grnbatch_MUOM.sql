Create PROCEDURE sp_insert_grnbatch_MUOM(@GRNID int,           
     @PRODUCT_CODE nvarchar(15),           
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
     @FREE decimal(18,6)=0,          
     @OpeningDate datetime = Null,          
     @BackDatedTransaction int = 0,          
     @UOM int = 0,          
     @UOMQty Decimal(18,6) = 0,          
     @UOMPrice Decimal(18,6) = 0,@TaxSuff Decimal(18,6) = 0,          
     @TaxID Int = Null,     
     @Vat_Locality Int=0,     
     @DocType Int=Null,  
     @ItemOrder Int = 0,@OrgPTS Decimal(18,6) = 0, @TaxType Int = 1, @PFM Decimal(18,6),@MRPForTax Decimal(18,6),@MRPPerPack Decimal(18,6),@TOQ int
     ,@GSTFlag Int , @MarginDetID Int = 0, @MarginPerc Decimal(18,6) = 0, @MarginOn Decimal(18,6) = 0, @MarginAddOn Decimal(18,6) = 0
     )     
AS  
DECLARE @PURCHASE_PRICE Decimal(18,6)          
DECLARE @PKD_DATE datetime          
DECLARE @PKD_TRACKED int          
DECLARE @BATCHCODE int          
DECLARE @DIFF Decimal(18,6)          
DECLARE @FreeUOMQty Decimal(18,6)          
DECLARE @GRNAPPLICABLEON int        
DECLARE @GRNPARTOFF Decimal(18,6)        
DECLARE @APPLICABLEON int        
DECLARE @PARTOFF Decimal(18,6)        
DECLARE @IS_VAT_ITEM int        
declare @convert Decimal(18,6)    
Declare @GSTTaxType Int

If @TaxSuff > 0           
Begin          
 If Not exists(Select * from Tax Where (case When Percentage = @TaxSuff then 1 When CST_Percentage = @TaxSuff Then 1 Else 0 End) = 1)          
  Set @TaxSuff = 0          
End          
        
If @GRNID>0 AND @Vat_locality=0 --IF this proc is Called From GRN    
 Select TOP 1 @Vat_locality = Locality from Vendors where VendorID in (Select VendorID from GRNAbstract where GRNID=@GRNID)    
    
/*
If @Vat_locality=1  --LST    
 SELECT @APPLICABLEON = LstApplicableOn, @PARTOFF = LstPartOff from Tax where Tax_Code= @TaxId          
Else If @Vat_locality=2 --CST    
 SELECT @APPLICABLEON = CstApplicableOn, @PARTOFF = CstPartOff from Tax where Tax_Code= @TaxId          
*/

IF @TaxType = 2 /*CST*/
  SELECT @APPLICABLEON = CstApplicableOn, @PARTOFF = CstPartOff from Tax where Tax_Code= @TaxId          
Else    /* LST OR FLST */
  SELECT @APPLICABLEON = LstApplicableOn, @PARTOFF = LstPartOff from Tax where Tax_Code= @TaxId          
  
If @GRNID> 0       
Begin          
 Select @GRNAPPLICABLEON = @APPLICABLEON    
 Select @GRNPARTOFF = @PARTOFF    
End      

Set  @GSTTaxType = 0
If IsNull(@GSTFlag,0) = 1 
Begin
	Set @GSTTaxType = @TaxType
	Set @TaxType = 5
End
    
SET @BATCH_NUMBER = Replace(@BATCH_NUMBER, CHAR(9), N',')          
IF @PRICEOPTION = 0          
 SELECT @PURCHASE_PRICE = Purchase_Price, @PKD_TRACKED = TrackPKD FROM Items WHERE Product_Code = @PRODUCT_CODE          
ELSE          
 SELECT   
@PURCHASE_PRICE = Case Purchased_At WHEN 1 THEN @PTS WHEN 2 THEN @PTR ELSE Items.Purchase_Price END,  
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
      
If @UOMQty <> 0           
 SET @UOMPrice = @PURCHASE_PRICE * (@QUANTITY / @UOMQty)          
 Else          
begin    
 If @Free > 0      
 begin    
  --if there is no saleble qty, uomprice should be updated in the    
  --dummy batch.    
  select @convert = (case when @uom = uom then 1    
    when @uom = Uom1 then UOM1_Conversion     
    when @uom = Uom2 then UOM2_Conversion end)     
  from items    
  where Product_Code = @PRODUCT_CODE       
  set @UOMprice = @PURCHASE_PRICE * @convert    
 end    
 else    
  SET @UOMPrice = 0          
end     
IF @QUANTITY > 0  
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
      UOM,          
      UOMQty,          
      UOMPrice,TaxSuffered,GRNTaxSuffered,GRNTaxID,GRNApplicableOn,GrnPartOff,     
      ApplicableOn, PartOfPercentage, Vat_locality, DocType, ReceInvItemOrder,OrgPTS,TaxType, PFM,MRPForTax, MRPPerPack,TOQ,GSTTaxType
      , MarginDetID, MarginPerc, MarginOn, MarginAddOn)                
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
  @QUANTITY,0,          
--  @SPECIAL_PRICE,        -- ITC Not req this price  
  @PKD_DATE,          
  0,          
  @UOM,          
  @UOMQty,          
  @UOMPrice,@TaxSuff,@TaxSuff,@TaxID,@GRNAPPLICABLEON,@GRNPARTOFF,     
  @APPLICABLEON, @PARTOFF, @Vat_Locality, @DocType, @ItemOrder,@OrgPTS,@TaxType,@PFM,@MRPForTax,@MRPPerPack,@TOQ,@GSTTaxType
  ,@MarginDetID, @MarginPerc, @MarginOn, @MarginAddOn)     
Select @BATCHCODE = @@IDENTITY     
End       
IF @BackDatedTransaction = 1           
BEGIN          
	SET @DIFF = @QUANTITY          
	exec sp_update_opening_stock @PRODUCT_CODE, @OpeningDate, @DIFF, 0, @PURCHASE_PRICE, 0, 0, @BATCHCODE
END
If @Free > 0           
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
      PTS,          
      PTR,          
      ECP,          
      PurchasePrice,          
      QuantityReceived,          
      Company_Price,          
      PKD,           
      Free,          
      BatchReference,          
      UOM,            UOMQty,          
      UOMPrice,TaxSuffered,GRNTaxSuffered,GRNTaxID,GRNApplicableOn,GRNPartOff,     
  ApplicableOn, PartOfPercentage, Vat_locality, DocType, ReceInvItemOrder,OrgPTS,TaxType,PFM,MRPForTax,MRPPerPack,TOQ,GSTTaxType)     
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
  @BATCHCODE,          
  @UOM,          
  @FreeUOMQty,          
  0,@TaxSuff , @TaxSuff,@TaxID,@GRNAPPLICABLEON,@GRNPARTOFF,     
--  @APPLICABLEON, @PARTOFF, @Vat_Locality, @DocType, @ItemOrder,@OrgPTS,@TaxType,@PFM,@MRPForTax,@MRPPerPack)     
  @APPLICABLEON, @PARTOFF, @Vat_Locality, @DocType, @ItemOrder,@OrgPTS,@TaxType,@PFM,@MRPForTax,0,@TOQ,@GSTTaxType)     	
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
from itemcategories, items  where itemcategories.categoryid = items.categoryid    
and items.product_code = @product_Code    
    
if @track_csp = 1     
 begin    
  IF @PURCHASED_AT = 1     
   BEGIN    
    update items set sale_price = @PTS, purchase_price = @purchase_price,    
          PTS=@PTS,PTR=@PTR,ECP=@ECP,company_price = 0,PFM=@PFM -- @Special_Price                      -- ITC Not req this price  
			, MRPPerPack = @MRPPerPack
          where items.product_code = @product_Code and @FREE=0    
   END    
  ELSE    
   BEGIN    
    update items set sale_price = @PTR, purchase_price = @purchase_price,    
          PTS=@PTS,PTR=@PTR,ECP=@ECP,company_price = 0,PFM=@PFM -- @Special_Price                      -- ITC Not req this price  
			, MRPPerPack = @MRPPerPack
          where items.product_code = @product_Code and @FREE=0
   END    
 END    
else    
--For NonCSP items Price Updation in Batch_Products    
Begin    
 UPDATE Batch_Products SET SalePrice = Item.SALE_PRICE, PTS = Item.PTS,    
 PTR = Item.PTR,ECP = Item.ECP,Company_price=Item.Company_Price,PFM=Item.PFM,MRPForTax=@MRPForTax , MRPPerPack = Item.MRPPerPack ,TOQ=isnull(Item.TOQ_Purchase,0)  
 from Batch_Products Batch,Items Item    
 WHERE Batch.Product_Code = Item.PRODUCT_CODE and Batch.Product_Code = @PRODUCT_CODE     
 and  Isnull(Batch.[free],0) <> 1  
End    
--------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ Channel Wise PTR Calclulation--------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
If IsNull(@BATCHCODE,0) > 0
Begin
	Insert Into BatchWiseChannelPTR (Batch_Code, ChannelMarginID, ChannelTypeCode, RegisterStatus, ChannelPTR)
	Select @BATCHCODE ,ID , ChannelTypeCode , RegFlag, "ChannelPTR" = @MarginAddOn + @MarginOn * MarginPerc /100 
	From tbl_mERP_ChannelMarginDetail Where MarginDetID =  @MarginDetID
End
--------------------------------------------------------------------------------------------------------------------------------------------------------
    
SELECT @BATCHCODE      
