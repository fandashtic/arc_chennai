CREATE Procedure sp_Get_ItemLists_StockTaking    
(@Manufacturer nvarchar(255),     
@Brand nvarchar(255),     
@Category nvarchar(255))    
As    
Create Table #tempCategory(CategoryID int, Status int)                  
Exec GetLeafCategories '%', @Category                

Select Product_Code, ProductName from Items, Manufacturer, Brand, ItemCategories    
Where  Items.ManufacturerID = Manufacturer.ManufacturerID and    
Items.BrandID = Brand.BrandID and    
Items.CategoryID = ItemCategories.CategoryID and    
Manufacturer.Manufacturer_Name like @Manufacturer and    
Brand.BrandName like @Brand and    
--ItemCategories.Category_Name like @Category    
ItemCategories.CategoryID in (Select CategoryID from #tempCategory)  
Order By Product_Code  
Drop Table #tempCategory  


