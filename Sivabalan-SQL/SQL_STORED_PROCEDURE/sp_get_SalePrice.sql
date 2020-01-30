CREATE PROCEDURE sp_get_SalePrice(@ItemCode as nvarchar(15))        
AS        
BEGIN        
DECLARE @PRICE_OPTION INT, @TRACK_INV INT    
Select @PRICE_OPTION=Price_Option,@TRACK_INV=Track_Inventory From Items inner join ItemCategories on Items.CategoryID=ItemCategories.CategoryID        
Where Product_Code=@ItemCode        
    
IF @TRACK_INV=1     
BEGIN        
 IF @PRICE_OPTION=1         
 BEGIN        
  Select Top 1 Batch_Code, Batch_Number, isnull(Expiry,''),isnull(PKD,''),ECP
  From Batch_Products        
  Where Product_Code= @ItemCode and isnull(free,0)=0        
  Order by Batch_Code        
 END      
 ELSE    
 BEGIN        
  Select Top 1 Batch_Code, Batch_Number, isnull(Expiry,''),isnull(PKD,''),Items.ECP        
  From Batch_Products INNER JOIN Items ON Items.Product_Code=Batch_Products.Product_Code     
  Where Batch_Products.Product_Code= @ItemCode and isnull(free,0)=0        
  Order by Batch_Code        
 END      
END      
ELSE        
BEGIN        
 Select '',N'', '','',ECP      
 From Items        
 Where Product_Code= @ItemCode        
END        
END      
  
  


