CREATE procedure [dbo].[spr_list_stock_ledger_by_item_mUOM](@FROM_DATE datetime,     
                                                    @ShowItems nvarchar(100),     
                                                 @StockVal nvarchar(100),     
                                                    @ItemCode nvarchar(2550))      
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
 If @ShowItems = N'Items With Stock'          
 BEGIN          
 Select Items.product_Code,     
 "Item Code" = Items.Product_Code,     
 "Item Name" = Items.ProductName,        
 "Total On Hand Qty UOM3" = IsNull(CAST(dbo.GetFirstLevelUOMQty(Items.Product_Code, ISNULL(OpeningDetails.Opening_Quantity, 0)) AS nvarchar)         
 + N' ' +  CAST(UOM3.Description AS nvarchar), 0),          
 "Total On Hand Qty UOM2" = IsNull(CAST(dbo.GetSecondLevelUOMQty(Items.Product_Code, ISNULL(OpeningDetails.Opening_Quantity, 0)) AS nvarchar)         
 + N' ' +  CAST(UOM2.Description AS nvarchar), 0),          
 "Total On Hand Qty UOM1" = IsNull(CAST(dbo.GetLastLevelUOMQty(Items.Product_Code, ISNULL(OpeningDetails.Opening_Quantity, 0)) AS nvarchar)         
 + N' ' +  CAST(UOM1.Description AS nvarchar), 0),          
 "Conversion Unit" = IsNull(CAST(CAST(Items.ConversionFactor * ISNULL(OpeningDetails.Opening_Quantity, 0) as Decimal(18,6))  AS nvarchar)         
 + N' ' +  CAST(ConversionTable.ConversionUnit AS nvarchar), 0),        
    "Reporting UOM" = IsNull(Cast(dbo.sp_Get_ReportingUOMQty(Items.Product_Code, ISNULL(OpeningDetails.Opening_Quantity, 0)) As nvarchar)    
    
--  "Reporting UOM" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6))  AS nvarchar)         
 + N' ' + CAST((Select Description From UOM Where UOM = Items.ReportingUOM)  AS nvarchar), 0) ,        
-- "Total On Hand Value" = ISNULL(OpeningDetails.Opening_Value, 0),        
      "Total On Hand Value" =         
  case @StockVal          
  When N'PTS' Then         
  ((ISNULL(openingdetails.Opening_Quantity - IsNull(Free_opening_Quantity, 0), 0) * Isnull(Items.PTS, 0)))              
  When N'PTR' Then         
  ((ISNULL(openingdetails.Opening_Quantity - IsNull(Free_opening_Quantity, 0), 0) * Isnull(Items.PTR, 0)))              
--   When 'ECP' Then         
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))              
  When N'ECP' Then         
  ((ISNULL(openingdetails.Opening_Quantity - IsNull(Free_opening_Quantity, 0), 0) * Isnull(Items.ECP, 0)))              
--   When 'Special Price' Then         
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))              
  Else        
  (ISNULL(OpeningDetails.Opening_Value, 0))            
  End,    
 "Saleable Stock UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty(Items.Product_Code, (openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0))) As nvarchar)    
 + N' ' +  CAST(UOM3.Description AS nvarchar), 0),          
 "Saleable Stock UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty(Items.Product_Code, (openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0))) As nvarchar)    
 + N' ' +  CAST(UOM2.Description AS nvarchar), 0),          
 "Saleable Stock UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty(Items.Product_Code, (openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0))) As nvarchar)    
 + N' ' +  CAST(UOM1.Description AS nvarchar), 0),          
-- "Saleable Value" = openingdetails.Opening_Value - IsNull(openingdetails.Damage_Opening_Value,0),        
       "Saleable Value" =           
  case @StockVal            
  When N'PTS' Then           
  (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTS, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTS, 0))              
  When N'PTR' Then           
  (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTR, 0))              
--   When 'ECP' Then           
--   (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))              
  When N'ECP' Then           
  (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))              
--   When 'Special Price' Then           
--   (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))              
  Else          
  (isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))          
  End,        
 "Free OnHand Qty UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty(Items.Product_Code, isnull(openingdetails.Free_Saleable_Quantity, 0)) As nvarchar)    
 + N' ' +  CAST(UOM3.Description AS nvarchar), 0),              
 "Free OnHand Qty UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty(Items.Product_Code, isnull(openingdetails.Free_Saleable_Quantity, 0)) As nvarchar)    
 + N' ' +  CAST(UOM2.Description AS nvarchar), 0),              
 "Free OnHand Qty UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty(Items.Product_Code, isnull(openingdetails.Free_Saleable_Quantity, 0)) As nvarchar)    
 + N' ' +  CAST(UOM1.Description AS nvarchar), 0),    
 "Damages Qty UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty(Items.Product_Code, isnull(openingdetails.Damage_Opening_Quantity,0)) As nvarchar)    
 + N' ' +  CAST(UOM3.Description AS nvarchar), 0),              
 "Damages Qty UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty(Items.Product_Code, isnull(openingdetails.Damage_Opening_Quantity,0)) As nvarchar)    
 + N' ' +  CAST(UOM2.Description AS nvarchar), 0),              
 "Damages Qty UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty(Items.Product_Code, isnull(openingdetails.Damage_Opening_Quantity,0)) As nvarchar)    
 + N' ' +  CAST(UOM1.Description AS nvarchar), 0),              
-- "Damages Value" = isnull(openingdetails.Damage_Opening_Value, 0)             
      "Damages Value" =         
  case @StockVal          
  When N'PTS' Then         
  isnull((isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTS, 0)), 0)            
  When N'PTR' Then        
  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTR, 0)), 0)            
--   When 'ECP' Then        
--   isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)            
  When N'ECP' Then        
  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)            
--   When 'Special Price' Then        
--   isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)            
  Else        
  isnull((openingdetails.Damage_Opening_Value), 0)            
  End        
    
 from  Items, OpeningDetails, UOM As UOM1, UOM As UOM2, UOM As UOM3, ConversionTable        
 WHERE          
 Items.Product_Code = OpeningDetails.Product_Code AND         
 OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)       
 AND Items.UOM *= UOM1.UOM        
 And Items.UOM1 *= UOM2.UOM    
 And Items.UOM2 *= UOM3.UOM    
    And OpeningDetails.Opening_Quantity > 0           
 AND Items.ConversionUnit *= ConversionTable.ConversionID        
    AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)    
 and Items.Active = 1     
 END    
 ELSE          
 BEGIN          
 Select Items.product_Code,     
 "Item Code" = Items.Product_Code,     
 "Item Name" = Items.ProductName,        
 "Total On Hand Qty UOM3" = IsNull(CAST(dbo.GetFirstLevelUOMQty(Items.Product_Code, ISNULL(OpeningDetails.Opening_Quantity, 0)) AS nvarchar)         
 + N' ' +  CAST(UOM3.Description AS nvarchar), 0) ,          
 "Total On Hand Qty UOM2" = IsNull(CAST(dbo.GetSecondLevelUOMQty(Items.Product_Code, ISNULL(OpeningDetails.Opening_Quantity, 0)) AS nvarchar)         
 + N' ' +  CAST(UOM2.Description AS nvarchar), 0) ,          
 "Total On Hand Qty UOM1" = IsNull(CAST(dbo.GetLastLevelUOMQty(Items.Product_Code, ISNULL(OpeningDetails.Opening_Quantity, 0)) AS nvarchar)         
 + N' ' +  CAST(UOM1.Description AS nvarchar), 0) ,          
 "Conversion Unit" = IsNull(CAST(CAST(Items.ConversionFactor * ISNULL(OpeningDetails.Opening_Quantity, 0) as Decimal(18,6))  AS nvarchar)         
 + N' ' +  CAST(ConversionTable.ConversionUnit AS nvarchar), 0) ,        
    "Reporting UOM" = IsNull(Cast(dbo.sp_Get_ReportingUOMQty(Items.Product_Code, ISNULL(OpeningDetails.Opening_Quantity, 0)) As nvarchar)    
    
--  "Reporting UOM" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6))  AS nvarchar)         
 + N' ' + CAST((Select Description From UOM Where UOM = Items.ReportingUOM)  AS nvarchar), 0) ,        
-- "Total On Hand Value" = ISNULL(OpeningDetails.Opening_Value, 0),        
      "Total On Hand Value" =         
  case @StockVal          
  When N'PTS' Then         
  ((ISNULL(openingdetails.Opening_Quantity - IsNull(Free_opening_Quantity, 0), 0) * Isnull(Items.PTS, 0)))              
  When N'PTR' Then         
  ((ISNULL(openingdetails.Opening_Quantity - IsNull(Free_opening_Quantity, 0), 0) * Isnull(Items.PTR, 0)))              
--   When 'ECP' Then         
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))              
  When N'ECP' Then         
  ((ISNULL(openingdetails.Opening_Quantity - IsNull(Free_opening_Quantity, 0), 0) * Isnull(Items.ECP, 0)))              
--   When 'Special Price' Then         
--   ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))              
  Else        
  (ISNULL(OpeningDetails.Opening_Value, 0))            
  End,    
 "Saleable Stock UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty(Items.Product_Code, (openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0))) As nvarchar)    
 + N' ' +  CAST(UOM3.Description AS nvarchar), 0),          
 "Saleable Stock UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty(Items.Product_Code, (openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0))) As nvarchar)    
 + N' ' +  CAST(UOM2.Description AS nvarchar), 0),          
 "Saleable Stock UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty(Items.Product_Code, (openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0))) As nvarchar)    
 + N' ' +  CAST(UOM1.Description AS nvarchar), 0),          
-- "Saleable Value" = openingdetails.Opening_Value - IsNull(openingdetails.Damage_Opening_Value,0),        
       "Saleable Value" =           
  case @StockVal            
  When N'PTS' Then           
  (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTS, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTS, 0))              
  When N'PTR' Then           
  (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTR, 0))              
--   When 'ECP' Then           
--   (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))              
  When N'ECP' Then           
  (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))            --   When 'Special Price' Then           
--   (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))              
  Else          
  (isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))          
  End,        
 "Free OnHand Qty UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty(Items.Product_Code, isnull(openingdetails.Free_Saleable_Quantity, 0)) As nvarchar)    
 + N' ' +  CAST(UOM3.Description AS nvarchar), 0),              
 "Free OnHand Qty UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty(Items.Product_Code, isnull(openingdetails.Free_Saleable_Quantity, 0)) As nvarchar)    
 + N' ' +  CAST(UOM2.Description AS nvarchar), 0),              
 "Free OnHand Qty UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty(Items.Product_Code, isnull(openingdetails.Free_Saleable_Quantity, 0)) As nvarchar)    
 + N' ' +  CAST(UOM1.Description AS nvarchar), 0),    
 "Damages Qty UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty(Items.Product_Code, isnull(openingdetails.Damage_Opening_Quantity,0)) As nvarchar)    
 + N' ' +  CAST(UOM3.Description AS nvarchar), 0),              
 "Damages Qty UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty(Items.Product_Code, isnull(openingdetails.Damage_Opening_Quantity,0)) As nvarchar)    
 + N' ' +  CAST(UOM2.Description AS nvarchar), 0),              
 "Damages Qty UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty(Items.Product_Code, isnull(openingdetails.Damage_Opening_Quantity,0)) As nvarchar)    
 + N' ' +  CAST(UOM1.Description AS nvarchar), 0),              
-- "Damages Value" = isnull(openingdetails.Damage_Opening_Value, 0)             
      "Damages Value" =         
  case @StockVal          
  When N'PTS' Then         
  isnull((isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTS, 0)), 0)            
  When N'PTR' Then        
  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTR, 0)), 0)            
--   When 'ECP' Then        
--   isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)            
  When N'ECP' Then        
  isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)            
--   When 'Special Price' Then        
--   isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)            
  Else        
  isnull((openingdetails.Damage_Opening_Value), 0)            
  End        
    
 from  Items, OpeningDetails, UOM As UOM1, UOM As UOM2, UOM As UOM3, ConversionTable        
 WHERE          
 Items.Product_Code *= OpeningDetails.Product_Code AND         
 OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)       
 AND Items.UOM *= UOM1.UOM        
 And Items.UOM1 *= UOM2.UOM    
 And Items.UOM2 *= UOM3.UOM    
--    And OpeningDetails.Opening_Quantity > 0           
 AND Items.ConversionUnit *= ConversionTable.ConversionID        
    AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)    
 and Items.Active = 1     
    
 END    
END      
ELSE  -- if for current date    
BEGIN      
 IF @ShowItems = N'Items with stock'          
 BEGIN          
 Select     
 Batch_Products.Product_Code,     
 "Item Code" = Batch_Products.Product_Code,     
 "Item Name" = Items.ProductName,    
 "Total On Hand Qty UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code, Sum(Quantity)) as nvarchar)     
 + N' ' + IsNull(UOM3.Description, N''), 0),     
 "Total On Hand Qty UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, Sum(Quantity)) as nvarchar)     
 + N' ' + IsNull(UOM2.Description, N''), 0),   
 "Total On Hand Qty UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, Sum(Quantity)) as nvarchar)     
 + N' ' + IsNull(UOM1.Description, N''), 0),     
-- "Total On Hand Value" = cast(ISNULL(SUM(QUANTITY * PurchasePrice), 0) as decimal(18,6)),      
  "Total On Hand Value" =           
  case @StockVal          
  When N'PTS'  Then        
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End) End)    
  When N'PTR' Then        
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End) End)    
--   When 'ECP' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End) End)    
  When N'ECP' Then        
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.ECP, 0)End)),0)         
--   When 'Special Price' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End) End)    
  Else        
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)            
  End,      
 "Conversion Unit" = IsNull(CAST(CAST(Items.ConversionFactor * ISNULL(SUM(Quantity), 0) AS Decimal(18,6)) AS nvarchar)     + N' ' +  CAST(ConversionTable.ConversionUnit AS nvarchar), 0) ,      
    "Reporting UOM" = IsNull(Cast(dbo.sp_Get_ReportingUOMQty(Batch_Products.Product_Code, SUM(IsNull(Quantity, 0))) As nvarchar)     
    
--  "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE Items.ReportingUnit     
--  WHEN 0 THEN     
--  1     
--  ELSE     
--  Items.ReportingUnit     
--  END) AS Decimal(18,6)) AS nvarchar)         
 + N' ' +     
 CAST((Select Description From UOM Where UOM = Items.ReportingUOM) AS nvarchar), 0),      
 "Saleable Stock UOM3" = IsNull(cast(dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) = 0 And IsNull(Free,0) = 0 Then Quantity Else 0 End) as decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM3.Description, N''), 0),    
 "Saleable Stock UOM2" = IsNull(cast(dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) = 0 And IsNull(Free,0) = 0 Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM2.Description, N''), 0),    
 "Saleable Stock UOM1" = IsNull(cast(dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) = 0 And IsNull(Free,0) = 0 Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM1.Description, N''), 0),    
-- "Saleable Value" = cast(sum(Case When IsNull(Damage, 0) = 0 And IsNull(Free,0) = 0 Then Quantity*Batch_Products.PurchasePrice Else 0 End) as Decimal(18,6)),    
  "Saleable Value" = --(Select         
  IsNull(case @StockVal          
  When N'PTS' Then   Case When isnull(free,0)=0 and isnull(damage,0) = 0  Then   
  Sum(Case IC.Price_Option When 1 Then (Isnull(Batch_Products.Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Batch_Products.Quantity, 0) * Isnull(Items.PTS, 0)) End )  End  
  When N'PTR' Then   Case When isnull(free,0)=0 and isnull(damage,0) = 0  Then 
  Sum(Case IC.Price_Option When 1 Then (Isnull(Batch_Products.Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Batch_Products.Quantity, 0) * Isnull(Items.PTR, 0)) End )  End  
--   When 'ECP' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End )    
  When N'ECP' Then   Case When isnull(free,0)=0 and isnull(damage,0) = 0  Then   
  isnull(Sum(isnull(Batch_Products.Quantity, 0) * Isnull(Items.ECP, 0)),0) End  
--   When 'Special Price' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End )    
  Else Case When isnull(free,0)=0 and isnull(damage,0) = 0  Then   
  isnull(Sum(isnull(Batch_Products.Quantity, 0) * isnull(PurchasePrice, 0)),0) End  
  End, 0),   
--     from batch_products, Items, ItemCategories IC  where Items.Product_Code = Batch_Products.Product_Code and Items.CategoryID = IC.CategoryID and isnull(free,0)=0 and isnull(damage,0) = 0 And items.product_code = Items.Product_code),            
  "Free On Hand Qty UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) = 0 And IsNull(Free,0) > 0 Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM3.Description, N''), 0),    
 "Free On Hand Qty UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) = 0 And IsNull(Free,0) > 0 Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM2.Description, N''), 0),    
 "Free On Hand Qty UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) = 0 And IsNull(Free,0) > 0 Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM1.Description, N''), 0),    
 "Damages Qty UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM3.Description, N''), 0),    
 "Damages Qty UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM2.Description, N''), 0),    
 "Damages Qty UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM1.Description, N''), 0),    
-- "Damages Value" = cast(sum(Case When IsNull(Damage, 0) > 0 Then Quantity*Batch_Products.PurchasePrice Else 0 End) as Decimal(18,6))    
 "Damages Value" = --(select        
  IsNull(case @StockVal          
  When N'PTS'  Then Case When isnull(damage,0) <> 0 Then  
  Sum(Case IC.Price_Option When 1 Then (Isnull(Batch_Products.Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Batch_Products.Quantity, 0) * Isnull(Items.PTS, 0)) End)  End  
  When N'PTR' Then  Case When isnull(damage,0) <> 0 Then  
  Sum(Case IC.Price_Option When 1 Then (Isnull(Batch_Products.Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Batch_Products.Quantity, 0) * Isnull(Items.PTR, 0)) End)  End  
--   When 'ECP' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)    
  When N'ECP' Then  Case When isnull(damage,0) <> 0 Then  
  isnull(Sum(isnull(Batch_Products.Quantity, 0) * isnull(Items.ECP, 0)),0) End  
--   When 'Special Price' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)    
  Else Case When isnull(damage,0) <> 0 Then   
  isnull(Sum(isnull(Batch_Products.Quantity, 0) * isnull(PurchasePrice, 0)),0) End  
  End, 0)    
--    from Items, Batch_Products, ItemCategories IC  where Items.Product_Code = Batch_Products.Product_Code And Items.CategoryID = IC.CategoryID and isnull(damage,0) <> 0 And items.product_code = Items.Product_code)        
 From Batch_Products, Items, UOM As UOM1, UOM As UOM2, UOM As UOM3, ConversionTable, ItemCategories IC    
 Where Batch_Products.Product_Code = Items.Product_Code And     
    Items.CategoryID = IC.CategoryID And    
 Items.UOM *= UOM1.UOM And    
 Items.UOM1 *= UOM2.UOM And    
 Items.UOM2 *= UOM3.UOM And    
 Items.ConversionUnit *= ConversionTable.ConversionID And    
    Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)    
 Group By Batch_Products.Product_Code, Items.ProductName, UOM1.Description,     
 ConversionTable.ConversionUnit, Items.ConversionFactor, UOM2.Description,     
 Items.ReportingUnit, Items.ReportingUOM, UOM3.Description, Batch_Products.Free, Batch_Products.Damage  
    HAVING ISNULL(SUM(Quantity), 0) > 0          
 END          
 ELSE          
 BEGIN          
 Select     
 Items.Product_Code,   
 "Item Code" = Items.Product_Code,     
 "Item Name" = Items.ProductName,    
 "Total On Hand Qty UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code, Sum(Quantity)) as nvarchar)     
 + N' ' + IsNull(UOM3.Description, N''), 0),     
 "Total On Hand Qty UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, Sum(Quantity)) as nvarchar)     
 + N' ' + IsNull(UOM2.Description, N''), 0),     
 "Total On Hand Qty UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, Sum(Quantity)) as nvarchar)     
 + N' ' + IsNull(UOM1.Description, N''), 0),     
-- "Total On Hand Value" = cast(ISNULL(SUM(QUANTITY * PurchasePrice), 0) as decimal(18,6)),      
  "Total On Hand Value" =           
  case @StockVal          
  When N'PTS'  Then        
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End) End)    
  When N'PTR' Then        
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End) End)    
--   When 'ECP' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End) End)    
  When N'ECP' Then        
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.ECP, 0)End)),0)         
--   When 'Special Price' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End) End)    
  Else        
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)            
  End,      
 "Conversion Unit" = IsNull(CAST(CAST(Items.ConversionFactor * ISNULL(SUM(Quantity), 0) AS Decimal(18,6)) AS nvarchar)     + N' ' +  CAST(ConversionTable.ConversionUnit AS nvarchar), 0) ,      
 "Reporting UOM" = IsNull(Cast(dbo.sp_Get_ReportingUOMQty(Batch_Products.Product_Code, SUM(IsNull(Quantity, 0))) As nvarchar)     
    
--  "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE Items.ReportingUnit     
--  WHEN 0 THEN     
--  1     
--  ELSE     
--  Items.ReportingUnit     
--  END) AS Decimal(18,6)) AS nvarchar)         
 + N' ' +     
 CAST((Select Description From UOM Where UOM = Items.ReportingUOM) AS nvarchar), 0),      
 "Saleable Stock UOM3" = IsNull(cast(dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code,
 cast(sum(Case When IsNull(Damage, 0) = 0 And IsNull(Free,0) = 0 Then Quantity Else 0 
End) as decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM3.Description, N''), 0),    
 "Saleable Stock UOM2" = IsNull(cast(dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code, 
cast(sum(Case When IsNull(Damage, 0) = 0 And IsNull(Free,0) = 0 
Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM2.Description, N''), 0),    
 "Saleable Stock UOM1" = IsNull(cast(dbo.GetLastLevelUOMQty(Batch_Products.Product_Code, 
cast(sum(Case When IsNull(Damage, 0) = 0 And IsNull(Free,0) = 0 Then Quantity Else 0 End) 
as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM1.Description, N''), 0),    
-- "Saleable Value" = cast(sum(Case When IsNull(Damage, 0) = 0 And IsNull(Free,0) = 0 Then Quantity*Batch_Products.PurchasePrice Else 0 End) as Decimal(18,6)),    
  "Saleable Value" = --(Select         
  IsNull(case @StockVal          
  When N'PTS' Then  sum(Case When isnull(free,0) = 0 And isnull(damage,0) = 0 Then  
  Case IC.Price_Option When 1 Then 
(Isnull(Batch_Products.Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else 
(Isnull(Batch_Products.Quantity, 0) * Isnull(Items.PTS, 0)) End   End  )

  When N'PTR' Then  sum(Case When isnull(free,0)=0 and isnull(damage,0) = 0 Then  
Case IC.Price_Option When 1 Then (Isnull(Batch_Products.Quantity, 0) * 
Isnull(Batch_Products.PTR, 0)) Else (Isnull(Batch_Products.Quantity, 0) * 
Isnull(Items.PTR, 0)) End End  )
--   When 'ECP' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End )    

  When N'ECP' Then sum(Case When isnull(free,0)=0 and isnull(damage,0) = 0 Then  
  isnull(isnull(Batch_Products.Quantity, 0) * Isnull(Items.ECP, 0),0) End )
--   When 'Special Price' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End )    

  Else sum(Case When isnull(free,0)=0 and isnull(damage,0) = 0 Then  
  isnull(isnull(Batch_Products.Quantity, 0) * isnull(PurchasePrice, 0),0) End ) 
  End, 0),  

--     from batch_products, Items, ItemCategories IC  where Items.Product_Code = Batch_Products.Product_Code and Items.CategoryID = IC.CategoryID and isnull(free,0)=0 and isnull(damage,0) = 0 And items.product_code = Items.Product_code),            
  "Free On Hand Qty UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty
(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) = 0 And 
IsNull(Free,0) > 0 Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM3.Description, N''), 0),    
 "Free On Hand Qty UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty
(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) = 0 And 
IsNull(Free,0) > 0 Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM2.Description, N''), 0),    
 "Free On Hand Qty UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty
(Batch_Products.Product_Code, cast(sum(Case When IsNull(Damage, 0) = 0 And 
IsNull(Free,0) > 0 Then Quantity Else 0 End) as Decimal(18,6))) as nvarchar)     
 + N' ' + IsNull(UOM1.Description, N''), 0),    
 "Damages Qty UOM3" = IsNull(Cast(dbo.GetFirstLevelUOMQty(Batch_Products.Product_Code,
 cast(sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) as Decimal(18,6)))
 as nvarchar)     
 + N' ' + IsNull(UOM3.Description, N''), 0),    
 "Damages Qty UOM2" = IsNull(Cast(dbo.GetSecondLevelUOMQty(Batch_Products.Product_Code,
 cast(sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) as Decimal(18,6))) 
as nvarchar)     
 + N' ' + IsNull(UOM2.Description, N''), 0),    
 "Damages Qty UOM1" = IsNull(Cast(dbo.GetLastLevelUOMQty(Batch_Products.Product_Code,
 cast(sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) as Decimal(18,6))) 
as nvarchar)     
 + N' ' + IsNull(UOM1.Description, N''), 0),    
-- "Damages Value" = cast(sum(Case When IsNull(Damage, 0) > 0 Then Quantity*Batch_Products.PurchasePrice Else 0 End) as Decimal(18,6))    
     "Damages Value" = --(select        
  IsNuLL(case @StockVal          
  When N'PTS'  Then Case When isnull(damage,0) <> 0 Then  
  Sum(Case IC.Price_Option When 1 Then (Isnull(Batch_Products.Quantity, 0) *
 Isnull(Batch_Products.PTS, 0)) Else (Isnull(Batch_Products.Quantity, 0) * 
Isnull(Items.PTS, 0)) End)  End  
  When N'PTR' Then  Case When isnull(damage,0) <> 0 Then  
  Sum(Case IC.Price_Option When 1 Then (Isnull(Batch_Products.Quantity, 0) * 
Isnull(Batch_Products.PTR, 0)) Else (Isnull(Batch_Products.Quantity, 0) * 
Isnull(Items.PTR, 0)) End)  End  
--   When 'ECP' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)    
  When N'ECP' Then Case When isnull(damage,0) <> 0 Then  
  isnull(Sum(isnull(Batch_Products.Quantity, 0) * isnull(Items.ECP, 0)),0) End  
--   When 'Special Price' Then        
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)    
  Else Case When isnull(damage,0) <> 0 Then  
  isnull(Sum(isnull(Batch_Products.Quantity, 0) * isnull(PurchasePrice, 0)),0) End  
  End, 0)    
--    from Items its, Batch_Products, ItemCategories IC  where Items.Product_Code = Batch_Products.Product_Code And Items.CategoryID = IC.CategoryID and isnull(damage,0) <> 0 And its.product_code = items.product_code)        
 From Batch_Products, Items, UOM As UOM1, UOM As UOM2, UOM As UOM3, ConversionTable, ItemCategories IC    
 Where Items.Product_Code *= Batch_Products.Product_Code And     
    Items.CategoryID = IC.CategoryID And    
 Items.UOM *= UOM1.UOM And    
 Items.UOM1 *= UOM2.UOM And    
 Items.UOM2 *= UOM3.UOM And    
 Items.ConversionUnit *= ConversionTable.ConversionID And    
 Items.Product_Code In (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)    
 Group By Batch_Products.Product_Code, Items.ProductName, UOM1.Description,     
 ConversionTable.ConversionUnit, Items.ConversionFactor, UOM2.Description,     
 Items.ReportingUnit, Items.ReportingUOM, UOM3.Description, Items.Product_Code,
-- Batch_Products.free, 
Batch_Products.Damage   
--    HAVING ISNULL(SUM(Quantity), 0) > 0          
 END    
END
