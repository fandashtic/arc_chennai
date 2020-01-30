CREATE PROCEDURE [dbo].[spr_list_stock_ledger_category_details_FMCG](@CATEGORY int, 
															 @FROM_DATE datetime, 
															 @ShowItems nvarchar(50), 
															 @StockVal nvarchar(100), 
															 @ItemCode nvarchar(2550),
															 @ItemName nvarchar(255))            
AS            
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @ItemCode = '%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

IF (DATEPART(dy, @FROM_DATE) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FROM_DATE) = DATEPART(yyyy, GETDATE())) OR DATEPART(yyyy, @FROM_DATE) < DATEPART(yyyy, GETDATE())            
BEGIN         
 IF @ShowItems = 'Items With Stock'        
 BEGIN           
  Select  Items.Product_Code, "Item Code" = Items.Product_Code,             
    "Item Name" = Items.ProductName,             
    "Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)            
    + ' ' + CAST(UOM.Description AS nvarchar),             
    "Conversion Unit" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) * Items.ConversionFactor AS Decimal(18,6)) AS nvarchar)            
    + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),            
    "Reporting UOM" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit When 0 then 1 else Items.ReportingUnit End) AS Decimal(18,6)) AS nvarchar)            
    + ' ' + CAST((SELECT Description From UOM Where UOM = Items.ReportingUOM) AS nvarchar),            
  "Total On Hand Value" =       
  case @StockVal        
  When 'SalePrice' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))            
  When 'PurchasePrice' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))            
--   When 'ECP' Then       
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))            
   When 'MRP' Then       
   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))            
--   When 'Special Price' Then       
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))            
  Else      
  (ISNULL(OpeningDetails.Opening_Value, 0))          
  End,  
    
    "Saleable Stock" = (isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),          
    "Saleable Value" =       
  case @StockVal        
  When 'SalePrice' Then       
  (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))  - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))          
  When 'PurchasePrice' Then       
  (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))          
--   When 'ECP' Then       
--   (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.ECP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))          
   When 'MRP' Then       
   (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.MRP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))          
--   When 'Special Price' Then       
--   (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Company_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))          
  Else      
  (isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))      
  End,      
    "Free OnHand Qty" = isnull(openingdetails.Free_Saleable_Quantity, 0),            
  "Damages Qty" = isnull(openingdetails.Damage_Opening_Quantity,0),            
    "Damages Value" =       
  case @StockVal        
  When 'SalePrice' Then       
  isnull((isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)), 0)          
  When 'PurchasePrice' Then      
  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)), 0)         
--   When 'ECP' Then      
--   isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)          
   When 'MRP' Then      
   isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)          
--   When 'Special Price' Then      
--   isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)          
  Else      
  isnull((openingdetails.Damage_Opening_Value), 0)          
  End,      
    "Purchase Price" = isnull(Items.Purchase_Price,0),  
 "Sale Price" = isnull(Items.Sale_Price, 0),  
    "Manufacturer Name" = Manufacturer.Manufacturer_Name        
  from    Items
  Inner Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
  Left Outer Join UOM On Items.UOM = UOM.UOM            
  Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID            
  Left Outer Join Manufacturer On Manufacturer.ManufacturerID = Items.ManufacturerID                 
  WHERE OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)            
   AND Items.CategoryID = @CATEGORY            
   and Items.active = 1 And ISNULL(OpeningDetails.Opening_Quantity, 0) > 0        
   And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
 END        
 ELSE        
 BEGIN        
  Select  Items.Product_Code, "Item Code" = Items.Product_Code,             
    "Item Name" = Items.ProductName,             
    "Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)            
    + ' ' + CAST(UOM.Description AS nvarchar),             
    "Conversion Unit" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) * Items.ConversionFactor AS Decimal(18,6)) AS nvarchar)            
    + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),            
    "Reporting UOM" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit When 0 then 1 else Items.ReportingUnit End) AS Decimal(18,6)) AS nvarchar)            
    + ' ' + CAST((SELECT Description From UOM Where UOM = Items.ReportingUOM) AS nvarchar),            
  "Total On Hand Value" =       
  case @StockVal        
  When 'SalePrice' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))            
  When 'PurchasePrice' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))            
--   When 'ECP' Then       
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))            
   When 'MRP' Then       
   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))            
--   When 'Special Price' Then       
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))            
  Else      
  (ISNULL(OpeningDetails.Opening_Value, 0))          
  End,    
    "Saleable Stock" = (isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),          
    "Saleable Value" =       
  case @StockVal        
  When 'SalePrice' Then       
  (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))  - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))          
  When 'PurchasePrice' Then       
  (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))          
--   When 'ECP' Then       
--   (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.ECP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))          
   When 'MRP' Then       
   (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.MRP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))          
--   When 'Special Price' Then       
--   (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Company_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))          
  Else      
  (isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))      
  End,      
    "Free OnHand Qty" = isnull(openingdetails.Free_Saleable_Quantity, 0),            
    "Damages Qty" = isnull(openingdetails.Damage_Opening_Quantity,0),            
    "Damages Value" =       
  case @StockVal        
  When 'SalePrice' Then       
  isnull((isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)), 0)          
  When 'PurchasePrice' Then      
  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)), 0)          
--   When 'ECP' Then      
--   isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)          
   When 'MRP' Then      
   isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)          
--   When 'Special Price' Then      
--   isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)          
  Else      
  isnull((openingdetails.Damage_Opening_Value), 0)          
  End,      
 "Purchase Price" = isnull(Items.Purchase_Price,0),  
  "Sale Price" = isnull(Items.Sale_Price, 0),  
    "Manufacturer Name" = Manufacturer.Manufacturer_Name        
  from  Items
  Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
  Left Outer Join UOM On Items.UOM = UOM.UOM            
  Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID            
  Left Outer Join Manufacturer On Manufacturer.ManufacturerID = Items.ManufacturerID                
  WHERE  OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)            
   AND Items.CategoryID = @CATEGORY            
   and Items.active = 1        
   
   And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
 END        
END            
ELSE            
BEGIN            
 IF @ShowItems = 'Items With Stock'        
 BEGIN        
  Select  a.Product_Code, "Item Code" = a.Product_Code, "Item Name" = a.ProductName,             
   "Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar)            
   + ' ' + CAST(UOM.Description AS nvarchar),             
   "Conversion Unit" = CAST(CAST(ISNULL(SUM(Quantity), 0) * a.ConversionFactor AS Decimal(18,6)) AS nvarchar)            
   + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),            
   "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE a.ReportingUnit When 0 then 1 else a.ReportingUnit End) AS Decimal(18,6)) AS nvarchar)            
   + ' ' + CAST((SELECT Description From UOM Where UOM = a.ReportingUOM) AS nvarchar),               
 "Total On Hand Value" =         
  case @StockVal        
  When 'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Sale_Price, 0)) End) End)  
  When 'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Purchase_Price, 0)) End) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.ECP, 0)) End) End)  
   When 'MRP' Then      
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(a.MRP, 0)End)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Company_Price, 0)) End) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End,    
   "Saleable Stock" = isnull((select Sum(Quantity) from batch_products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.CATEGORYID = @CATEGORY And Items.Product_Code = a.Product_Code),0 
  
    
),                      
  "Saleable Value" = Isnull((Select         
  case @StockVal        
  When 'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)  
  When 'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
   When 'MRP' Then      
   isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End   
from batch_products, Items, ItemCategories IC where Items.Product_Code = Batch_Products.Product_Code AND Items.CategoryID = IC.CategoryID and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.CATEGORYID = @CATEGORY         
    And Items.Product_Code = a.Product_Code),0),          
   "Free OnHand Qty" = isnull((select sum(Quantity) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0) <> 0 And Items.CATEGORYID = @CATEGORY  And Items.Product_Code = a.Product_Code),0),            
   "Damages Qty" = isnull((select sum(Quantity) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And Items.CATEGORYID = @CATEGORY  And Items.Product_Code = a.Product_Code),0),            
  "Damages Value" = isnull((select          
  case @StockVal        
  When 'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)  
  When 'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
   When 'MRP' Then      
   isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End          
from Batch_Products, Items, ItemCategories IC where Items.Product_Code = Batch_Products.Product_Code and Items.CategoryID = IC.CategoryID AND isnull(damage,0) <> 0 And Items.CATEGORYID = @CATEGORY  And Items.Product_Code = a.Product_Code),0),         
      
"Purchase Price" = isnull(a.Purchase_Price,0),  
"Sale Price" = isnull(a.Sale_Price, 0),  
   "Manufacturer Name" = Manufacturer.Manufacturer_Name        
  from Items a
  Left Outer Join Batch_Products On a.Product_Code = Batch_Products.Product_Code
  Left Outer Join UOM On a.UOM = UOM.UOM          
  Left Outer Join ConversionTable On a.ConversionUnit = ConversionTable.ConversionID          
  Left Outer Join Manufacturer On Manufacturer.ManufacturerID = a.ManufacturerID        
  Inner Join  ItemCategories IC On a.CategoryID = IC.CategoryID            
  WHERE a.CategoryID = @CATEGORY          
  and a.active = 1         
  And a.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
  GROUP BY a.Product_Code, a.ProductName,          
  a.ConversionUnit, a.ReportingUnit, a.ReportingUOM,          
  UOM.Description, ConversionTable.ConversionUnit, a.ConversionFactor,        
--  a.PTS, a.PTR, a.ECP, Manufacturer.Manufacturer_Name        
 a.Purchase_Price, a.Sale_Price, Manufacturer.Manufacturer_Name        
  HAVING ISNULL(SUM(Quantity), 0) > 0         
 END        
 ELSE     
 BEGIN        
  Select  a.Product_Code, "Item Code" = a.Product_Code, "Item Name" = a.ProductName,         
   "Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar)        
   + ' ' + CAST(UOM.Description AS nvarchar),         
   "Conversion Unit" = CAST(CAST(ISNULL(SUM(Quantity), 0) * a.ConversionFactor AS Decimal(18,6)) AS nvarchar)        
   + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),        
   "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE a.ReportingUnit When 0 then 1 else a.ReportingUnit End) AS Decimal(18,6)) AS nvarchar)        
   + ' ' + CAST((SELECT Description From UOM Where UOM = a.ReportingUOM) AS nvarchar),        
 "Total On Hand Value" =         
  case @StockVal        
  When 'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Sale_Price, 0)) End) End)  
  When 'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Purchase_Price, 0)) End) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.ECP, 0)) End) End)  
   When 'MRP' Then      
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(a.MRP, 0)End)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Company_Price, 0)) End) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End,      
   "Saleable Stock" = isnull((select Sum(Quantity) from batch_products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.CATEGORYID = @CATEGORY And Items.Product_Code = a.Product_Code),0
  
),        
   "Saleable Value" = isnull((select     
  case @StockVal        
  When 'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)  
  When 'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
   When 'MRP' Then      
   isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End        
   from batch_products, Items, ItemCategories IC where Items.Product_Code = Batch_Products.Product_Code and Items.CategoryID = IC.CategoryID AND isnull(free,0)=0 and isnull(damage,0) = 0 And Items.CATEGORYID = @CATEGORY     
    And Items.Product_Code = a.Product_Code),0),      
   "Free OnHand Qty" = isnull((select sum(Quantity) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0) <> 0 And Items.CATEGORYID = @CATEGORY  And Items.Product_Code = a.Product_Code),0),        
   "Damages Qty" = isnull((select sum(Quantity) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And Items.CATEGORYID = @CATEGORY  And Items.Product_Code = a.Product_Code),0),        
   "Damages Value" = isnull((select     
  case @StockVal        
  When 'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)  
  When 'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
   When 'MRP' Then      
   isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End      
   from Batch_Products, Items, ItemCategories IC where Items.Product_Code = Batch_Products.Product_Code and Items.CategoryID = IC.CategoryID AND isnull(damage,0) <> 0 And Items.CATEGORYID = @CATEGORY  And Items.Product_Code = a.Product_Code),0),      
 "Purchase Price" = isnull(a.Purchase_Price,0),  
 "Sale Price" = isnull(a.Sale_Price, 0),  
   "Manufacturer Name" = Manufacturer.Manufacturer_Name    
  from Items a
  Left Outer Join Batch_Products On a.Product_Code = Batch_Products.Product_Code
  Left Outer Join UOM On a.UOM = UOM.UOM      
  Left Outer Join  ConversionTable On a.ConversionUnit = ConversionTable.ConversionID      
  Left Outer Join  Manufacturer On Manufacturer.ManufacturerID = a.ManufacturerID    
  Inner Join ItemCategories IC On a.CategoryID = IC.CategoryID         
  WHERE  a.CategoryID = @CATEGORY      
  and a.active = 1    
  And a.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
  GROUP BY a.Product_Code, a.ProductName,      
  a.ConversionUnit, a.ReportingUnit, a.ReportingUOM,      
  UOM.Description, ConversionTable.ConversionUnit, a.ConversionFactor,    
--  a.PTS, a.PTR, a.ECP, Manufacturer.Manufacturer_Name    
a.Purchase_Price, a.Sale_Price, Manufacturer.Manufacturer_Name    
 END    
END        

Drop Table #tmpProd




