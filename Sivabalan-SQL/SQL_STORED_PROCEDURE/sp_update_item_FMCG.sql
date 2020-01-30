
Create PROCEDURE sp_update_item_FMCG(@ITEM_CODE nvarchar(15),              
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
    @TAXSUFFERED Decimal(18,6),              
    @SOLDAS nvarchar(50),              
    @FORUMCODE nvarchar(20),              
    @REPORTINGUOM int,              
    @REPORTINGUNITS Decimal(18,6),              
    @TRACKPKD int,              
    @VIRTUAL_TRACK_BATCHES int,              
    @WAREHOUSEID nVarchar(20),              
    @TAXINCLUSIVE Decimal(18,6) = 0,              
    @TAXINCLUSIVERATE Decimal(18,6) = 0,              
    @HYPERLINK nVarchar(256) = N'',              
    @EXCISEDUTY int = 0,              
    @ADHOCAMOUNT Decimal(18,6) = 0,          
    @Vat Int = 0,          
    @CollectTaxSuffered Int = 0,    
    @UserDefinedCode nvarchar(255) = Null,
    @CASEUOM Int =0 , 
    @CASECONVERSION Decimal (18,6)= 0 
)              
AS              
DECLARE @ORIG_ALIAS nvarchar(15)              
Declare @priceOption int    
    
SELECT @ORIG_ALIAS = IsNull(Alias,N'') From Items Where Product_Code = @ITEM_CODE              
IF @ORIG_ALIAS <> @FORUMCODE              
BEGIN              
Update StockTransferOutDetailReceived Set Product_Code = @ITEM_CODE              
Where ForumCode = @FORUMCODE              
Update stock_request_detail_received Set Product_Code = @ITEM_CODE              
Where ForumCode = @FORUMCODE              
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
   TaxSuffered = @TAXSUFFERED,              
   SoldAs = @SOLDAS,              
   Alias = @FORUMCODE,              
   ReportingUOM = @REPORTINGUOM,              
   ReportingUnit = @REPORTINGUNITS,              
   TrackPKD = @TRACKPKD,              
   Virtual_Track_Batches = @VIRTUAL_TRACK_BATCHES,              
   SupplyingBranch = @WAREHOUSEID,              
   ModifiedDate = GetDate(),              
   TaxInclusive = @TAXINCLUSIVE,              
   TAXINCLUSIVERATE = @TAXINCLUSIVERATE,              
   HYPERLINK = @HYPERLINK,              
   EXCISEDUTY = @EXCISEDUTY ,              
   ADHOCAMOUNT = @ADHOCAMOUNT,          
   Vat = @Vat,          
   CollectTaxSuffered = @CollectTaxSuffered,    
   UserDefinedCode = @UserDefinedCode,
   Case_UOM = @CASEUOM, Case_Conversion = @CASECONVERSION     
WHERE Product_Code = @ITEM_CODE              
              
select @priceOption = IsNull(ItemCategories.price_option, 0)     
from items, ItemCategories     
where items.CategoryId = ItemCategories.CategoryId     
And items.Product_Code = @ITEM_CODE    
If @PriceOption = 0    
Begin    
 Update Batch_Products set SalePrice = @Sale_Price    
 Where Product_code = @Item_Code And isnull(free,0) <> 1    
End    

