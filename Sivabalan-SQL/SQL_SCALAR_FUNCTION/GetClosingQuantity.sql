CREATE function GetClosingQuantity (@GivenDate Datetime, @CurrentDate Datetime, @Category nvarchar(255))  
  
Returns Decimal(18, 6)  
As  
Begin  
Declare @CatID Int  
Declare @Quantity Decimal(18, 6)  
Select @CatID = CategoryID From ItemCategories Where Category_Name Like @Category  
If @GivenDate < @CurrentDate  
Begin  
Select @Quantity = Opening_Quantity From OpeningDetails, Items Where   
OpeningDetails.Product_Code = Items.Product_Code And OpeningDetails.Opening_Date =   
Dateadd(DD, 1, @GivenDate) And items.CategoryID = @CatID  
End  
Else  
Begin  
Select @Quantity = Sum(Quantity) From Batch_Products, Items Where   
Batch_Products.Product_Code = Items.Product_Code And items.CategoryID = @CatID  
End  
Return @Quantity  
End  


