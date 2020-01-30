CREATE Procedure sp_acc_Update_ReceivedPriceListItems(@ForumCode	nVarChar(50), 
@PTS Decimal(18,6), @PTR Decimal(18,6), @ECP Decimal(18,6), @PurchasePrice Decimal(18,6),
@SalePrice Decimal(18,6),@MRP Decimal(18,6),@SpecialPrice Decimal(18,6), @TaxSuffered Int,@TaxApplicable Int)
As
Update Items Set 
PTS = @PTS,
PTR = @PTR,
ECP = @ECP, 
Purchase_Price = @PurchasePrice, 
Sale_Price = @SalePrice, 
MRP = @MRP, 
Company_Price = @SpecialPrice, 
TaxSuffered = @TaxSuffered, 
Sale_Tax = @TaxApplicable
Where Alias = @ForumCode

Declare @priceOption Integer, @ITEM_CODE nVarchar(15)

Select @ITEM_CODE = Product_Code From Items Where Alias = @ForumCode

Select @priceOption=price_option from ItemCategories where CategoryId in( select categoryId from items where Alias = @ForumCode)
 If @PriceOption = 0    
 Begin    
 UPDATE Batch_Products SET                 
    SalePrice = @SalePrice,                      
    Company_Price = @SpecialPrice,                      
    PTS = @PTS,                      
    PTR = @PTR,                      
    ECP = @ECP                    
 WHERE Product_Code = @ITEM_CODE  And isnull(free,0) <> 1   
 End



