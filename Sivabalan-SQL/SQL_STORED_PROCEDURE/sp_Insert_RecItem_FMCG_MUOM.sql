CREATE Procedure sp_Insert_RecItem_FMCG_MUOM (@ItemID Int,  
        @CategoryID Int,  
        @MfrID Int,  
        @BrandID Int,  
        @SUOM Int,  
        @RUOM Int,  
        @ConversionUnit Int,  
        @STax Decimal(18,6),  
        @PTax Decimal(18,6),
	@UOM1 Int,
	@UOM2 Int,
	@CaseUOM Int = 0,
	@CaseConversion Decimal(18,6) =0 )  
As  
Declare @ForumCode nvarchar(255)  
Declare @ItemCode nvarchar(255)  
Declare @ItemName nvarchar(255)  
Declare @ItemDesc nvarchar(255)  
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
Declare @SoldAs nvarchar(255)  
Declare @ItemPropCount Int  
Declare @PropertyID Int  
Declare @PropertyValue nvarchar(255)  
Declare @Active Int  
Declare @UOM1_Conversion Int
Declare @UOM2_Conversion Int
Declare @DefaultUOM Int
Declare @Hyperlink nvarchar(256)
Declare @VAT Int
Declare @COLLECTTAXSUFFERED Int
  
Select @ForumCode = ForumCode, @ItemCode = Product_Code, @ItemName = ProductName,  
@ItemDesc= Description, @PurchasePrice = PurchasePrice, @SalePrice = SalePrice,  
@MRP = MRP, @StockNorm = StockNorm, @MOQ = MinOrderQty, @TrackBatches = Track_Batches,  
@ConversionFactor = ConversionFactor, @SaleID = SaleID,   
@ReportingUnit = ReportingUnit, @TrackPKD = TrackPKD,   
@VirtualTrackBatches = Virtual_Track_Batches, @SoldAs = SoldAs,   
@ItemPropCount = ItemPropCount, @Active = Active  ,
@UOM1_Conversion = UOM1_Conversion,
@UOM2_Conversion = UOM2_Conversion,
@DefaultUOM = DefaultUOM, @HyperLink = Hyperlink, 
@VAT = IsNull(VAT,0), @COLLECTTAXSUFFERED = IsNull(COLLECTTAXSUFFERED,0) 
From ItemsReceivedDetail  
Where ID = @ItemID  
  
Insert Into Items (Product_Code, ProductName, Description, CategoryID, ManufacturerID,   
BrandID, UOM, Purchase_Price, Sale_Price, Sale_Tax, MRP, StockNorm, MinOrderQty,   
Track_Batches, ConversionFactor, ConversionUnit, Active, SaleID, TaxSuffered, SoldAs, Alias,   
ReportingUOM, ReportingUnit, TrackPKD, Virtual_Track_Batches, 
UOM1, UOM2, UOM1_Conversion, UOM2_Conversion, DefaultUOM, Hyperlink, VAT, COLLECTTAXSUFFERED, Case_UOM, Case_Conversion)  
Values(@ItemCode, @ItemName, @ItemDesc, @CategoryID, @MfrID, @BrandID, @SUOM,   
@PurchasePrice, @SalePrice, @STax, @MRP, @StockNorm, @MOQ, @TrackBatches,   
@ConversionFactor, @ConversionUnit, @Active, @SaleID, @PTax, @SoldAs, @ForumCode, @RUOM,   
@ReportingUnit, @TrackPKD, @VirtualTrackBatches,
@UOM1, @UOM2, @UOM1_Conversion, @UOM2_Conversion, @DefaultUOM, @Hyperlink, @VAT, @COLLECTTAXSUFFERED, @CaseUOM, @CaseConversion)  



