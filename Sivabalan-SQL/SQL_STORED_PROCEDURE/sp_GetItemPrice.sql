CREATE procedure sp_GetItemPrice (@ItemCode nvarchar(30))
as
SELECT Track_Batches, Sale_Price, Price_Option, Track_Inventory, PTS, PTR, Company_Price, Virtual_Track_Batches
FROM Items, ItemCategories WHERE Product_Code = @ItemCode AND ItemCategories.CategoryID = Items.CategoryID





