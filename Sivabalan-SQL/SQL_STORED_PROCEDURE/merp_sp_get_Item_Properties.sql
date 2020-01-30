Create Procedure merp_sp_get_Item_Properties(@Product_Code NVarchar(50))      
As      
Begin      
 Select       
 Items.Product_Code,      
 Items.ProductName,      
 Items.Virtual_Track_Batches,      
 ItemCategories.Track_Inventory,      
 ItemCategories.Price_Option,      
 Items.TrackPKD,      
 Items.Purchased_At
 From Items, ItemCategories      
 Where Items.Product_Code = @Product_Code And      
 Items.CategoryID = ItemCategories.CategoryID And Items.Active = 1      
End
