CREATE PROCEDURE sp_update_SalePrice_FMCG      
(      
 @ItemCode as nVarchar(15),       
 @PriceAtUOMLevel as Int      
)            
AS       
Declare @priceOption int
BEGIN  
DECLARE @nconvFactor Decimal(18,6)   
SET @nconvFactor = 1  
IF @PriceAtUOMLevel=1  
 SET @nconvFactor = (SELECT UOM1_Conversion FROM Items WHERE Product_Code=@ItemCode)  
ELSE IF @PriceAtUOMLevel=2  
 SET @nconvFactor = (SELECT UOM2_Conversion FROM Items WHERE Product_Code=@ItemCode)  
IF @nconvFactor>0     
BEGIN    
 UPDATE Items SET Sale_Price = Sale_Price/@nconvFactor,     
 Purchase_Price = Purchase_Price/@nconvFactor, MRP = MRP/@nconvFactor    
 WHERE Product_Code=@ItemCode    
    
select @priceOption = IsNull(ItemCategories.price_option, 0) 
from items, ItemCategories 
where items.CategoryId = ItemCategories.CategoryId 
And items.Product_Code = @ITEMCODE
If @PriceOption = 0
Begin
	Update Batch_Products set SalePrice = SalePrice/@nconvFactor
	Where Product_code = @ItemCode And isnull(free,0) <> 1
End 
END    
END    


