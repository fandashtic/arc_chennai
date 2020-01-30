CREATE PROCEDURE spr_manufacturerwise_item_pricelist_fmcg(@Manufactname nvarchar(2550),        
          @Divisionname nvarchar(2550),@Categoryname nvarchar(2550))         
AS          
    
Declare @Delimeter as Char(1)        
Set @Delimeter = Char(15)        
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Create table #tmpDiv(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Create table #tmpCat(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
      
if @Manufactname = '%'         
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer        
Else        
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufactname,@Delimeter)        
        
if @Divisionname = '%'        
   Insert into #tmpDiv select BrandName from Brand        
Else        
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@Divisionname,@Delimeter)        
      
if @Categoryname = '%'        
   Insert into #tmpCat Select Category_Name from ItemCategories        
Else        
   Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Categoryname,@Delimeter)        
      
Select "Item Code" = Items.Product_Code, "Item Code" = Items.Product_Code,"Item Name"= ProductName,      
"Category Name " = ItemCategories.Category_Name ,    
 "Purchase Price" = case Itemcategories.Price_Option when 0 then Items.Purchase_Price else Batch_Products.PurchasePrice end,      
 "Profit% On CP" = Cast(case Itemcategories.Price_Option       
   when 0 then (Sale_Price - Purchase_Price)/case Purchase_Price when 0 then 1 else Purchase_Price end      
   else (SalePrice - PurchasePrice)/case PurchasePrice when 0 then 1 else PurchasePrice end      
   end * 100 as Decimal(18,6)),          
 "Profit% On SP" = Cast(case Itemcategories.Price_Option       
   when 0 then (Sale_Price - Purchase_Price)/case Sale_Price when 0 then 1 else Sale_Price end       
   else (SalePrice - PurchasePrice)/case SalePrice when 0 then 1 else SalePrice end      
   end * 100 as Decimal(18,6)),        
 "Sale Price" = case Itemcategories.Price_Option when 0 then Items.Sale_Price else Batch_Products.SalePrice end      
        
From Items,Manufacturer,brand,Batch_Products,Itemcategories       
where Batch_Products.Product_Code = Items.Product_Code And        
 Items.BrandID = brand.BrandID AND        
 Items.ManufacturerID = Manufacturer.ManufacturerID And       
 Items.CategoryID = ItemCategories.CategoryID AND        
 Manufacturer.Manufacturer_Name in (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) AND        
 brand.BrandName in (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) and     
itemcategories.category_name in (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCat)    
        
Group by  Items.Product_Code,ProductName,Purchase_Price,Sale_Price,Itemcategories.Price_Option,Batch_Products.PurchasePrice,Batch_Products.SalePrice,ItemCategories.Category_Name        
     
Drop Table #tmpMfr      
Drop Table #tmpDiv      
Drop Table #tmpCat        
    
    
  





