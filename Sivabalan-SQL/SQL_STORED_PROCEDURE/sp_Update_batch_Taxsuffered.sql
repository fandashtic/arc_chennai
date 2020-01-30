Create Procedure sp_Update_batch_Taxsuffered(@ProductCode nvarchar(30),
@BatchCode Int,
@PTS Decimal(18,6),
@PTR Decimal(18,6),
@TaxSuffered Decimal(18,6),
@ApplicableOn int ,
@PartOf Decimal(18,6))
As
Declare @PurchasePrice as Decimal(18,6)
Declare @PurchaseAt as int
Declare @PriceOption as int
Select @PriceOption = IsNull(Price_Option,0) from ItemCategories where CategoryId=(select CategoryId from Items where Product_code=@ProductCode) 
select @PurchaseAt=Purchased_At,@PurchasePrice=Purchase_price from Items where Product_code=@ProductCode
If @PriceOption = 1 
Begin
	If @PurchaseAt = 1 
		set @PurchasePrice = @PTS
	else
		set @PurchasePrice = @PTR
end
	Update Batch_Products set TaxSuffered=@TaxSuffered,PurchasePrice=@PurchasePrice,
	ApplicableOn=@ApplicableOn,PartofPercentage=@PartOf where Batch_Code=@BatchCode


