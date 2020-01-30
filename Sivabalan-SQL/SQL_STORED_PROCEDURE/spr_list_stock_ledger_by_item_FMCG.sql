CREATE procedure [dbo].[spr_list_stock_ledger_by_item_FMCG](@FROM_DATE datetime, @ShowItems nvarchar(100), @StockVal nvarchar(100))            
AS            
IF (DATEPART(dy, @FROM_DATE) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FROM_DATE) = DATEPART(yyyy, GETDATE())) OR DATEPART(yyyy, @FROM_DATE) < DATEPART(yyyy, GETDATE())        
BEGIN            
 If @ShowItems = 'Items With Stock'          
 BEGIN          
 Select              
  Items.product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,            
  "Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)             
  + ' ' +  CAST(UOM.Description AS nvarchar) ,             
  "Conversion Unit" = CAST(CAST(Items.ConversionFactor * ISNULL(OpeningDetails.Opening_Quantity, 0) as Decimal(18,6))  AS nvarchar)             
  + ' ' +  CAST(ConversionTable.ConversionID AS nvarchar) ,            
  "Reporting UOM" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6))  AS nvarchar)             
  + ' ' + CAST((Select Description From UOM Where UOM = Items.ReportingUOM)  AS nvarchar) ,            
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
  "Saleable Stock" = openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0),            
   "Saleable Value" =           
  case @StockVal            
  When 'SalePrice' Then           
  (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))              
   When 'PurchasePrice' Then           
   (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))              
--   When 'ECP' Then           
--   (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))              
   When 'MRP' Then           
   (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))              
--   When 'Special Price' Then           
--   (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))              
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
  End        
 from  Items, OpeningDetails, UOM, ConversionTable            
 WHERE              
  Items.Product_Code *= OpeningDetails.Product_Code AND       
  OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)             
  AND Items.UOM *= UOM.UOM            
  And OpeningDetails.Opening_Quantity > 0           
  AND Items.ConversionUnit *= ConversionTable.ConversionID            
  and Items.Active = 1 
 END            
 ELSE          
 BEGIN          
 Select              
  Items.product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,            
  "Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)             
  + ' ' +  CAST(UOM.Description AS nvarchar) ,             
  "Conversion Unit" = CAST(CAST(Items.ConversionFactor * ISNULL(OpeningDetails.Opening_Quantity, 0) as Decimal(18,6))  AS nvarchar)             
  + ' ' +  CAST(ConversionTable.ConversionID AS nvarchar) ,            
  "Reporting UOM" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6))  AS nvarchar)             
  + ' ' + CAST((Select Description From UOM Where UOM = Items.ReportingUOM)  AS nvarchar) ,            
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
  "Saleable Stock" = openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0),            
  "Saleable Value" =       
   case @StockVal        
   When 'SalePrice' Then       
   (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))  - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))          
    When 'PurchasePrice' Then       
    (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))          
--    When 'ECP' Then       
--    (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.PTS, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))          
    When 'MRP' Then       
    (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.MRP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))          
--    When 'Special Price' Then       
--    (isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Company_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))          
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
  End         
 from  Items, OpeningDetails, UOM, ConversionTable, ItemCategories IC               
 WHERE              
  Items.Product_Code *= OpeningDetails.Product_Code AND             
  OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)             
  AND IC.CategoryID = Items.CategoryID    
  AND Items.UOM *= UOM.UOM            
  AND Items.ConversionUnit *= ConversionTable.ConversionID           
  and Items.Active = 1 
 END          
END          
ELSE            
BEGIN            
 IF @ShowItems = 'Items with stock'          
 BEGIN          
 Select  I1.product_Code, "Item Code" = I1.Product_Code, "Item Name" = I1.ProductName,            
  "Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar)             
  + ' ' +  CAST(UOM.Description AS nvarchar) ,             
  "Conversion Unit" = CAST(CAST(I1.ConversionFactor * ISNULL(SUM(Quantity), 0) AS Decimal(18,6)) AS nvarchar)             
  + ' ' +  CAST(ConversionTable.ConversionUnit AS nvarchar) ,            
  "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)             
  + ' ' + CAST((Select Description From UOM Where UOM = I1.ReportingUOM)  AS nvarchar) ,            
 "Total On Hand Value" =           
  case @StockVal          
  When 'SalePrice'  Then        
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Sale_Price, 0)) End) End)    
   When 'PurchasePrice' Then        
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Purchase_Price, 0)) End) End)    
--   When 'ECP' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.ECP, 0)) End) End)    
   When 'MRP' Then        
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I1.MRP, 0)End)),0)         
--   When 'Special Price' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Company_Price, 0)) End) End)    
  Else        
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)            
  End,      
  "Saleable Stock" = (select isnull(Sum(Quantity),0) from batch_products, Items  where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And items.product_code = i1.Product_code),            
  "Saleable Value" = (Select         
  case @StockVal          
  When 'SalePrice' Then         
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End )    
  When 'PurchasePrice' Then          
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End )    
--   When 'ECP' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End )    
   When 'MRP' Then          
   isnull(Sum(isnull(Quantity, 0) * Isnull(Items.MRP, 0)),0)                
--   When 'Special Price' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End )    
  Else        
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End        
 from batch_products, Items, ItemCategories IC  where Items.Product_Code = Batch_Products.Product_Code and Items.CategoryID = IC.CategoryID and isnull(free,0)=0 and isnull(damage,0) = 0 And items.product_code = i1.Product_code),            
  "Free OnHand Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items  where Items.Product_Code = Batch_Products.Product_Code and free <> 0 And items.product_code = i1.Product_code),            
  "Damages Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items  where Items.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And items.product_code = i1.Product_code),            
  "Damages Value" = (select        
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
 from Items, Batch_Products, ItemCategories IC  where Items.Product_Code = Batch_Products.Product_Code And Items.CategoryID = IC.CategoryID and isnull(damage,0) <> 0 And items.product_code = i1.Product_code)                 
 from  Items I1, Batch_Products, UOM, ConversionTable, ItemCategories IC             
 WHERE  I1.Product_Code *= Batch_Products.Product_Code            
  AND I1.CategoryID = IC.CategoryID    
  AND I1.UOM *= UOM.UOM            
  AND I1.ConversionUnit *= ConversionTable.ConversionID            
  and I1.Active = 1          
 GROUP BY            
  I1.Product_Code, I1.ProductName, UOM.Description, I1.ConversionFactor,            
  ConversionTable.ConversionUnit, I1.ReportingUnit, I1.ReportingUOM            
 HAVING ISNULL(SUM(Quantity), 0) > 0          
 END          
 ELSE          
 BEGIN          
 Select  I1.product_Code, "Item Code" = I1.Product_Code, "Item Name" = I1.ProductName,            
  "Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar)             
  + ' ' +  CAST(UOM.Description AS nvarchar) ,             
  "Conversion Unit" = CAST(CAST(I1.ConversionFactor * ISNULL(SUM(Quantity), 0) AS Decimal(18,6)) AS nvarchar)             
  + ' ' +  CAST(ConversionTable.ConversionUnit AS nvarchar) ,      
 "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)             
  + ' ' + CAST((Select Description From UOM Where UOM = I1.ReportingUOM)  AS nvarchar) ,            
 "Total On Hand Value" =           
  case @StockVal         
  When 'SalePrice'  Then        
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Sale_Price, 0)) End) End)    
  When 'PurchasePrice' Then        
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Purchase_Price, 0)) End) End)    
--   When 'ECP' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.ECP, 0)) End) End)    
   When 'MRP' Then        
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I1.MRP, 0)End)),0)         
--   When 'Special Price' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Company_Price, 0)) End) End)    
  Else        
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)            
  End,          
  "Saleable Stock" = (select isnull(Sum(Quantity),0) from batch_products, Items  where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And items.product_code = i1.Product_code),            
  "Saleable Value" = (Select         
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
  from batch_products, Items, ItemCategories IC  where Items.Product_Code = Batch_Products.Product_Code And Items.CategoryID = IC.CategoryID and  isnull(free,0)=0 and isnull(damage,0) = 0 And items.product_code = i1.Product_code),            
  "Free OnHand Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items  where Items.Product_Code = Batch_Products.Product_Code and free <> 0 And items.product_code = i1.Product_code),            
  "Damages Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items  where Items.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And items.product_code = i1.Product_code),            
  "Damages Value" = (select        
  case @StockVal          
  When 'SalePrice'  Then        
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)    
  When 'PurchasePrice' Then        
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)    
--  When 'ECP' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)    
   When 'MRP' Then        
   isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)         
--   When 'Special Price' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)    
  Else        
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)            
  End    
  from Items, Batch_Products, ItemCategories IC where Items.Product_Code = Batch_Products.Product_Code and IC.CategoryID = Items.CategoryID and isnull(damage,0) <> 0 And items.product_code = i1.Product_code)                     
 from  Items I1, Batch_Products, UOM, ConversionTable, ItemCategories IC            
 WHERE  I1.Product_Code *= Batch_Products.Product_Code            
  AND I1.UOM *= UOM.UOM            
  AND I1.ConversionUnit *= ConversionTable.ConversionID            
  AND IC.CategoryID = I1.CategoryID    
  and I1.Active = 1          
 GROUP BY            
  I1.Product_Code, I1.ProductName, UOM.Description, I1.ConversionFactor,            
  ConversionTable.ConversionUnit, I1.ReportingUnit, I1.ReportingUOM                     
 END            
END
