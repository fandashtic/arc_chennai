CREATE Procedure sp_Update_RecItem_FMCG (@ItemID Int,  
        @CategoryID Int,  
        @MfrID Int,  
        @BrandID Int,  
        @SUOM Int,  
        @RUOM Int,  
        @ConversionUnit Int,  
        @STax Decimal(18,6),  
        @PTax Decimal(18,6),
        @CaseUOM Int = 0,
        @CaseConversion Decimal(18,6) = 0)  
As  
Declare @ForumCode nVarchar(255)  
Declare @ItemCode nVarchar(255)  
Declare @ItemName nVarchar(255)  
Declare @ItemDesc nVarchar(255)  
Declare @PurchasePrice Decimal(18,6)  
Declare @SalePrice Decimal(18,6)  
Declare @MRP Decimal(18,6)  
Declare @StockNorm Decimal(18,6)  
Declare @MOQ Decimal(18,6)  
Declare @TrackBatches Int  
Declare @ConversionFactor Decimal(18,6)  
Declare @SaleID Int  
Declare @ReportingUnit Decimal(18,6)  
Declare @TrackPKD Int  
Declare @VirtualTrackBatches Int  
Declare @SoldAs nVarchar(255)  
Declare @ItemPropCount Int  
Declare @PropertyID Int  
Declare @PropertyValue nVarchar(255)  
Declare @Active Int  
Declare @Hyperlink nvarchar(256)  
Declare @VAT Int  
Declare @COLLECTTAXSUFFERED Int  
Declare @priceOption int  
  
Select @ForumCode = ForumCode, @ItemCode = Product_Code, @ItemName = ProductName,  
@ItemDesc= Description, @PurchasePrice = PurchasePrice, @SalePrice = SalePrice,  
@MRP = MRP, @StockNorm = StockNorm, @MOQ = MinOrderQty, @TrackBatches = Track_Batches,  
@ConversionFactor = ConversionFactor, @SaleID = SaleID,   
@ReportingUnit = ReportingUnit, @TrackPKD = TrackPKD,   
@VirtualTrackBatches = Virtual_Track_Batches, @SoldAs = SoldAs,   
@ItemPropCount = ItemPropCount, @Active = Active, @HyperLink = Hyperlink,   
@VAT = IsNull(VAT,0), @COLLECTTAXSUFFERED = IsNull(COLLECTTAXSUFFERED,0)
From ItemsReceivedDetail  
Where ID = @ItemID  
  
if Not Exists(Select Product_Code from Items Where Product_Code <> @ItemCode and Alias =  
 @FORUMCODE)  
Begin  
  
Set @VirtualTrackBatches = @TrackBatches  
If @TrackPKD = 1  
 Begin  
 Set @TrackBatches = 1  
 End  
  
Update Items Set  ProductName = @ItemName, Description = @ItemDesc, CategoryID = @CategoryID,  
ManufacturerID = @MfrID, BrandID = @BrandID, UOM = @SUOM, Purchase_Price = @PurchasePrice,   
Sale_Price = @SalePrice, Sale_Tax = @STax, MRP = @MRP, StockNorm = @StockNorm,   
MinOrderQty = @MOQ, Track_Batches = @TrackBatches, ConversionFactor = @ConversionFactor,   
ConversionUnit = @ConversionUnit, Active = @Active, SaleID = @SaleID, TaxSuffered = @PTax,   
SoldAs = @SoldAs, Alias = @ForumCode, ReportingUOM = @RUOM, ReportingUnit = @ReportingUnit,   
TrackPKD = @TrackPKD, Virtual_Track_Batches = @VirtualTrackBatches, Hyperlink = @Hyperlink,   
VAT = @VAT, COLLECTTAXSUFFERED = @COLLECTTAXSUFFERED,
Case_UOM = @CaseUOM, Case_Conversion = @CaseConversion
Where Product_Code = @ItemCode  

  
select @priceOption = IsNull(ItemCategories.price_option, 0) 
from items, ItemCategories 
where items.CategoryId = ItemCategories.CategoryId 
And items.Product_Code = @ITEMCODE
If @PriceOption = 0
Begin
	Update Batch_Products set SalePrice = @SalePrice Where 
	Product_code = @ItemCode And isnull(free,0) <> 1
End
 Select 1, @ForumCode, @ItemCode  
END  
  
Else  
 Select 0, @ForumCode, @ItemCode  



