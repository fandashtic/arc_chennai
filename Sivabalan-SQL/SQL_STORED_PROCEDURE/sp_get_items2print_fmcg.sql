CREATE procedure [dbo].[sp_get_items2print_fmcg](@CATEGORY nvarchar(128),       
         @MANUFACTURER nvarchar(128),      
         @BRAND nvarchar(128))      
AS      
create table #tempcategory(CategoryID int, Status int)  
exec getleafcategories N'%', @CATEGORY  
Select Batch_Products.Product_Code, ProductName, Batch_Number, 
IsNull(Case When Month(Batch_Products.Expiry) < 10 Then N'0' Else N'' End + Cast(Month(Batch_Products.Expiry) as nvarchar) + N'/' + Cast(Year(Batch_Products.Expiry) as nvarchar), N''), 
Case When Month(Batch_Products.PKD) < 10 Then N'0' Else N'' End + Cast(Month(Batch_Products.PKD) as nvarchar) + N'/' + Cast(Year(Batch_Products.PKD) as nvarchar), 
Cast(Case Price_Option When 1 Then ISNULL(Batch_Products.SalePrice,0) Else Items.Sale_Price End as decimal(18, 2)), Cast(Sum(Quantity) as Decimal(18,2)),     
"MRP" = Cast(Cast(Items.MRP as Decimal(18,2)) as nvarchar),     
"Sale Price + Tax" = Cast(Cast(Case Price_Option When 1 Then ISNULL(Batch_Products.SalePrice,0) Else Items.Sale_Price End * (1 + (IsNull(Tax.Percentage,0) / 100)) as Decimal(18,2)) as nvarchar)          
From Items, ItemCategories, Manufacturer, Brand, Batch_Products, Tax    
Where   Items.CategoryID = ItemCategories.CategoryID And       
  Items.ManufacturerID = Manufacturer.ManufacturerID And      
  Items.BrandID = Brand.BrandID And      
  Items.Product_Code = Batch_Products.Product_Code And      
  ItemCategories.CategoryID In (Select CategoryID From #tempcategory) And          
  Manufacturer.Manufacturer_Name Like @MANUFACTURER And      
  Brand.BrandName Like @BRAND And (IsNull(Items.Flags, 0) & 1) = 0 And    
  Items.Sale_Tax *= Tax.Tax_Code          
Group By Batch_Products.Product_Code, ProductName, Batch_Number, Expiry, PKD, Price_Option,     
Batch_Products.SalePrice, Items.Sale_Price, Tax.Percentage, Items.MRP    
drop table #tempcategory
