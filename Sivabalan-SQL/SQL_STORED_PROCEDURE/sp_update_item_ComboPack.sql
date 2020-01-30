CREATE PROCEDURE sp_update_item_ComboPack(@ITEM_CODE nvarchar(15),    
    @DESCRIPTION nvarchar(2000),    
    @CATEGORYID int,    
    @MANUFACTURERID nvarchar(15),    
    @BRANDID int,    
    @UOM int,    
    @PURCHASE_PRICE Decimal(18,6),    
    @SALE_PRICE Decimal(18,6),    
    @SALE_TAX Decimal(18,6),    
    @MRP Decimal(18,6),    
    @PREFERRED_VENDOR nvarchar(15),    
    @STOCK_NORM Decimal(18,6),    
    @MOQ Decimal(18,6),    
    @TRACK_BATCHES int,    
    @OPENING_STOCK Decimal(18,6),    
    @OPENING_STOCK_VALUE Decimal(18,6),    
    @SCHEMEID int,    
    @CONVERSION_FACTOR Decimal(18,6),    
    @CONVERSION_UNIT int,    
    @ACTIVE int,    
    @SALEID int,    
    @PURCHASED_AT int,    
    @COMPANY_PRICE Decimal(18,6),    
    @PTS Decimal(18,6),    
    @PTR Decimal(18,6),    
    @TAXSUFFERED Decimal(18,6),    
    @SOLDAS nvarchar(50),    
    @FORUMCODE nvarchar(20),    
    @REPORTINGUOM Decimal(18,6),    
    @REPORTINGUNITS Decimal(18,6),    
    @TRACKPKD int,    
    @VIRTUAL_TRACK_BATCHES int,    
    @WAREHOUSEID nvarchar(20),    
    @ITEMCOMBO int,    
    @TRACKINVENTORYCOMBO int,@AutoSC int=0,
    @HYPERLINK nvarchar(256) = N'',
    @EXCISEDUTY int = 0,  
    @ADHOCAMOUNT Decimal(18,6) = 0,
    @Vat Int=0,
    @CollectTaxSuffered Int=0
)    
AS    
DECLARE @ORIG_ALIAS nvarchar(15)  
Declare @PriceOption int  
SELECT @ORIG_ALIAS = IsNull(Alias,N'') From Items Where Product_Code = @ITEM_CODE    
IF @ORIG_ALIAS <> @FORUMCODE    
BEGIN    
Update StockTransferOutDetailReceived Set Product_Code = @ITEM_CODE    
Where ForumCode = @FORUMCODE    
Update stock_request_detail_received Set Product_Code = @ITEM_CODE    
Where ForumCode = @FORUMCODE    
if(@AutoSC=1)
update itemclosingstock set Item_ForumCode=@ForumCode where product_code=@Item_Code  
END    
UPDATE Items SET Description = @DESCRIPTION,    
   CategoryID = @CATEGORYID,    
   ManufacturerID = @MANUFACTURERID,    
   BrandID = @BRANDID,    
   UOM = @UOM,    
   Purchase_Price = @PURCHASE_PRICE,    
   Sale_Price = @SALE_PRICE,    
   Sale_Tax = @SALE_TAX,    
   MRP = @MRP,    
   Preferred_Vendor = @PREFERRED_VENDOR,    
   StockNorm = @STOCK_NORM,    
   MinOrderQty = @MOQ,    
   Track_Batches = @TRACK_BATCHES,    
   Opening_Stock = @OPENING_STOCK,    
   Opening_Stock_Value = @OPENING_STOCK_VALUE,    
   SchemeID = @SCHEMEID,    
   ConversionFactor = @CONVERSION_FACTOR,    
   ConversionUnit = @CONVERSION_UNIT,    
   Active = @ACTIVE,    
   SaleID = @SALEID,    
   Purchased_At = @PURCHASED_AT,    
   Company_Price = @COMPANY_PRICE,    
   PTS = @PTS,    
   PTR = @PTR,    
   ECP = @SALE_PRICE,    
   TaxSuffered = @TAXSUFFERED,    
   SoldAs = @SOLDAS,    
   Alias = @FORUMCODE,    
   ReportingUOM = @REPORTINGUOM,    
   ReportingUnit = @REPORTINGUNITS,    
   TrackPKD = @TRACKPKD,    
   Virtual_Track_Batches = @VIRTUAL_TRACK_BATCHES,    
   SupplyingBranch = @WAREHOUSEID,    
   ModifiedDate = GetDate(),    
   ItemCombo = @ITEMCOMBO,    
   TrackInventoryCombo = @TRACKINVENTORYCOMBO,
   HyperLink = @HYPERLINK,
   EXCISEDUTY = @EXCISEDUTY,  
   ADHOCAMOUNT = @ADHOCAMOUNT,
   Vat = @Vat,
   CollectTaxSuffered = @CollectTaxSuffered
WHERE Product_Code = @ITEM_CODE    

--Updating Prices for NonCSP Items
select @priceOption=price_option from ItemCategories where CategoryId in( select categoryId from items where Product_code=@ITEM_CODE)
	If @PriceOption = 0
	Begin
	UPDATE Batch_Products SET               
	   SalePrice = @SALE_PRICE,                  
	   Company_Price = @COMPANY_PRICE,                  
	   PTS = @PTS,                  
	   PTR = @PTR,                  
	   ECP = @SALE_PRICE                 
	WHERE Product_Code = @ITEM_CODE  and IsNull([free],0) <>1      
	End





