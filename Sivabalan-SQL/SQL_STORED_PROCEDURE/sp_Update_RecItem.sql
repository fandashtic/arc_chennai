Create Procedure [dbo].[sp_Update_RecItem] (@ItemID Int,
				    @CategoryID Int,
				    @MfrID Int,
				    @BrandID Int,
				    @SUOM Int,
				    @RUOM Int,
				    @ConversionUnit Int,
				    @STax Decimal(18,6),
				    @PTax Decimal(18,6), 
				    @CUOM Int = 0,
				    @CaseConversion Decimal(18,6)= 0)
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
Declare @Hyperlink nvarchar(256)
Declare @VAT Int
Declare @COLLECTTAXSUFFERED Int
Declare @AdhocAmount Decimal(18,6)
Declare @PriceOption int

Select @ForumCode = ForumCode, @ItemCode = Product_Code, @ItemName = ProductName,
@ItemDesc= Description, @PurchasePrice = PurchasePrice, @SalePrice = SalePrice,
@MRP = MRP, @StockNorm = StockNorm, @MOQ = MinOrderQty, @TrackBatches = Track_Batches,
@ConversionFactor = ConversionFactor, @SaleID = SaleID, @StockistMargin = StockistMargin,
@RetailerMargin = RetailerMargin, @CompanyMargin = CompanyMargin, 
@ReportingUnit = ReportingUnit, @TrackPKD = TrackPKD, 
@VirtualTrackBatches = Virtual_Track_Batches, @SoldAs = SoldAs, @PTS = PTS, @PTR = PTR,
@ECP = ECP, @CompanyPrice = CompanyPrice, @PurchasedAt = PurchasedAt,
@ItemPropCount = ItemPropCount, @Active = Active, @HyperLink = Hyperlink, 
@VAT = IsNull(VAT,0), @COLLECTTAXSUFFERED = IsNull(COLLECTTAXSUFFERED,0), 
@AdhocAmount = IsNull(AdhocAmount,0)
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

-- Stcok verification for DeActive item in Batch_products and van
If @ACTIVE = 0
Begin
Declare @Quantity decimal(18,6)
Declare @VanQuantity decimal(18,6)
Select @Quantity = Sum(Quantity) from Batch_Products Where Product_Code = @ItemCode
Select @VanQuantity = Sum(Pending)  from VanStatementDetail where Product_Code = @ItemCode
if (IsNull(@Quantity,0) + IsNull(@VanQuantity,0)) > 0
Set @Active = 1
End
If isnull(@STax,0) = 0 
	Begin
		Set @STax = isnull((select Top 1 Sale_Tax From items Where Product_Code = @ItemCode),0)
	End
If isnull(@PTax,0) = 0 
	Begin
		Set @PTax = isnull((select Top 1 TaxSuffered From items Where Product_Code = @ItemCode),0)
	End

Update Items Set  ProductName = @ItemName, Description = @ItemDesc, CategoryID= @CategoryID, 
ManufacturerID = @MfrID, BrandID = @BrandID, UOM= @SUOM, Purchase_Price= @PurchasePrice, 
Sale_Price = @SalePrice, Sale_Tax = @STax, MRP = @MRP, StockNorm = @StockNorm, 
MinOrderQty = @MOQ, Track_Batches = @TrackBatches, ConversionFactor = @ConversionFactor,
ConversionUnit = @ConversionUnit, Active = @Active, SaleID = @SaleID, Company_Price = 
@CompanyPrice, PTS = @PTS, PTR = @PTR, ECP = @ECP, Purchased_At = @PurchasedAt, 
Company_Margin = @CompanyMargin, Stockist_Margin = @StockistMargin, Retailer_Margin = 
@RetailerMargin, TaxSuffered = @PTax, SoldAs = @SoldAs, Alias = @ForumCode, ReportingUOM = 
@RUOM, ReportingUnit = @ReportingUnit, TrackPKD = @TrackPKD, Virtual_Track_Batches = 
@VirtualTrackBatches, Hyperlink = @Hyperlink, VAT = @VAT, 
COLLECTTAXSUFFERED = @COLLECTTAXSUFFERED, AdhocAmount = @AdhocAmount,
Case_UOM = @CUOM, Case_Conversion = @CaseConversion
Where Product_Code = @ItemCode

select @priceOption=price_option from ItemCategories where CategoryId in( select categoryId from items where Product_code=@ITEMCODE)
	If @PriceOption = 0
	Begin
	UPDATE Batch_Products SET                
	   SalePrice = @SALEPRICE,                  
	   Company_Price = @COMPANYPRICE,                  
	   PTS = @PTS,                  
	   PTR = @PTR,                  
	   ECP = @ECP    
	WHERE Product_Code = @ITEMCODE  and (IsNull([free],0) <> 1 )  
	End



Select 1,@ForumCode, @ItemCode
END
Else
	Select 0, @ForumCode, @ItemCode
