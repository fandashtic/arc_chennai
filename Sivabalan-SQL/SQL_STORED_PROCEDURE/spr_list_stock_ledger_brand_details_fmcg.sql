CREATE procedure [dbo].[spr_list_stock_ledger_brand_details_fmcg](@BRAND int, 
														  @FROM_DATE datetime, 
														  @ShowItems nvarchar(50), 
														  @StockVal nvarchar(100),
														  @ItemCode nvarchar(2550),
														  @ItemName nvarchar(255))            
AS            
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @ItemCode = N'%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

IF (DATEPART(dy, @FROM_DATE) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FROM_DATE) = DATEPART(yyyy, GETDATE())) OR DATEPART(yyyy, @FROM_DATE) < DATEPART(yyyy, GETDATE())        
BEGIN            
 IF @ShowItems = N'Items with stock'        
 begin        
  Select  Items.Product_Code,           
   "Item Code" = Items.Product_Code,             
   "Item Name" = Items.ProductName,             
   "Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)   + N' ' + CAST(ISNULL(UOM.Description,N'') AS nvarchar),             
   "Conversion Unit" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) * Items.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + N' ' + CAST(isnull(ConversionTable.ConversionUnit, N'') AS nvarchar),            
   "Reporting UOM" = Cast( dbo.sp_Get_ReportingUOMQty(Items.Product_Code, ISNULL(OpeningDetails.Opening_Quantity, 0)) As nvarchar) 
--    CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)           
     + N' ' + CAST((SELECT isnull(Description, N'') FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),            
  "Total On Hand Value" =       
  case @StockVal        
  When N'SalePrice' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))            
  When N'PurchasePrice' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))            
--   When 'ECP' Then       
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))            
   When N'MRP' Then       
   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))            
--   When 'Special Price' Then       
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))            
  Else      
  (ISNULL(OpeningDetails.Opening_Value, 0))          
  End,     
   "Saleable Stock" = (isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),          
    "Saleable Value" =       
 case @StockVal        
 When N'SalePrice' Then       
 (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))  - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))          
 When N'PurchasePrice' Then       
 (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))          
--  When 'ECP' Then       
--  (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.ECP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))          
  When N'MRP' Then       
  (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.MRP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))          
--  When 'Special Price' Then       
--  (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Company_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))          
 Else      
 (isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0)) 
 End,      
   "Free OnHand Qty" = isnull(openingdetails.Free_Saleable_Quantity, 0),            
   "Damages Qty" = isnull(openingdetails.Damage_Opening_Quantity,0),            
    "Damages Value" =       
 case @StockVal        
 When N'SalePrice' Then       
 isnull((isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)), 0)          
 When N'PurchasePrice' Then      
isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)), 0)          
--  When 'ECP' Then      
--  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)          
  When N'MRP' Then      
  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)          
--  When 'Special Price' Then   
--  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)          
 Else      
 isnull((openingdetails.Damage_Opening_Value), 0)          
 End      
  from    Items, OpeningDetails, UOM, conversionTable            
WHERE   Items.Product_Code = OpeningDetails.Product_Code AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)            
   AND Items.BrandID = @BRAND            
   AND Items.UOM *= UOM.UOM             
   AND Items.ConversionUnit *= ConversionTable.ConversionID            
   And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
   and items.active = 1        
   and ISNULL(OpeningDetails.Opening_Quantity, 0) > 0        
 end        
 else        
 begin        
  Select  Items.Product_Code,           
   "Item Code" = Items.Product_Code,             
   "Item Name" = Items.ProductName,             
   "Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)   + N' ' + CAST(ISNULL(UOM.Description,N'') AS nvarchar),             
   "Conversion Unit" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) * Items.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + N' ' + CAST(isnull(ConversionTable.ConversionUnit, N'') AS nvarchar),            
   "Reporting UOM" = Cast( dbo.sp_Get_ReportingUOMQty(Items.Product_Code, ISNULL(OpeningDetails.Opening_Quantity, 0)) As nvarchar) 
  --CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)           
     + N' ' + CAST((SELECT isnull(Description, N'') FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),            
  "Total On Hand Value" =       
  case @StockVal        
  When N'SalePrice' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))            
  When N'PurchasePrice' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))            
--   When 'ECP' Then       
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))            
   When N'MRP' Then       
   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))            
--   When 'Special Price' Then       
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))            
  Else      
  (ISNULL(OpeningDetails.Opening_Value, 0))          
  End,     
   "Saleable Stock" = (isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),          
    "Saleable Value" =       
 case @StockVal        
 When N'SalePrice' Then       
 (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))  - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))          
 When N'PurchasePrice' Then       
 (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))          
--  When 'ECP' Then       
--  (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.ECP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))          
  When N'MRP' Then       
  (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.MRP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))          
--  When 'Special Price' Then       
--  (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Company_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))          
 Else      
 (isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))      
 End,      
   "Free OnHand Qty" = isnull(openingdetails.Free_Saleable_Quantity, 0),            
   "Damages Qty" = isnull(openingdetails.Damage_Opening_Quantity,0),            
    "Damages Value" =   
 case @StockVal        
 When N'SalePrice' Then       
 isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)), 0)          
 When N'PurchasePrice' Then      
 isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)), 0)          
--  When 'ECP' Then      
--  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)          
  When N'MRP' Then      
  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)          
--  When 'Special Price' Then      
--  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)          
 Else      
 isnull((openingdetails.Damage_Opening_Value), 0)          
 End      
  from    Items, OpeningDetails, UOM, conversionTable            
  WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)            
   AND Items.BrandID = @BRAND            
   AND Items.UOM *= UOM.UOM             
   AND Items.ConversionUnit *= ConversionTable.ConversionID            
   And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
   and items.active = 1         
 end        
END            
ELSE            
BEGIN          
 IF @ShowItems = N'Items with stock'        
 begin        
  Select  a.Product_Code,            
   "Item Code" = a.Product_Code,           
   "Item Name" = a.ProductName,             
   "Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar)  + N' ' + CAST(ISNULL(UOM.Description,N'') AS nvarchar),             
   "Conversion Unit" = CAST(CAST(ISNULL(SUM(Quantity), 0) * a.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + N' ' + CAST(isnull(ConversionTable.ConversionUnit, N'') AS nvarchar),            
   "Reporting UOM" = Cast( dbo.sp_Get_ReportingUOMQty(a.Product_Code, ISNULL(SUM(Quantity), 0)) As nvarchar) 
  --CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE a.ReportingUnit WHEN 0 THEN 1 ELSE a.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)   
  + N' ' + CAST((SELECT isnull(Description, N'') FROM UOM WHERE UOM = a.ReportingUOM) AS nvarchar),        
   
 "Total On Hand Value" =         
  case @StockVal        
  When N'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Sale_Price, 0)) End) End)  
  When N'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Purchase_Price, 0)) End) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.ECP, 0)) End) End)  
   When N'MRP' Then      
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(a.MRP, 0)End)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Company_Price, 0)) End) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End,      
   "Saleable Stock" = isnull((select Sum(Quantity) from batch_products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.BrandID = @Brand And Items.Product_Code = a.Product_Code),0),     
 
  "Saleable Value" = Isnull((Select         
  case @StockVal        
  When N'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)  
  When N'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
   When N'MRP' Then      
   isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End       
 from batch_products, Items, ItemCategories IC         
     where Items.CategoryID = IC.CategoryID AND Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and         
      isnull(damage,0) = 0 And Items.BrandID = @Brand And         
      Items.Product_Code = a.Product_Code)  ,0),          
   "Free OnHand Qty" = isnull((select sum(Quantity) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and free <> 0 And Items.BrandID = @Brand And Items.Product_Code = a.Product_Code),0),            
   "Damages Qty" = isnull((select sum(Quantity) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and damage <> 0 And Items.BrandID = @Brand And Items.Product_Code = a.Product_Code), 0),           
  "Damages Value" = isnull((select        
  case @StockVal        
  When N'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)  
  When N'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
   When N'MRP' Then      
   isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End      
from Batch_Products, Items, ItemCategories IC where Items.CategoryID = IC.CategoryID AND Items.Product_Code = Batch_Products.Product_Code and damage <> 0 And Items.BrandID = @Brand And Items.Product_Code = a.Product_Code),  0)          
  from Items a, Batch_Products, UOM, ConversionTable, ItemCategories IC            
  WHERE a.Product_Code *= Batch_Products.Product_Code AND a.BrandID = @BRAND            
   AND a.UOM *= UOM.UOM            
   AND a.ConversionUnit *= ConversionTable.ConversionID            
   AND a.CategoryID = IC.CategoryID  
   And a.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
   and a.active = 1             
  GROUP BY a.Product_Code, a.ProductName, a.UOM, a.ConversionUnit,            
   a.ConversionFactor, a.ReportingUnit, a.ReportingUOM, ConversionTable.ConversionUnit,            
   UOM.Description            
   HAVING ISNULL(SUM(QUANTITY), 0) > 0        
 end        
 else        
 begin        
  Select  a.Product_Code,            
   "Item Code" = a.Product_Code,           
   "Item Name" = a.ProductName,             
 "Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar)  + N' ' + CAST(ISNULL(UOM.Description,N'') AS nvarchar),             
   "Conversion Unit" = CAST(CAST(ISNULL(SUM(Quantity), 0) * a.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + N' ' + CAST(isnull(ConversionTable.ConversionUnit, N'') AS nvarchar),            
"Reporting UOM" = Cast( dbo.sp_Get_ReportingUOMQty(a.Product_Code, ISNULL(SUM(Quantity), 0)) As nvarchar) 
--CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE a.ReportingUnit WHEN 0 THEN 1 ELSE a.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)   
  + N' ' + CAST((SELECT isnull(Description, N'') FROM UOM WHERE UOM = a.ReportingUOM) AS nvarchar),        
   
 "Total On Hand Value" =         
  case @StockVal        
  When N'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Sale_Price, 0)) End) End)  
  When N'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Purchase_Price, 0)) End) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.ECP, 0)) End) End)  
   When N'MRP' Then    
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(a.MRP, 0)End)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Company_Price, 0)) End) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End,        
   "Saleable Stock" = isnull((select Sum(Quantity) from batch_products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.BrandID = @Brand And Items.Product_Code = a.Product_Code),0),     
 
  "Saleable Value" = Isnull((Select         
  case @StockVal        
  When N'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)  
  When N'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
   When N'MRP' Then      
   isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End        
 from batch_products, Items, ItemCategories IC         
     where Items.CategoryID = IC.CategoryID And Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and         
      isnull(damage,0) = 0 And Items.BrandID = @Brand And         
      Items.Product_Code = a.Product_Code)  ,0),          
   "Free OnHand Qty" = isnull((select sum(Quantity) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and free <> 0 And Items.BrandID = @Brand And Items.Product_Code = a.Product_Code),0),            
   "Damages Qty" = isnull((select sum(Quantity) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and damage <> 0 And Items.BrandID = @Brand And Items.Product_Code = a.Product_Code), 0),       
  "Damages Value" = isnull((select        
  case @StockVal        
  When N'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)  
  When N'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
   When N'MRP' Then      
   isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End       
from Batch_Products, Items, ItemCategories IC where Items.CategoryID = IC.CategoryID AND Items.Product_Code = Batch_Products.Product_Code and damage <> 0 And Items.BrandID = @Brand And Items.Product_Code = a.Product_Code),  0)          
  from Items a, Batch_Products, UOM, ConversionTable, ItemCategories IC            
  WHERE a.Product_Code *= Batch_Products.Product_Code AND a.BrandID = @BRAND            
   AND a.UOM *= UOM.UOM            
   AND a.ConversionUnit *= ConversionTable.ConversionID      
   AND a.CategoryID = IC.CategoryID        
   And a.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
   and a.active = 1             
  GROUP BY a.Product_Code, a.ProductName, a.UOM, a.ConversionUnit,            
   a.ConversionFactor, a.ReportingUnit, a.ReportingUOM, ConversionTable.ConversionUnit,            
   UOM.Description            
 end        
END
