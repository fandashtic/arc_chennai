CREATE PROCEDURE sp_update_ImportItem_FMCG (@Product_Code nvarchar(30),         
 @ProductName nvarchar(2000),         
 @Description nvarchar(2000),         
 @CategoryID int,         
 @ManufacturerID nvarchar(15),        
 @BrandID int,        
 @UOM int,         
 @Purchase_Price Decimal(18,6),       
 @Sale_Tax Decimal(18,6),         
 @MRP Decimal(18,6),         
 @Preferred_Vendor nvarchar(15),         
 @StockNorm Decimal(18,6),         
 @MinOrderQty Decimal(18,6),         
 @ConversionFactor Decimal(18,6),         
 @ConversionUnit int,         
 @SaleID int,         
 @Sale_Price Decimal(18,6),         
 @TaxSuffered Decimal(18,6),         
 @SoldAS  nvarchar(50),           
 @ReportingUOM Decimal(18,6),         
 @ReportingUnit Decimal(18,6),         
 @TrackPKD int,         
 @Track_Batches int,          
 @Virtual_Track_Batches int,         
 @Alias nvarchar(30),    
 @TaxInclusive Decimal(18,6) = 0,    
 @TaxInclusiveRate Decimal(18,6) = 0,    
 @Hyperlink nvarchar(256) = N'',    
 @AdhocAmount Decimal(18,6) = 0,  
 @Vat int=0,  
 @CollectTaxSuffered int=0,
 @CaseUOM Int=0,
 @CaseConversion Decimal(18,6)=0, 
 @UserDefinedcode nVarchar(256)=N'')      
AS          
 Declare @ORIG_ALIAS nvarchar(30)          
 Declare @priceOption int
      
 UPDATE Items SET ProductName = @ProductName,      
   Description = @Description,          
   CategoryID = @CategoryID,          
   ManufacturerID = @ManufacturerID,          
   BrandID = @BrandID,          
   UOM = @UOM,          
   Purchase_Price = @Purchase_Price,          
   Sale_Price = @Sale_Price,          
   Sale_Tax = @Sale_Tax,          
   MRP = @MRP,          
   Preferred_Vendor = @Preferred_Vendor,          
   StockNorm = @StockNorm,          
   MinOrderQty = @MinOrderQty,          
   Track_Batches = @Track_Batches,          
   ConversionFactor = @ConversionFactor,          
   ConversionUnit = @ConversionUnit,          
   SaleID = @SaleID,          
   TaxSuffered = @TaxSuffered,          
   SoldAs = @SoldAS,          
   Alias = @Alias,          
   ReportingUOM = @ReportingUOM,          
   ReportingUnit = @ReportingUnit,          
   TrackPKD = @TrackPKD,          
   Virtual_Track_Batches = @Virtual_Track_Batches,          
   ModifiedDate = GetDate(),    
   TaxInclusive = @TaxInclusive,    
   TaxInclusiveRate = @TaxInclusiveRate,    
   Hyperlink = @Hyperlink,    
   AdhocAmount = @AdhocAmount,  
   Vat = @Vat,  
   CollectTaxSuffered = @CollectTaxSuffered,
   Case_UOM = @CaseUOM,
   Case_Conversion = @CaseConversion,
   UserDefinedCode = @UserDefinedCode
 WHERE Product_Code = @Product_Code          
      
select @priceOption = IsNull(ItemCategories.price_option, 0) 
from items, ItemCategories 
where items.CategoryId = ItemCategories.CategoryId 
And items.Product_Code = @Product_Code
If @PriceOption = 0
Begin
	Update batch_products set SalePrice = @Sale_Price 
        Where Product_code = @Product_Code And isnull(free,0) <> 1
End 
  
SELECT @ORIG_ALIAS = IsNull(Alias,N'') From Items Where Product_Code = @Product_Code       
IF @ORIG_ALIAS <> @Alias          
BEGIN          
Update StockTransferOutDetailReceived Set Product_Code = @Product_Code          
Where ForumCode = @Alias          
Update stock_request_detail_received Set Product_Code = @Product_Code          
Where ForumCode = @Alias          
END          


