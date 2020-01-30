Create Procedure sp_get_ItemECP (@Product_Code nvarchar(50), @BatchCode int)
As
Declare @PriceOption int

Select @PriceOption = Price_Option From ItemCategories, Items Where
Items.Product_Code = @Product_Code And Items.CategoryID = ItemCategories.CategoryID

If @PriceOption = 0 
	Select ECP From Items Where Product_Code = @Product_Code
Else
	Select Batch_Products.ECP From Batch_Products Where Product_Code = @Product_Code
	And Batch_Code = @BatchCode


