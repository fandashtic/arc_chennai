Create Procedure sp_Insert_RecItem_MUOM(@ItemID Int,
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
@CaseUOM Int= 0,
@CaseConversion Decimal(18,6) = 0)
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
Declare @StockistMargin Decimal(18,6)
Declare @RetailerMargin Decimal(18,6)
Declare @CompanyMargin Decimal(18,6)
Declare @ReportingUnit Decimal(18,6)
Declare @TrackPKD Int
Declare @VirtualTrackBatches Int
Declare @SoldAs nvarchar(255)
Declare @PTS Decimal(18,6)
Declare @PTR Decimal(18,6)
Declare @ECP Decimal(18,6)
Declare @CompanyPrice Decimal(18,6)
Declare @PurchasedAt Int
Declare @ItemPropCount Int
Declare @PropertyID Int
Declare @PropertyValue nvarchar(255)
Declare @Active Int
Declare @UOM1_Conversion Decimal(18,6)
Declare @UOM2_Conversion Decimal(18,6)
Declare @DefaultUOM Int
Declare @Hyperlink nvarchar(256)
Declare @VAT Int
Declare @COLLECTTAXSUFFERED Int
Declare @AdhocAmount Decimal(18,6)
Declare @Taxinclusive int
Declare @TaxinclusiveRate Decimal(18,6)
Declare @Ean_Number nvarchar(50)
Declare @MRP_Per_Pack Decimal(18,6)
Declare @ASL int
Declare @TOQ_Purchase int

Declare @TOQ_Sales int
Declare @HSNNumber nvarchar(15)
Declare @CategorizationID int
Declare @CategorizationName nvarchar(255)
Declare @GSTEnable Int
Declare @FreeSKUFlag int

Select @GSTEnable = Isnull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'

Select @ForumCode = ForumCode, @ItemCode = Product_Code, @ItemName = ProductName,
@ItemDesc= Description, @PurchasePrice = PurchasePrice, @SalePrice = SalePrice,
@MRP = MRP, @StockNorm = StockNorm, @MOQ = MinOrderQty, @TrackBatches = Track_Batches,
@ConversionFactor = ConversionFactor, @SaleID = SaleID, @StockistMargin = StockistMargin,
@RetailerMargin = RetailerMargin, @CompanyMargin = CompanyMargin,
@ReportingUnit = ReportingUnit, @TrackPKD = TrackPKD,
@VirtualTrackBatches = Virtual_Track_Batches, @SoldAs = SoldAs, @PTS = PTS, @PTR = PTR,
@ECP = ECP, @CompanyPrice = CompanyPrice, @PurchasedAt = PurchasedAt,
@ItemPropCount = ItemPropCount, @Active = Active ,
@UOM1_Conversion = UOM1_Conversion,
@UOM2_Conversion = UOM2_Conversion,
@DefaultUOM = DefaultUOM, @HyperLink = Hyperlink,
@VAT = IsNull(VAT,0), @COLLECTTAXSUFFERED = IsNull(COLLECTTAXSUFFERED,0),
@AdhocAmount = IsNull(AdhocAmount,0) ,
@Taxinclusive = isnull(Taxinclusive,0),
@TaxinclusiveRate = isnull(TaxinclusiveRate,0),
@Ean_Number = Isnull(Ean_Number, '') ,
@MRP_Per_Pack=isnull(MRPPerPack,0), @ASL = Isnull(ASL,0),@TOQ_Purchase=isnull(TOQ_Purchase,0),@TOQ_Sales=isnull(TOQ_Sales,0),
@HSNNumber = Isnull(HSNNumber, ''),
@CategorizationName   = isnull(CategorizationName,''), @FreeSKUFlag  = isnull(FreeSKUFlag,0)
From ItemsReceivedDetail
Where ID = @ItemID

set @CategorizationID = 0
select @CategorizationID = ID From ProductCategorization Where CategorizationName = @CategorizationName

If @GSTEnable <> 1
Insert Into Items (Product_Code, ProductName, Description, CategoryID, ManufacturerID,
BrandID, UOM, Purchase_Price, Sale_Price,
Sale_Tax,
MRP, StockNorm, MinOrderQty,
Track_Batches, ConversionFactor, ConversionUnit, Active, SaleID, Company_Price, PTS, PTR,
ECP, Purchased_At, Company_Margin, Stockist_Margin, Retailer_Margin,
TaxSuffered,
SoldAs, Alias, ReportingUOM, ReportingUnit, TrackPKD, Virtual_Track_Batches,
UOM1, UOM2, UOM1_Conversion, UOM2_Conversion, DefaultUOM, Hyperlink, VAT, COLLECTTAXSUFFERED,
AdhocAmount,Taxinclusive,TaxinclusiveRate, Case_Uom, Case_Conversion, Ean_Number,MRPPerPack,ASL,TOQ_Purchase,TOQ_Sales,HSNNumber,CategorizationID,
FreeSKUFlag)
Values(@ItemCode, @ItemName, @ItemDesc, @CategoryID, @MfrID, @BrandID, @SUOM,
@PurchasePrice, @SalePrice,
@STax,
@MRP, @StockNorm, @MOQ, @TrackBatches, @ConversionFactor,
@ConversionUnit, @Active, @SaleID, @CompanyPrice, @PTS, @PTR, @ECP, @PurchasedAt, @CompanyMargin,
@StockistMargin, @RetailerMargin,
@PTax,
@SoldAs, @ForumCode, @RUOM, @ReportingUnit,
@TrackPKD, @VirtualTrackBatches,
@UOM1, @UOM2, @UOM1_Conversion, @UOM2_Conversion, @DefaultUOM, @Hyperlink, @VAT, @COLLECTTAXSUFFERED,
@AdhocAmount,@Taxinclusive,@TaxinclusiveRate, @CaseUOM, @CaseConversion, @Ean_Number,@MRP_Per_Pack,@ASL,@TOQ_Purchase,@TOQ_Sales,@HSNNumber,@CategorizationID,
@FreeSKUFlag)
Else
Insert Into Items (Product_Code, ProductName, Description, CategoryID, ManufacturerID,
BrandID, UOM, Purchase_Price, Sale_Price,
--Sale_Tax,
MRP, StockNorm, MinOrderQty,
Track_Batches, ConversionFactor, ConversionUnit, Active, SaleID, Company_Price, PTS, PTR,
ECP, Purchased_At, Company_Margin, Stockist_Margin, Retailer_Margin,
--TaxSuffered,
SoldAs, Alias, ReportingUOM, ReportingUnit, TrackPKD, Virtual_Track_Batches,
UOM1, UOM2, UOM1_Conversion, UOM2_Conversion, DefaultUOM, Hyperlink, VAT, COLLECTTAXSUFFERED,
AdhocAmount,Taxinclusive,TaxinclusiveRate, Case_Uom, Case_Conversion, Ean_Number,MRPPerPack,ASL,TOQ_Purchase,TOQ_Sales,HSNNumber,CategorizationID,
FreeSKUFlag)
Values(@ItemCode, @ItemName, @ItemDesc, @CategoryID, @MfrID, @BrandID, @SUOM,
@PurchasePrice, @SalePrice,
--@STax,
@MRP, @StockNorm, @MOQ, @TrackBatches, @ConversionFactor,
@ConversionUnit, @Active, @SaleID, @CompanyPrice, @PTS, @PTR, @ECP, @PurchasedAt, @CompanyMargin,
@StockistMargin, @RetailerMargin,
--@PTax,
@SoldAs, @ForumCode, @RUOM, @ReportingUnit,
@TrackPKD, @VirtualTrackBatches,
@UOM1, @UOM2, @UOM1_Conversion, @UOM2_Conversion, @DefaultUOM, @Hyperlink, @VAT, @COLLECTTAXSUFFERED,
@AdhocAmount,@Taxinclusive,@TaxinclusiveRate, @CaseUOM, @CaseConversion, @Ean_Number,@MRP_Per_Pack,@ASL,@TOQ_Purchase,@TOQ_Sales,@HSNNumber,@CategorizationID,
@FreeSKUFlag)

Update BillDetail Set UOM=@SUOM where Product_Code=@ItemCode and isnull(Missing,0)=1

Update InvoiceDetailReceived set Product_Code=@ItemCode,UOM=@SUOM
where (Product_Code='' or Product_Code is NULL) and ForumCode=@ForumCode
