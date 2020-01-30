Create Procedure sp_Update_batch_Taxsuffered_FMCG(@ProductCode nvarchar(30),  
@BatchCode nvarchar(30),  
@PurchasePrice Decimal(18,6),  
@TaxSuffered Decimal(18,6),  
@ApplicableOn int ,  
@PartOf Decimal(18,6))  
As
Declare @Purchase_Price decimal (18,6)  
Declare @PriceOption int
Begin  
	Select @PriceOption = IsNull(Price_Option,0) from ItemCategories where CategoryId=(select CategoryId from Items where Product_code=@ProductCode) 
	Select @Purchase_Price=Purchase_Price from Items where Product_code=@Productcode --noncsp items

	if @PriceOption = 1 
		Set @Purchase_Price = @PurchasePrice --cspitems	
	
	Update Batch_Products set TaxSuffered=@TaxSuffered,PurchasePrice=@Purchase_Price,  
	ApplicableOn=@ApplicableOn,PartofPercentage=@PartOf where Batch_Code=@BatchCode  
End   
  


