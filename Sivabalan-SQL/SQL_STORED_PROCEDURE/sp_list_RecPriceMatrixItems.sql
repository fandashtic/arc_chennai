
Create Procedure sp_list_RecPriceMatrixItems (@ForumCode nvarchar(20), @SERIAL Int)        
As  
Select Distinct PricingAbstractReceived.ItemCode, Items.Product_Code, Items.ProductName, ItemCategories.Category_Name  
From PricingAbstractReceived, Items, ItemCategories  
Where PricingAbstractReceived.PartyCode = @ForumCode And  
   PricingAbstractReceived.Flag = 0 And  
   PricingAbstractReceived.Serial = @SERIAL And  
   PricingAbstractReceived.ItemCode = Items.Alias And       
   ItemCategories.CategoryID = Items.CategoryID      
Order By PricingAbstractReceived.ItemCode

