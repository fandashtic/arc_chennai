CREATE PROCEDURE [dbo].[sp_get_items2print](@CATEGORY nvarchar(128),       
         @MANUFACTURER nvarchar(128),      
         @BRAND nvarchar(128))      
AS      
create table #tempcategory(CategoryID int, Status int)  
exec getleafcategories N'%', @CATEGORY  
Select Batch_Products.Product_Code, ProductName, Batch_Number, 
IsNull(Case When Month(Batch_Products.Expiry) < 10 Then N'0' Else N'' End + Cast(Month(Batch_Products.Expiry) as nvarchar) + N'/' + Cast(Year(Batch_Products.Expiry) as nvarchar), N''), 
Case When Month(Batch_Products.PKD) < 10 Then N'0' Else N'' End + Cast(Month(Batch_Products.PKD) as nvarchar) + N'/' + Cast(Year(Batch_Products.PKD) as nvarchar),     
Cast(Cast(Case Price_Option When 1 Then ISNULL(Batch_Products.ECP,0) Else Items.ECP End As Decimal(18,2)) As nvarchar),     
Cast(Sum(Quantity) as Decimal(18,2)), "MRP" = Cast(Cast(Items.MRP as Decimal(18,2)) as nvarchar),     
"PTS" = Cast(Cast(Case Price_Option When 1 Then ISNULL(Batch_Products.PTS,0) Else Items.PTS End as Decimal(18,2)) As nvarchar),           
"PTR" = Cast(Cast(Case Price_Option When 1 Then ISNULL(Batch_Products.PTR,0) Else Items.PTR End as Decimal(18,2)) As nvarchar),           
"Spl Price" = Cast(Cast(Case Price_Option When 1 Then ISNULL(Batch_Products.Company_Price,0) Else Items.Company_Price End as Decimal(18,2)) As nvarchar),        
"ECP + Tax" = Cast(Cast(Case Price_Option When 1 Then ISNULL(Batch_Products.ECP,0) Else Items.ECP End * (1 + (IsNull(Tax.Percentage,0) / 100)) as Decimal(18,2)) as nvarchar)    
From Items
Inner Join ItemCategories on Items.CategoryID = ItemCategories.CategoryID
Inner Join Manufacturer on Items.ManufacturerID = Manufacturer.ManufacturerID
Inner Join Brand on Items.BrandID = Brand.BrandID
Inner Join Batch_Products on Items.Product_Code = Batch_Products.Product_Code
Left Outer Join Tax on Items.Sale_Tax = Tax.Tax_Code
Where   
--Items.CategoryID = ItemCategories.CategoryID And       
  --Items.ManufacturerID = Manufacturer.ManufacturerID And      
  --Items.BrandID = Brand.BrandID And      
  --Items.Product_Code = Batch_Products.Product_Code And      
  ItemCategories.CategoryID In (Select CategoryID From #tempcategory) And          
  Manufacturer.Manufacturer_Name Like @MANUFACTURER And      
  Brand.BrandName Like @BRAND And (IsNull(Items.Flags, 0) & 1) = 0 
  --And    
  --Items.Sale_Tax *= Tax.Tax_Code          
Group By Batch_Products.Product_Code, ProductName, Batch_Number, Expiry, PKD,     
Price_Option, Items.ECP, MRP, Items.PTS, Items.PTR, Items.Company_Price,     
Batch_Products.PTS, Batch_Products.PTR, Batch_Products.Company_Price, Batch_Products.ECP,     
Tax.Percentage    
drop table #tempcategory  
