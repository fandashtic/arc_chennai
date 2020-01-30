create procedure Sp_Get_ItemInformation(@Product_Code NVarchar(30))
as
SELECT ItemCategories.Price_Option,Items.Productname,items.Track_batches, 
ItemCategories.Track_Inventory FROM ItemCategories,Items 
where Items.CategoryID = ItemCategories.CategoryID and 
Items.Product_Code = @Product_Code




