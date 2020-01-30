CREATE procedure [dbo].[spr_list_stock_ledger_by_categorys_fmcg](@CATEGORY nvarchar(2550), @FROM_DATE datetime,         
@ShowItems nvarchar(50), @StockVal nvarchar(100))                      
AS                    
DECLARE @UOMCOUNT int                    
DECLARE @REPORTINGCOUNT int                    
DECLARE @CONVERSIONCOUNT int                    
declare @UOMDESC nvarchar(50)                    
declare @ReportingUOM nvarchar(50)                    
declare @ConversionUnit nvarchar(50)                    
        
Declare @Delimeter as Char(1)          
Set @Delimeter=Char(15)          
Create table #tmpCategory(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @CATEGORY='%'           
   Insert into #tmpCategory select Category_Name from ItemCategories          
Else          
   Insert into #tmpCategory select * from dbo.sp_SplitIn2Rows(@CATEGORY,@Delimeter)          
        
                    
IF (DATEPART(dy, @FROM_DATE) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FROM_DATE) = DATEPART(yyyy, GETDATE())) Or  DATEPART(yyyy, @FROM_DATE) < DATEPART(yyyy, GETDATE())                   
BEGIN                    
  select @UOMCOUNT = Count(DISTINCT Items.UOM) FROM Items, OpeningDetails, ItemCategories                    
  WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
  AND Items.CategoryID = ItemCategories.CategoryID AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)         
                  
  select @REPORTINGCOUNT = Count(DISTINCT Items.ReportingUOM) FROM Items, OpeningDetails, ItemCategories                    
  WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
  AND Items.CategoryID = ItemCategories.CategoryID AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)
                  
  select @CONVERSIONCOUNT = Count(DISTINCT Items.ConversionUnit) FROM Items, OpeningDetails, ItemCategories                    
  WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
  AND Items.CategoryID = ItemCategories.CategoryID AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)                   
                 
 IF @UOMCOUNT <= 1 and @REPORTINGCOUNT <= 1 and @CONVERSIONCOUNT <= 1                    
 BEGIN                    
  SELECT Top 1 @UOMDESC = UOM.Description FROM Items, OpeningDetails, ItemCategories, UOM                    
  WHERE Items.Product_Code *= OpeningDetails.Product_Code                     
  AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
  AND Items.CategoryID = ItemCategories.CategoryID                     
  AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory) 
  AND Items.UOM *= UOM.UOM                    
  SELECT Top 1 @ReportingUOM = UOM.Description FROM Items, OpeningDetails, ItemCategories, UOM                    
  WHERE Items.Product_Code *= OpeningDetails.Product_Code                     
  AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
  AND Items.CategoryID = ItemCategories.CategoryID                     
  AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory) 
  AND Items.ReportingUOM *= UOM.UOM                    
  SELECT Top 1 @ConversionUnit = ConversionTable.ConversionUnit                     
  FROM Items, OpeningDetails, ItemCategories, ConversionTable                    
  WHERE Items.Product_Code *= OpeningDetails.Product_Code                     
  AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE) 
  AND Items.CategoryID = ItemCategories.CategoryID                     
  AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)      
  AND Items.ConversionUnit *= ConversionTable.ConversionID                    
  IF @ShowItems = 'Items with stock'                
  BEGIN                
   Select  Items.CategoryID,                    
   "Category" = ItemCategories.Category_Name,                     
   "Total On Hand Qty" = CAST(ISNULL(SUM(OpeningDetails.Opening_Quantity), 0) AS nvarchar)   + ' ' + @UOMDESC,                     
   "Conversion Unit" = CAST(CAST(SUM(Items.ConversionFactor * ISNULL(OpeningDetails.Opening_Quantity, 0)) AS Decimal(18,6)) AS nvarchar)   + ' ' + @ConversionUnit,                    
    "Reporting UOM" = SubString(
   CAST(CAST(SUM(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1, 
   CharIndex('.', CAST(CAST(SUM(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
  + '.' + 
  CAST(Sum(Cast(ISNULL(OpeningDetails.Opening_Quantity, 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)
  + ' ' + @ReportingUOM,
--    "Reporting UOM" = CAST(CAST(SUM(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)   + ' ' + @ReportingUOM,                    
  "Total On Hand Value" =             
  case @StockVal              
  When 'PurchasePrice' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))                  
  When 'SalePrice' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))                  
--   When 'ECP' Then             
--   Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))                  
  When 'MRP' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))                  
--   When 'Special Price' Then             
--   Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))                  
  Else            
  Sum(ISNULL(OpeningDetails.Opening_Value, 0))                
  End,             
   "Saleable Stock" = sum(isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),                  
   "Saleable Value" =               
 case @StockVal                
 When 'PurchasePrice' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))                  
 When 'SalePrice' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))                  
--  When 'ECP' Then               
--  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))                  
 When 'MRP' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))                  
--  When 'Special Price' Then               
--  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))                  
 Else              
 sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))              
 End,              
   "Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity ), 0),  
   "Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),                    
    "Damages Value" =             
 case @StockVal              
 When 'PurchasePrice' Then             
 isnull(Sum(isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)), 0)                
 When 'SalePrice' Then            
 isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)), 0)                
--  When 'ECP' Then            
-- isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)                
 When 'MRP' Then            
 isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0) 
--  When 'Special Price' Then            
--  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)                
 Else            
 isnull(Sum(openingdetails.Damage_Opening_Value), 0)                
 End            
   from  Items, OpeningDetails, ItemCategories                    
   WHERE   Items.Product_Code *= OpeningDetails.Product_Code                     
   AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
   AND Items.CategoryID = ItemCategories.CategoryID                     
   AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)        
   and ItemCategories.active = 1                
   GROUP BY Items.CategoryID, ItemCategories.Category_Name                    
   HAVING ISNULL(SUM(OpeningDetails.Opening_Quantity), 0) > 0                
  END                
  ELSE                
  BEGIN               
   Select  Items.CategoryID,                    
   "Category" = ItemCategories.Category_Name,                     
   "Total On Hand Qty" = CAST(ISNULL(SUM(OpeningDetails.Opening_Quantity), 0) AS nvarchar)   + ' ' + @UOMDESC,                     
    "Conversion Unit" = CAST(CAST(SUM(Items.ConversionFactor * ISNULL(OpeningDetails.Opening_Quantity, 0)) AS Decimal(18,6)) AS nvarchar)   + ' ' + @ConversionUnit,                    
    "Reporting UOM" = 
  SubString(
   CAST(CAST(SUM(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1, 
   CharIndex('.', CAST(CAST(SUM(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
  + '.' + 
  CAST(Sum(Cast(ISNULL(OpeningDetails.Opening_Quantity, 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)
  + ' ' + @ReportingUOM,
--    "Reporting UOM" = CAST(CAST(SUM(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)   + ' ' + @ReportingUOM,                    
  "Total On Hand Value" =             
  case @StockVal              
  When 'PurchasePrice' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))                  
  When 'SalePrice' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))                  
--   When 'ECP' Then             
--   Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))                  
  When 'MRP' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))                  
--   When 'Special Price' Then             
--   Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))                  
  Else            
  Sum(ISNULL(OpeningDetails.Opening_Value, 0))                
  End,            
   "Saleable Stock" = sum(isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),                  
   "Saleable Value" =               
 case @StockVal                
 When 'PurchasePrice' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))                  
 When 'SalePrice' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))                  
--  When 'ECP' Then               
--  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))                  
 When 'MRP' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))                  
--  When 'Special Price' Then               
--  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))                  
 Else              
 sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))              
 End,              
   "Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity ), 0),                    
   "Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),                    
    "Damages Value" =             
 case @StockVal              
 When 'PurchasePrice' Then             
 isnull(Sum(isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)), 0)                
 When 'SalePrice' Then            
 isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)), 0)                
--  When 'ECP' Then            
--  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)               
 When 'MRP' Then            
 isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)                
--  When 'Special Price' Then            
--  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)                
 Else            
 isnull(Sum(openingdetails.Damage_Opening_Value), 0)                
 End            
   from  Items, OpeningDetails, ItemCategories                    
   WHERE   Items.Product_Code *= OpeningDetails.Product_Code                     
   AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
   AND Items.CategoryID = ItemCategories.CategoryID                     
   AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)                    
   and ItemCategories.active = 1                
   GROUP BY Items.CategoryID, ItemCategories.Category_Name                    
  END                
 END                    
 ELSE                    
 BEGIN                    
  IF @ShowItems = 'Items with stock'                
  BEGIN                
   Select  Items.CategoryID,                   
   "Category" = ItemCategories.Category_Name,                     
   "Total On Hand Qty" = ISNULL(SUM(OpeningDetails.Opening_Quantity), 0),                    
   "Conversion Unit" = Null,                     
   "Reporting UOM" = Null,                    
  "Total On Hand Value" =             
  case @StockVal              
  When 'PurchasePrice' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))                  
  When 'SalePrice' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))                  
--   When 'ECP' Then        
--   Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))                  
  When 'MRP' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))                  
--   When 'Special Price' Then             
--   Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))                  
  Else            
  Sum(ISNULL(OpeningDetails.Opening_Value, 0))                
  End,                    
        
   "Saleable Stock" = sum(isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),                  
            
   "Saleable Value" =               
 case @StockVal                
 When 'PurchasePrice' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))                  
 When 'SalePrice' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))                  
--  When 'ECP' Then               
--  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))                  
 When 'MRP' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))                  
--  When 'Special Price' Then               
--  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))                  
 Else              
 sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))              
 End,              
   "Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity ), 0),                    
   "Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),                    
    "Damages Value" =             
 case @StockVal              
 When 'PurchasePrice' Then             
 isnull(Sum(isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)), 0)                
 When 'SalePrice' Then            
 isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)), 0)                
--  When 'ECP' Then            
--  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)                
 When 'MRP' Then            
 isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)                
--  When 'Special Price' Then            
--  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)                
 Else            
 isnull(Sum(openingdetails.Damage_Opening_Value), 0)                
 End             
   from    Items, OpeningDetails, ItemCategories                    
   WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
   AND Items.CategoryID = ItemCategories.CategoryID AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory) 
  and ItemCategories.active = 1                
   GROUP BY Items.CategoryID, ItemCategories.Category_Name                    
   HAVING ISNULL(SUM(OpeningDetails.Opening_Quantity), 0) > 0                
  END                
  ELSE                
  BEGIN                
   Select  Items.CategoryID,                   
   "Category" = ItemCategories.Category_Name,                     
   "Total On Hand Qty" = ISNULL(SUM(OpeningDetails.Opening_Quantity), 0),                    
   "Conversion Unit" = Null,                     
   "Reporting UOM" = Null,                    
  "Total On Hand Value" =             
  case @StockVal              
  When 'PurchasePrice' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))                  
  When 'SalePrice' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))                  
--   When 'ECP' Then             
--   Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))                  
  When 'MRP' Then             
  Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))                  
--   When 'Special Price' Then             
--   Sum((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))                  
  Else            
  Sum(ISNULL(OpeningDetails.Opening_Value, 0))                
  End,                
   "Saleable Stock" = sum(isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),                  
   "Saleable Value" =               
 case @StockVal                
 When 'PurchasePrice' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))                  
 When 'SalePrice' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))                  
--  When 'ECP' Then               
--  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))                  
 When 'MRP' Then               
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))                  
--  When 'Special Price' Then        
--  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))                  
 Else              
 sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))              
 End,               
   "Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity ), 0),                    
   "Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),                    
    "Damages Value" =             
 case @StockVal              
 When 'PurchasePrice' Then             
 isnull(Sum(isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)), 0)                
 When 'SalePrice' Then            
 isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)), 0)                
--  When 'ECP' Then            
--  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)                
 When 'MRP' Then            
 isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)                
--  When 'Special Price' Then            
--  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)                
 Else            
 isnull(Sum(openingdetails.Damage_Opening_Value), 0)     
 End        
   from    Items, OpeningDetails, ItemCategories                    
   WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
   AND Items.CategoryID = ItemCategories.CategoryID AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory) 
   and ItemCategories.active = 1                
   GROUP BY Items.CategoryID, ItemCategories.Category_Name                    
  END                
 END                    
END                    
ELSE                    
BEGIN                    
 select @UOMCOUNT = Count(DISTINCT Items.UOM) FROM Items, Batch_Products, ItemCategories                    
 WHERE Items.CategoryID = ItemCategories.CategoryID AND Items.Product_Code *= Batch_Products.Product_Code 
 AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)
                 
 select @REPORTINGCOUNT = Count(DISTINCT Items.ReportingUOM) FROM Items, Batch_Products, ItemCategories                    
 WHERE Items.CategoryID = ItemCategories.CategoryID AND Items.Product_Code *= Batch_Products.Product_Code                    
 AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)
                 
 select @CONVERSIONCOUNT = Count(DISTINCT Items.ConversionUnit) FROM Items, Batch_Products, ItemCategories                    
 WHERE Items.CategoryID = ItemCategories.CategoryID AND Items.Product_Code *= Batch_Products.Product_Code                    
 AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)
                 
 IF @UOMCOUNT <= 1 and @REPORTINGCOUNT <= 1 and @CONVERSIONCOUNT <= 1                    
 BEGIN                    
  SELECT Top 1 @UOMDESC = UOM.Description FROM Items, OpeningDetails, ItemCategories, UOM                    
  WHERE Items.Product_Code *= OpeningDetails.Product_Code                     
  AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
  AND Items.CategoryID = ItemCategories.CategoryID                     
  AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)
  AND Items.UOM *= UOM.UOM                    
  SELECT Top 1 @ReportingUOM = UOM.Description FROM Items, OpeningDetails, ItemCategories, UOM                    
  WHERE Items.Product_Code *= OpeningDetails.Product_Code                     
  AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
  AND Items.CategoryID = ItemCategories.CategoryID                     
  AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)                    
  AND Items.ReportingUOM *= UOM.UOM                    
  SELECT Top 1 @ConversionUnit = ConversionTable.ConversionUnit                     
  FROM Items, OpeningDetails, ItemCategories, ConversionTable                    
  WHERE Items.Product_Code *= OpeningDetails.Product_Code                     
  AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                    
  AND Items.CategoryID = ItemCategories.CategoryID                     
  AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)                    
  AND Items.ConversionUnit *= ConversionTable.ConversionID                    
  IF @ShowItems = 'Items with stock'                
  BEGIN                
   Select  ItemCategories.CategoryID, "Category" = ItemCategories.Category_Name,                    
   "Total On Hand Qty" = CAST(ISNULL(SUM(QUANTITY), 0) AS nvarchar)   + ' ' + @UOMDESC,                  
   "Conversion Unit" = CAST(CAST(SUM(ISNULL(QUANTITY, 0) * I1.ConversionFactor) AS Decimal(18,6)) AS nvarchar)   + ' ' + @ConversionUnit,                  
   "Reporting UOM" = 
  SubString(
   CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1, 
   CharIndex('.', CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
  + '.' + 
  CAST(Sum(Cast(ISNULL(QUANTITY, 0) As Int)) % Avg(Cast((CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END) As Int)) AS nvarchar)
  + ' ' + @ReportingUOM,
--  "Reporting UOM" = CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)   + ' ' + @ReportingUOM,                    
 "Total On Hand Value" =               
  case @StockVal              
  When 'PurchasePrice'  Then        
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Purchase_Price, 0)) End) End) 
  When 'SalePrice' Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Sale_Price, 0)) End) End)        
--   When 'ECP' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.ECP, 0)) End) End)        
  When 'MRP' Then            
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I1.MRP, 0)End)),0)             
--   When 'Special Price' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Company_Price, 0)) End) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End,         
   "Saleable Stock" = isnull((select isnull(Sum(Quantity),0)                     
   From batch_products, Items, ItemCategories C1                     
   Where Items.Product_Code = Batch_Products.Product_Code                     
   And isnull(free,0)=0 and isnull(damage,0) = 0                     
   And Items.CategoryID = C1.CategoryID                     
   And C1.CategoryID = ItemCategories.CategoryID                    
   Group By Items.CategoryID, C1.Category_Name)  ,0),                  
   "Saleable Value" = isnull((select           
  case @StockVal              
  When 'PurchasePrice'  Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)        
  When 'SalePrice' Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)        
--   When 'ECP' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)        
  When 'MRP' Then            
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)             
--   When 'Special Price' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End          
   From batch_products, Items, ItemCategories C1                     
   Where Items.Product_Code = Batch_Products.Product_Code                     
   And isnull(free,0)=0 and isnull(damage,0) = 0                     
   And Items.CategoryID = C1.CategoryID                     
   And C1.CategoryID = ItemCategories.CategoryID                    
   Group By Items.CategoryID, C1.Category_Name)  ,0),                  
   "Free OnHand Qty" = isnull((select isnull(sum(Quantity),0)  from Batch_Products, Items, ItemCategories C1                     
   where Items.Product_Code = Batch_Products.Product_Code                     
   And free <> 0 And Items.CategoryID = C1.CategoryID         
   And C1.CategoryID = ItemCategories.CategoryID                    
   Group By Items.CategoryID, C1.Category_Name),  0),                  
   "Damages Qty" = isnull((select isnull(sum(Quantity),0)    from Batch_Products, Items, ItemCategories C1                     
   where Items.Product_Code = Batch_Products.Product_Code                     
   and isnull(damage,0) <> 0 And Items.CategoryID = C1.CategoryID                     
   And C1.CategoryID = ItemCategories.CategoryID                    
   Group By Items.CategoryID, C1.Category_Name),  0),                  
  "Damages Value" = isnull((select              
  case @StockVal              
  When 'PurchasePrice'  Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)        
  When 'SalePrice' Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)        
--   When 'ECP' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)        
  When 'MRP' Then            
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)             
--   When 'Special Price' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End           
   from Items, Batch_Products, ItemCategories C1                   
   where Items.Product_Code = Batch_Products.Product_Code                     
   And isnull(damage,0) <> 0 And Items.CategoryID = C1.CategoryID                     
   And C1.CategoryID = ItemCategories.CategoryID                    
   Group By Items.CategoryID, C1.Category_Name),  0)                  
   ----------------                    
   from Items I1, Batch_Products, ItemCategories                    
   WHERE I1.CategoryID = ItemCategories.CategoryID                     
   AND I1.Product_Code *= Batch_Products.Product_Code                    
   AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory) 
   and ItemCategories.active = 1                
   GROUP BY ItemCategories.CategoryID, ItemCategories.Category_Name                    
   HAVING ISNULL(SUM(QUANTITY), 0) > 0                
  END                
  ELSE                
  BEGIN                
   Select  ItemCategories.CategoryID, "Category" = ItemCategories.Category_Name,                    
   "Total On Hand Qty" = CAST(ISNULL(SUM(QUANTITY), 0) AS nvarchar)   + ' ' + @UOMDESC,                  
   "Conversion Unit" = CAST(CAST(SUM(ISNULL(QUANTITY, 0) * I1.ConversionFactor) AS Decimal(18,6)) AS nvarchar)   + ' ' + @ConversionUnit, 
   "Reporting UOM" = 
  SubString(
   CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1, 
   CharIndex('.', CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
  + '.' + 
  CAST(Sum(Cast(ISNULL(QUANTITY, 0) As Int)) % Avg(Cast((CASE I1.ReportingUnit WHEN 0 THEN 1 ELSE I1.ReportingUnit END) As Int)) AS nvarchar)
  + ' ' + @ReportingUOM,
   --Cast (dbo.sp_Get_ReportingUOMQty((Select Product_Code From Items Where CategoryID = ItemCategories.CategoryID), SUM(ISNULL(QUANTITY, 0))) As nvarchar ) + ' ' + @ReportingUOM,
  "Total On Hand Value" =               
  case @StockVal              
  When 'PurchasePrice'  Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Purchase_Price, 0)) End) End)        
  When 'SalePrice' Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Sale_Price, 0)) End) End)        
--   When 'ECP' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.ECP, 0)) End) End)        
  When 'MRP' Then            
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I1.MRP, 0)End)),0)             
--   When 'Special Price' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Company_Price, 0)) End) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End,              
   "Saleable Stock" = isnull((select isnull(Sum(Quantity),0)                     
   From batch_products, Items, ItemCategories C1                     
   Where Items.Product_Code = Batch_Products.Product_Code                     
   And isnull(free,0)=0 and isnull(damage,0) = 0                     
   And Items.CategoryID = C1.CategoryID                     
   And C1.CategoryID = ItemCategories.CategoryID                    
   Group By Items.CategoryID, C1.Category_Name)  ,0),                  
   "Saleable Value" = isnull((Select          
  case @StockVal              
  When 'PurchasePrice'  Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)        
  When 'SalePrice' Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)        
--   When 'ECP' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)        
  When 'MRP' Then            
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)             
--   When 'Special Price' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End          
   From batch_products, Items, ItemCategories C1                     
   Where Items.Product_Code = Batch_Products.Product_Code                     
   And isnull(free,0)=0 and isnull(damage,0) = 0                     
   And Items.CategoryID = C1.CategoryID          
   And C1.CategoryID = ItemCategories.CategoryID                    
   Group By Items.CategoryID, C1.Category_Name)  ,0),                  
   "Free OnHand Qty" = isnull((select isnull(sum(Quantity),0)  from Batch_Products, Items, ItemCategories C1                     
   where Items.Product_Code = Batch_Products.Product_Code                     
   And free <> 0 And Items.CategoryID = C1.CategoryID                     
   And C1.CategoryID = ItemCategories.CategoryID     
   Group By Items.CategoryID, C1.Category_Name),  0),                  
   "Damages Qty" = isnull((select isnull(sum(Quantity),0)    from Batch_Products, Items, ItemCategories C1                     
   where Items.Product_Code = Batch_Products.Product_Code                 
   and isnull(damage,0) <> 0 And Items.CategoryID = C1.CategoryID                     
   And C1.CategoryID = ItemCategories.CategoryID        
   Group By Items.CategoryID, C1.Category_Name),  0),                  
  "Damages Value" = isnull((select              
  case @StockVal              
  When 'PurchasePrice'  Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)        
  When 'SalePrice' Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)        
--   When 'ECP' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)        
  When 'MRP' Then            
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)             
--   When 'Special Price' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)        
Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End           
   from Items, Batch_Products, ItemCategories C1                     
   where Items.Product_Code = Batch_Products.Product_Code                     
   And isnull(damage,0) <> 0 And Items.CategoryID = C1.CategoryID                     
   And C1.CategoryID = ItemCategories.CategoryID                    
   Group By Items.CategoryID, C1.Category_Name),  0)                  
   from Items I1, Batch_Products, ItemCategories                    
   WHERE I1.CategoryID = ItemCategories.CategoryID                     
   AND I1.Product_Code *= Batch_Products.Product_Code                    
   AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)
   and ItemCategories.active = 1                
   GROUP BY ItemCategories.CategoryID, ItemCategories.Category_Name
  END                
 END                    
 ELSE                    
 BEGIN                   
  IF @ShowItems = 'Items with stock'    
  BEGIN                 
  Select  ItemCategories.CategoryID,                   
  "Category" = ItemCategories.Category_Name,                    
  "Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0),                     
  "Conversion Unit" = Null,                     
  "Reporting UOM" = Null,                    
 "Total On Hand Value" =               
  case @StockVal              
  When 'PurchasePrice'  Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Purchase_Price, 0)) End) End)        
  When 'SalePrice' Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Sale_Price, 0)) End) End)        
--   When 'ECP' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.ECP, 0)) End) End)        
  When 'MRP' Then            
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I1.MRP, 0)End)),0)             
--   When 'Special Price' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Company_Price, 0)) End) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End,             
  "Saleable Stock" = isnull((select isnull(Sum(Quantity),0)                     
  from batch_products, Items, ItemCategories C1                    
  where Items.Product_Code = Batch_Products.Product_Code                     
  and isnull(free,0)=0 and isnull(damage,0) = 0                     
  And Items.CategoryID = C1.CategoryID              
  And C1.CategoryID = ItemCategories.CategoryID                    
  Group By Items.CategoryID, C1.Category_Name) ,0),                  
  "Saleable Value" = Isnull((Select               
  case @StockVal              
  When 'PurchasePrice'  Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)        
  When 'SalePrice' Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)        
--   When 'ECP' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)        
  When 'MRP' Then            
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)             
--   When 'Special Price' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End          
  from batch_products, Items, ItemCategories C1                     
  where Items.Product_Code = Batch_Products.Product_Code                     
  and isnull(free,0)=0 and isnull(damage,0) = 0                     
  And Items.CategoryID = C1.CategoryID                     
  And C1.CategoryID = ItemCategories.CategoryID                    
  Group By Items.CategoryID, C1.Category_Name) ,0),                  
  "Free OnHand Qty" = isnull((select isnull(sum(Quantity),0)                     
  from Batch_Products, Items, ItemCategories C1                     
  where Items.Product_Code = Batch_Products.Product_Code                     
  and free <> 0 And Items.CategoryID = C1.CategoryID                     
  And C1.CategoryID = ItemCategories.CategoryID                    
  Group By Items.CategoryID, C1.Category_Name), 0),                  
  "Damages Qty" = isnull((select isnull(sum(Quantity),0)                     
  from Batch_Products, Items, ItemCategories C1                      
  where Items.Product_Code = Batch_Products.Product_Code                     
  and isnull(damage,0) <> 0 And Items.CategoryID = C1.CategoryID                     
  And C1.CategoryID = ItemCategories.CategoryID                    
  Group By Items.CategoryID, C1.Category_Name),0),                    
  "Damages Value" = isnull((select              
  case @StockVal              
  When 'PurchasePrice'  Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)        
  When 'SalePrice' Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)        
--   When 'ECP' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End) 
  When 'MRP' Then    
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)             
--   When 'Special Price' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End      
  from Items, Batch_Products, ItemCategories C1                     
  where Items.Product_Code = Batch_Products.Product_Code                     
  and isnull(damage,0) <> 0 And Items.CategoryID = C1.CategoryID                     
  And C1.CategoryID = ItemCategories.CategoryID                    
  Group By Items.CategoryID, C1.Category_Name),0)                  
  from Items I1 , Batch_Products, ItemCategories                    
  WHERE  I1.CategoryID = ItemCategories.CategoryID                   
  AND I1.Product_Code *= Batch_Products.Product_Code                    
  AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)                    
  and ItemCategories.active = 1                
  GROUP BY ItemCategories.CategoryID, ItemCategories.Category_Name                       
  HAVING ISNULL(SUM(QUANTITY), 0) > 0                
  END                
  ELSE                
  BEGIN                
  Select  ItemCategories.CategoryID,                   
  "Category" = ItemCategories.Category_Name,                    
  "Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0),                     
  "Conversion Unit" = Null,                     
  "Reporting UOM" = Null,                    
 "Total On Hand Value" =               
  case @StockVal              
  When 'PurchasePrice'  Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Purchase_Price, 0)) End) End)        
  When 'SalePrice' Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Sale_Price, 0)) End) End)        
--   When 'ECP' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.ECP, 0)) End) End)        
  When 'MRP' Then            
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I1.MRP, 0)End)),0)             
--   When 'Special Price' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I1.Company_Price, 0)) End) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End,              
  "Saleable Stock" = isnull((select isnull(Sum(Quantity),0)                     
  from batch_products, Items, ItemCategories C1 where Items.Product_Code = Batch_Products.Product_Code                     
  and isnull(free,0)=0 and isnull(damage,0) = 0                     
  And Items.CategoryID = C1.CategoryID                     
  And C1.CategoryID = ItemCategories.CategoryID                    
  Group By Items.CategoryID, C1.Category_Name) ,0),                  
  "Saleable Value" = Isnull((Select               
  case @StockVal              
  When 'PurchasePrice'  Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)        
  When 'SalePrice' Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)        
--   When 'ECP' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)        
  When 'MRP' Then            
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)             
--   When 'Special Price' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End                
  from batch_products, Items, ItemCategories C1                     
  where Items.Product_Code = Batch_Products.Product_Code                     
  and isnull(free,0)=0 and isnull(damage,0) = 0                     
  And Items.CategoryID = C1.CategoryID                     
  And C1.CategoryID = ItemCategories.CategoryID                    
  Group By Items.CategoryID, C1.Category_Name) ,0),            
                  
  "Free OnHand Qty" = isnull((select isnull(sum(Quantity),0)                     
  from Batch_Products, Items, ItemCategories C1                     
  where Items.Product_Code = Batch_Products.Product_Code                     
  and free <> 0 And Items.CategoryID = C1.CategoryID                     
  And C1.CategoryID = ItemCategories.CategoryID                    
  Group By Items.CategoryID, C1.Category_Name), 0),                  
  "Damages Qty" = isnull((select isnull(sum(Quantity),0)                     
  from Batch_Products, Items, ItemCategories C1                      
  where Items.Product_Code = Batch_Products.Product_Code                     
  and isnull(damage,0) <> 0 And Items.CategoryID = C1.CategoryID                     
  And C1.CategoryID = ItemCategories.CategoryID                    
  Group By Items.CategoryID, C1.Category_Name),0),                    
  "Damages Value" = isnull((select              
  case @StockVal              
  When 'PurchasePrice'  Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)        
  When 'SalePrice' Then            
  Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)        
--   When 'ECP' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)        
  When 'MRP' Then            
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)             
--   When 'Special Price' Then            
--   Sum(Case C1.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End               
  from Items, Batch_Products, ItemCategories C1                     
  where Items.Product_Code = Batch_Products.Product_Code                     
  and isnull(damage,0) <> 0 And Items.CategoryID = C1.CategoryID                     
  And C1.CategoryID = ItemCategories.CategoryID                    
  Group By Items.CategoryID, C1.Category_Name),0)                  
  ----------------                    
  from Items I1 , Batch_Products, ItemCategories                    
  WHERE  I1.CategoryID = ItemCategories.CategoryID                   
  AND I1.Product_Code *= Batch_Products.Product_Code                    
  AND ItemCategories.Category_Name In (Select Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCategory)
  and ItemCategories.active = 1      
  GROUP BY ItemCategories.CategoryID, ItemCategories.Category_Name                 
  END                
 END                    
END                  
              
Drop table #tmpCategory
