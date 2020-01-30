CREATE function GetClosingValue (@GivenDate Datetime, @CurrentDate Datetime, @Category nvarchar(255))  
Returns Decimal(18, 6)  
As  
Begin  
Declare @CatID Int  
Declare @Value Decimal(18, 6)  
Select @CatID = CategoryID From ItemCategories Where Category_Name Like @Category  
If @GivenDate < @CurrentDate  
Begin  
Select @Value = Opening_Value From OpeningDetails, Items Where   
OpeningDetails.Product_Code = Items.Product_Code And OpeningDetails.Opening_Date =   
Dateadd(DD, 1, @GivenDate) And items.CategoryID =  @CatID  
End  
Else  
Begin  
Select  @Value = Sum(Quantity * PurchasePrice) From Batch_Products, Items Where   
Batch_Products.Product_Code = Items.Product_Code And items.CategoryID = @CATID  
End  
Return @Value  
End  


