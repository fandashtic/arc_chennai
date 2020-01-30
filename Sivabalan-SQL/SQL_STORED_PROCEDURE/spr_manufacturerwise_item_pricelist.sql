CREATE PROCEDURE dbo.spr_manufacturerwise_item_pricelist(@Manufactname nvarchar(2550),                
          @Divisionname nvarchar(2550),@Categoryname nvarchar(2550))                 
AS                  
                
/* Procedure for listing the profit percentage of the items filtered by Manufacture name                 
 and Division name */                
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
            
            
Select distinct "Item Code" = Items.Product_Code, "Item Code" = Items.Product_Code,"Item Name"= Items.ProductName,              
"Category Name " = ItemCategories.Category_Name ,            
"PTS" = case Itemcategories.Price_Option when 0 then Items.PTS else Batch_Products.PTS end,                
 "Profit% On CP" = Cast(case Itemcategories.Price_Option               
    when 0 then (Items.PTR - Items.PTS)/case Items.PTS when 0 then 1 else Items.PTS end               
    else (Batch_Products.PTR - Batch_Products.PTS)/case Batch_Products.PTS when 0 then 1 else Batch_Products.PTS end               
       end * 100 as Decimal(18,6)),                
 "Profit% On SP" = Cast(case Itemcategories.Price_Option               
    when 0 then (Items.PTR - Items.PTS)/case Items.PTR when 0 then 1 else Items.PTR end               
    else (Batch_Products.PTR - Batch_Products.PTS)/case Batch_Products.PTR when 0 then 1 else Batch_Products.PTR end               
    end * 100 as Decimal(18,6)),                  
"PTR" = case Itemcategories.Price_Option when 0 then Items.PTR else Batch_Products.PTR end,                
 "Profit% On CP" = Cast(case Itemcategories.Price_Option               
    when 0 then (Items.ECP - Items.PTR)/case Items.PTR when 0 then 1 else Items.PTR end               
    else (Batch_Products.ECP - Batch_Products.PTR)/case Batch_Products.PTR when 0 then 1 else Batch_Products.PTR end               
    end * 100 as Decimal(18,6)),                  
 "Profit% On SP" = Cast(case Itemcategories.Price_Option               
    when 0 then (Items.ECP - Items.PTR)/case Items.ECP when 0 then 1 else Items.ECP end               
    else (Batch_Products.ECP - Batch_Products.PTR)/case Batch_Products.ECP when 0 then 1 else Batch_Products.ECP end               
    end * 100 as Decimal(18,6)),                 
"ECP" = case Itemcategories.Price_Option when 0 then Items.ECP else Batch_Products.ECP end,
"MRPPerPack" = case Itemcategories.Price_Option when 0 then Items.MRPPerPack else Batch_Products.MRPPerPack end                            
                
From Batch_Products,Items,Manufacturer,brand,ItemCategories, GRNAbstract                 
where   Batch_Products.Product_Code = Items.Product_Code And                
 Items.BrandID = brand.BrandID AND                
 Items.ManufacturerID = Manufacturer.ManufacturerID And               
 Items.CategoryID = ItemCategories.CategoryID AND                
 Manufacturer.Manufacturer_Name in (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) AND                
 brand.BrandName in (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) and             
 itemcategories.category_name in (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCat) And   
 Batch_Products.GRN_ID = GRNAbstract.GRNID And  
 (Isnull(GRNAbstract.GRNStatus,0) & 32) = 0  
               
Group by Items.ManufacturerID, Items.Product_Code,ProductName,Batch_Products.PTR,Batch_Products.PTS,Batch_Products.ECP,Batch_Products.MRPPerPack,              
  Items.PTR, Items.PTS, Items.ECP,Items.MRPPerPack ,ItemCategories.Price_Option,ItemCategories.Category_Name            
              
Drop Table #tmpMfr            
Drop Table #tmpDiv            
Drop Table #tmpCat            
