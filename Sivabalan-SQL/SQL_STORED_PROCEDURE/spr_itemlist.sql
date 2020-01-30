
CREATE PROCEDURE dbo.spr_itemlist (@Manufact_name nvarchar(2550),       
          @Division_name nvarchar(2550),       
          @fromdate datetime,       
          @todate datetime)      
AS      
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
Create table #tmpDiv(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @Manufact_name='%'       
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer      
Else      
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufact_name,@Delimeter)      
      
if @Division_name='%'      
   Insert into #tmpDiv select BrandName from Brand      
Else      
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@Division_name,@Delimeter)      
    
Select  distinct Items.CreationDate,"Product Code" = Items.Product_Code,       
 "Product Name"= Items.ProductName, PTS,PTR, ECP, 
--	MRP,
 "MRP Per Pack" = isnull(items.MRPPerPack,0),
  "Special Price"=Company_Price,   
 "Sales Tax Local %" = t1.Percentage,"Sales Tax Central%" = t1.cst_percentage,      
        "Tax Suffered Local %" = t2.percentage,"Tax Suffered Central%" = t2.cst_percentage,      
 "Manufacturer" = Manufacturer.Manufacturer_Name, "Division" = Brand.BrandName,       
 "Date" = Items.CreationDate      
From Items
Left Outer Join Tax t1 On Items.Sale_Tax = t1.Tax_Code
Left Outer Join Tax t2 On Items.TaxSuffered = t2.Tax_Code 
Inner Join Manufacturer On  Items.ManufacturerID = Manufacturer.ManufacturerID 
Inner Join brand On Items.BrandID = brand.BrandID 
where  Items.CreationDate BETWEEN @fromdate AND @todate AND      
Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) AND      
brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)      
   
Drop table #tmpMfr  
Drop table #tmpDiv  
