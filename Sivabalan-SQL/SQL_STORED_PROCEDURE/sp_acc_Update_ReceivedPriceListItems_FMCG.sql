CREATE Procedure sp_acc_Update_ReceivedPriceListItems_FMCG(@ForumCode VarChar(50),     
@PurchasePrice Decimal(18,6),@SalePrice Decimal(18,6),@MRP Decimal(18,6),  
@TaxSuffered Int,@TaxApplicable Int)    
As    
Update Items Set     
Purchase_Price = @PurchasePrice,     
Sale_Price = @SalePrice,     
MRP = @MRP,     
TaxSuffered = @TaxSuffered,     
Sale_Tax = @TaxApplicable    
Where Alias = @ForumCode    

