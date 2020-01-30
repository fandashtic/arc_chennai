CREATE procedure sp_GetItemPrice_FMCG (@ItemCode nvarchar(30))
as
SELECT Track_Batches, Sale_Price, Price_Option, Track_Inventory, Virtual_Track_Batches
FROM Items, ItemCategories WHERE Product_Code = @ItemCode AND ItemCategories.CategoryID = Items.CategoryID


SET QUOTED_IDENTIFIER ON 

