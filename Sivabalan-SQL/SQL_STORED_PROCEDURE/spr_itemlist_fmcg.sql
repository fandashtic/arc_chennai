CREATE procedure [dbo].[spr_itemlist_fmcg] (@Manufact_name nvarchar(2550),   
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
  
Select  distinct Items.CreationDate,"Product Code" = Items.Product_Code, "Product Name"= Items.ProductName,  
"Purchase Price" = Purchase_Price,"Sales Price" = Sale_Price, MRP,   
"Sales Tax" = t1.Tax_Description,"Tax Suffered" = t2.Tax_Description,  
"Manufacturer" = Manufacturer.Manufacturer_Name,"Brand" = Brand.BrandName, "Date" = Items.CreationDate  
From Items,Tax t1,Tax t2,Manufacturer,brand  
where  Items.CreationDate BETWEEN @fromdate AND @todate AND  
 Items.Sale_Tax *= t1.Tax_Code AND Items.TaxSuffered *= t2.Tax_Code AND  
 Items.BrandID = brand.BrandID AND  
 Items.ManufacturerID = Manufacturer.ManufacturerID AND  
 Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) AND        
 brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)        
     
Drop table #tmpMfr    
Drop table #tmpDiv
