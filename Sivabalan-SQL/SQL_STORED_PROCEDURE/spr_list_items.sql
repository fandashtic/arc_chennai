CREATE PROCEDURE spr_list_items(@Manufactname nvarchar(2550),      
    @Divisionname nvarchar(2550))      
AS      
Begin      
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Create table #tmpDiv(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
if @Manufactname='%'         
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer        
Else        
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufactname,@Delimeter)        
        
if @Divisionname='%'        
   Insert into #tmpDiv select BrandName from Brand        
Else        
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@Divisionname,@Delimeter)        
      
SELECT Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,       
 "Description" = Items.Description,      
 "Category" = ItemCategories.Category_Name,
 "Forum Code" = Items.Alias
 ,"HSN Code" = Items.HSNNumber
FROM Items
Left Outer Join  ItemCategories On Items.CategoryID = ItemCategories.CategoryID
Inner Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID
Inner Join brand On Items.BrandID = brand.BrandID
WHERE 
 Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) AND      
 brand.BrandName In (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)       
ORDER BY Items.Product_Code      
      
Drop table #tmpMfr      
Drop table #tmpDiv

End
