CREATE procedure [dbo].[spr_list_stock_ledger_by_mfr_FMCG](@MANUFACTURER nvarchar(2550),   
												   @FROM_DATE datetime, 
												   @ShowItems nvarchar(50), 
												   @StockVal nvarchar(100), 
												   @ItemCode nvarchar(2550))                        
AS                        
  
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

if @MANUFACTURER='%'     
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer    
Else    
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@MANUFACTURER,@Delimeter)    
  
if @ItemCode = '%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)
                    
IF (DATEPART(dy, @FROM_DATE) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FROM_DATE) = DATEPART(yyyy, GETDATE())) or DATEPART(yyyy, @FROM_DATE) < DATEPART(yyyy, GETDATE())                    
BEGIN                    
 IF @ShowItems = 'Items with stock'                    
 BEGIN                    
 Select "ManufacturerID" = Items.ManufacturerID,                         
  "Manufacturer" = Manufacturer.Manufacturer_Name,                         
  "Total On Hand Qty" = ISNULL(SUM(OpeningDetails.Opening_Quantity), 0),                         
  "On Hand Value" =             
  case @StockVal              
  When 'SalePrice' Then             
  (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))                  
  When 'PurchasePrice' Then             
  (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))                  
--   When 'ECP' Then             
--   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))                  
   When 'MRP' Then             
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))                  
--   When 'Special Price' Then             
--   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))                  
  Else            
  SUM(ISNULL(OpeningDetails.Opening_Value, 0))                
  End,        
                     
  "Tax Suffered (%)" = Sum(OpeningDetails.TaxSuffered_Value),                    
  "Tax suffered" = Cast(ISNULL(SUM(OpeningDetails.Opening_Value * (OpeningDetails.TaxSuffered_Value/100)), 0) As Decimal(18,6)),                    
                    
  "Total On Hand Value" =                     
  case @StockVal                        
  When 'SalePrice' Then                       
  Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))                  
  When 'PurchasePrice' Then                       
  Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))               
--   When 'ECP' Then                       
--   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))               
   When 'MRP' Then                       
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))               
--   When 'Special Price' Then                       
--   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))    
  Else                    
  Cast(ISNULL(SUM(OpeningDetails.Opening_Value + (OpeningDetails.Opening_Value * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))                    
  End,                    
  "Saleable Stock" = isnull(sum(openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0)), 0),                        
 "Saleable Value" =                       
 case @StockVal                        
 When 'SalePrice' Then                       
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))                          
 When 'PurchasePrice' Then                       
 sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))                          
--  When 'ECP' Then                       
--  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))                          
  When 'MRP' Then                       
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))                          
--  When 'Special Price' Then                       
--  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))                          
 Else                      
 sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))                      
 End,                      
  "Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity), 0),                        
  "Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),                        
 "Damages Value" =                     
 case @StockVal                      
 When 'SalePrice' Then                     
 isnull(Sum(isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)), 0)                        
 When 'PurchasePrice' Then                    
 isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)), 0)                        
--  When 'ECP' Then                    
--  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)                        
  When 'MRP' Then                    
  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)                        
--  When 'Special Price' Then                    
--  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)                        
 Else                    
 isnull(Sum(openingdetails.Damage_Opening_Value), 0)                        
 End                     
 from    Items, OpeningDetails, Manufacturer                    
 WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                        
  AND Items.ManufacturerID = Manufacturer.ManufacturerID                       
  AND Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr)
  And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
  and Manufacturer.Active = 1                       
 GROUP BY Items.ManufacturerID, Manufacturer.Manufacturer_Name                        
 HAVING ISNULL(SUM(OpeningDetails.Opening_Quantity), 0) > 0                    
 END                    
 ELSE                    
 BEGIN                    
 Select  Items.ManufacturerID,                         
  "Manufacturer" = Manufacturer.Manufacturer_Name,                         
  "Total On Hand Qty" = ISNULL(SUM(OpeningDetails.Opening_Quantity), 0),                         
  "On Hand Value" =             
  case @StockVal              
  When 'SalePrice' Then   
  (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))                  
  When 'PurchasePrice' Then             
  (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))                  
--   When 'ECP' Then             
--   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))                  
   When 'MRP' Then             
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))     
--   When 'Special Price' Then             
--   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))                  
  Else            
  SUM(ISNULL(OpeningDetails.Opening_Value, 0))                
  End,                   
  "Tax Suffered (%)" = Sum(OpeningDetails.TaxSuffered_Value),                    
  "Tax suffered" = Cast(ISNULL(SUM(OpeningDetails.Opening_Value * (OpeningDetails.TaxSuffered_Value/100)), 0) As Decimal(18,6)),                    
  "Total On Hand Value" =                     
  case @StockVal                        
  When 'SalePrice' Then                       
  Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))               
  When 'PurchasePrice' Then                       
  Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))               
--   When 'ECP' Then                       
--   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))               
   When 'MRP' Then                       
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))               
--   When 'Special Price' Then                       
--   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))                    
  Else                    
  Cast(ISNULL(SUM(OpeningDetails.Opening_Value + (OpeningDetails.Opening_Value * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))                    
  End,         
  "Saleable Stock" = isnull(sum(openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0)), 0),                        
  "Saleable Value" =                       
  case @StockVal                        
  When 'SalePrice' Then                       
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))                          
  When 'PurchasePrice' Then                       
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))                          
--   When 'ECP' Then                       
--   sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))                          
   When 'MRP' Then                       
   sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))                          
--   When 'Special Price' Then                       
--   sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))                          
  Else                      
  sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))                      
  End,                      
  "Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity), 0),                        
  "Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),                        
 "Damages Value" =                     
 case @StockVal                      
 When 'SalePrice' Then                     
 isnull(Sum(isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)), 0)                        
 When 'PurchasePrice' Then                    
 isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)), 0)                        
--  When 'ECP' Then                    
--  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)                        
  When 'MRP' Then                    
  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)                        
--  When 'Special Price' Then                    
--  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)                        
 Else                    
 isnull(Sum(openingdetails.Damage_Opening_Value), 0)                        
 End                     
                         
 from    Items, OpeningDetails, Manufacturer                    
 WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                        
  AND Items.ManufacturerID = Manufacturer.ManufacturerID                       
  AND Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) 
  And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
  and Manufacturer.Active = 1                       
 GROUP BY Items.ManufacturerID, Manufacturer.Manufacturer_Name                        
 END                        
END                     
ELSE              
BEGIN                        
 IF @ShowItems = 'Items with stock'                    
 BEGIN                    
 Select [Manufacturer ID], [Manufacturer], "Total On Hand Qty" =  Sum([Total On Hand Qty]), "On Hand Value" = Sum([On Hand Value]),                     
 "Tax Suffered (%)" = Sum([Tax Suffered (%)]), "Tax suffered" = Sum([Tax suffered]), "Total On Hand Value" = Sum([Total On Hand Value]),"Saleable Stock" = Sum([Saleable Stock]),"Saleable Value" =  Sum([Saleable Value]),                     
 "Free OnHand Qty" = Sum([Free OnHand Qty]), "Damages Qty" = Sum([Damages Qty]), "Damages Value" = Sum([Damages Value]) from                    
 (Select "Manufacturer ID" = Items.ManufacturerID, "Manufacturer" = M1.Manufacturer_Name,                        
  "Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0),                         
 "On Hand Value" =               
  case @StockVal              
  When 'SalePrice'  Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End) End)        
  When 'PurchasePrice' Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End) End)        
--   When 'ECP' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End) End) 
   When 'MRP' Then            
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0)End)),0)             
--   When 'Special Price' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End,             
  "Tax Suffered (%)" = (select Sum(Batch_Products.TaxSuffered)  
   from Items It, Batch_Products  
   where It.Product_Code = Batch_Products.Product_Code and   
   It.ManufacturerID = M1.ManufacturerID   
   And ItemCategories.CategoryID = It.CategoryID  
   And IsNull(Batch_Products.Damage,0) NOT IN (1,2)),                                             
  
  
  "Tax suffered" =                     

 Case isnull(Batch_Products.TaxOnMRP,0)                      
 When 1 Then                      
  Case Isnull(ItemCategories.Price_option, 0)                       
  When 1 Then                      
  ISNULL(Round(SUM((QUANTITY * Batch_Products.SalePrice) * (dbo.fn_get_TaxOnMRP(Batch_Products.TaxSuffered) / 100)),2), 0)                      
  Else                      
  ISNULL(Round(SUM((QUANTITY * Items.Sale_Price) * (Batch_Products.TaxSuffered / 100)),2), 0)                       
  End                      
 Else             
 Case Isnull(ItemCategories.Price_option, 0)            
 When 1 Then            
        ISNULL(Round(SUM((QUANTITY * Batch_Products.PurchasePrice) * (Batch_Products.TaxSuffered / (100 - Batch_Products.TaxSuffered) )),2), 0)            
 Else         
   ISNULL(Round(SUM((Case [Free] When 1 Then 0 Else (QUANTITY * Items.Purchase_Price) * (Batch_Products.TaxSuffered / 100)End)),2), 0)               
 End          
 End,                          
  "Total On Hand Value" =                     
  case @StockVal                        
  When 'SalePrice' Then                       
  ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.SalePrice + Round(QUANTITY * Batch_Products.SalePrice * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.Sale_Price + Round(QUANTITY * Items.Sale_Price
 * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)                                                                      
  When 'PurchasePrice' Then                      
  ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.PurchasePrice + Round(QUANTITY * Batch_Products.PurchasePrice * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.Purchase_Price + Round(QUANTITY * Items.Purchase_Price
 * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)        
--   When 'ECP' Then                       
--   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.ECP + Round(QUANTITY * Batch_Products.ECP * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.ECP + Round(QUANTITY * Items.ECP
--  * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)        
   When 'MRP' Then                       
   ISNULL(SUM( (Case [Free] When 1 Then 0 Else QUANTITY * Items.MRP + Round(QUANTITY * Items.MRP * (Batch_Products.TaxSuffered / 100),2)End) ), 0)                       
--   When 'Special Price' Then                       
--   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.Company_Price + Round(QUANTITY * Batch_Products.Company_Price * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.Company_Price + Round(QUANTITY * Items.Company_Price * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)        
  Else                    
  ISNULL(SUM(QUANTITY * PurchasePrice + Round(QUANTITY * PurchasePrice * (Batch_Products.TaxSuffered / 100),2)), 0)                       
   End,                                                
  "Saleable Stock" = (select isnull(Sum(Quantity),0) from batch_products, Items It where It.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = 
It.CategoryID),                        
  "Saleable Value" = (Select                       
  case @StockVal                    
  When 'SalePrice'  Then                  
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Sale_Price, 0)) End)              
  When 'PurchasePrice' Then                  
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Purchase_Price, 0)) End)              
--   When 'ECP' Then                  
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)              
   When 'MRP' Then                  
   isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)                   
--   When 'Special Price' Then                  
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)              
  Else                  
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                      
  End                     
  from batch_products, Items It, ItemCategories IC where IC.CategoryID = It.CategoryID AND It.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID 
= It.CategoryID),                        
  "Free OnHand Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items It where It.Product_Code = Batch_Products.Product_Code and free <> 0 And It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = It.CategoryID),                      
  "Damages Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items It where It.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = It.CategoryID),        
   "Damages Value" = (select                      
   case @StockVal                    
   When 'SalePrice'  Then                  
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Sale_Price, 0)) End)              
   When 'PurchasePrice' Then                  
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Purchase_Price, 0)) End)              
--    When 'ECP' Then                  
--    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)              
    When 'MRP' Then                  
    isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)                   
--    When 'Special Price' Then                  
--    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)              
   Else                  
   isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                      
   End                      
 from Items It, Batch_Products, ItemCategories where It.CategoryID = ItemCategories.CategoryID AND It.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = It.CategoryID)                        
 from Items, Batch_Products, Manufacturer M1, ItemCategories            
 WHERE Items.ManufacturerID = M1.ManufacturerID AND Items.Product_Code *= Batch_Products.Product_Code                        
  AND M1.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr)
  And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
  and M1.Active = 1                       
  and ItemCategories.CategoryID = Items.CategoryID                     
 GROUP BY Items.ManufacturerID, M1.ManufacturerID, M1.Manufacturer_Name, Batch_Products.TaxOnMRP, ItemCategories.Price_option, ItemCategories.CategoryID                       
 HAVING ISNULL(SUM(QUANTITY), 0) > 0) Manufact                    
 Group By [Manufacturer ID], [Manufacturer]          
 END                    
 ELSE                    
 BEGIN                    
 Select  [Manufacturer ID], [Manufacturer],  "Total On Hand Qty" =  Sum([Total On Hand Qty]), "On Hand Value" = Sum([On Hand Value]),                     
 "Tax Suffered (%)" = Sum([Tax Suffered (%)]), "Tax suffered" = Sum([Tax suffered]), "Total On Hand Value" = Sum([Total On Hand Value]),"Saleable Stock" = Sum([Saleable Stock]),"Saleable Value" = Sum([Saleable Value]),                     
 "Free OnHand Qty" = Sum([Free OnHand Qty]), "Damages Qty" = Sum([Damages Qty]), "Damages Value" = Sum([Damages Value]) from                    
(Select "Manufacturer ID" = Items.ManufacturerID, "Manufacturer" = M1.Manufacturer_Name,                        
  "Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0),                         
 "On Hand Value" =               
  case @StockVal              
  When 'SalePrice'  Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End) End)        
  When 'PurchasePrice' Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End) End)        
--   When 'ECP' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End) End)        
   When 'MRP' Then            
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0)End)),0)             
--   When 'Special Price' Then            
--   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End,                         
  "Tax Suffered (%)" = (select Sum(Batch_Products.TaxSuffered)  
   from Items It, Batch_Products  
   where It.Product_Code = Batch_Products.Product_Code and   
   It.ManufacturerID = M1.ManufacturerID   
   And ItemCategories.CategoryID = It.CategoryID  
   And IsNull(Batch_Products.Damage,0) NOT IN (1,2)),                        
  
  "Tax suffered" =                     
 Case isnull(Batch_Products.TaxOnMRP,0)                      
 When 1 Then                      
  Case Isnull(ItemCategories.Price_option, 0)                       
  When 1 Then                      
  ISNULL(Round(SUM((QUANTITY * Batch_Products.SalePrice) * (dbo.fn_get_TaxOnMRP(Batch_Products.TaxSuffered) / 100)),2), 0)                      
  Else                      
  ISNULL(Round(SUM((QUANTITY * Items.Sale_Price) * (Batch_Products.TaxSuffered / 100)),2), 0)                       
  End                      
 Else                      
 Case Isnull(ItemCategories.Price_option, 0)          
 When 1 Then          
 ISNULL(Round(SUM((QUANTITY * Batch_Products.PurchasePrice) * (Batch_Products.TaxSuffered / (100 - Batch_Products.TaxSuffered) )),2), 0)          
 Else       
  ISNULL(Round(SUM((Case [Free] When 1 Then 0 Else (QUANTITY * Items.Purchase_Price) * (Batch_Products.TaxSuffered / 100)End)),2), 0)             
 End           
 End,                    
  "Total On Hand Value" =                     
  case @StockVal                        
  When 'SalePrice' Then                       
  ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.SalePrice + Round(QUANTITY * Batch_Products.SalePrice * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.Sale_Price + Round(QUANTITY * Items.Sale_Price  
 * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)                                                                      
  When 'PurchasePrice' Then                      
  ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.PurchasePrice + Round(QUANTITY * Batch_Products.PurchasePrice * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.Purchase_Price + Round(QUANTITY * Items.Purchase_Price
  
 * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)        
--   When 'ECP' Then                       
--   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.ECP + Round(QUANTITY * Batch_Products.ECP * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.ECP + Round(QUANTITY * Items.ECP
--   
--  * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)        
   When 'MRP' Then                       
   ISNULL(SUM( (Case [Free] When 1 Then 0 Else QUANTITY * Items.MRP + Round(QUANTITY * Items.MRP * (Batch_Products.TaxSuffered / 100),2)End) ), 0)                       
--   When 'Special Price' Then                       
--   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.Company_Price + Round(QUANTITY * Batch_Products.Company_Price * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.Company_Price + Round(QUANTITY * Items.Company_Price * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)        
   Else                    
  ISNULL(SUM(QUANTITY * PurchasePrice + Round(QUANTITY * PurchasePrice * (Batch_Products.TaxSuffered / 100),2)), 0)                       
   End,               
                   
  "Saleable Stock" = (select isnull(Sum(Quantity),0) from batch_products, Items It where It.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = 
It.CategoryID),                        
  "Saleable Value" = (Select                       
   case @StockVal                    
   When 'SalePrice'  Then                  
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Sale_Price, 0)) End)             
   When 'PurchasePrice' Then                  
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Purchase_Price, 0)) End)              
--    When 'ECP' Then                  
--    Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)              
    When 'MRP' Then                  
isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)                   
--    When 'Special Price' Then                  
--    Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)              
   Else                  
   isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                      
   End                     
 from batch_products, Items It, ItemCategories  IC          
          
where IC.CategoryID = It.CategoryID AND          
It.Product_Code = Batch_Products.Product_Code           
and isnull(free,0)=0 and isnull(damage,0) = 0           
And It.ManufacturerID = M1.ManufacturerID           
And ItemCategories.CategoryID = It.CategoryID),                          
  "Free OnHand Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items It where It.Product_Code = Batch_Products.Product_Code and free <> 0 And It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = It.CategoryID),                
  "Damages Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items It where It.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = It.CategoryID),        
 "Damages Value" = (select                      
   case @StockVal                    
   When 'SalePrice'  Then                  
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Sale_Price, 0)) End)              
   When 'PurchasePrice' Then                  
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Purchase_Price, 0)) End)              
--    When 'ECP' Then                  
--    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)              
    When 'MRP' Then                  
    isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)                   
--    When 'Special Price' Then                  
--    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)              
   Else                  
   isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                      
   End                       
 from Items It, Batch_Products, ItemCategories where It.CategoryID = ItemCategories.CategoryID And It.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = It.CategoryID)                        
 from Items, Batch_Products, Manufacturer M1, ItemCategories                    
 WHERE Items.ManufacturerID = M1.ManufacturerID AND Items.Product_Code *= Batch_Products.Product_Code                        
  AND M1.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr)
  And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
  and M1.Active = 1                       
  and ItemCategories.CategoryID = Items.CategoryID                
 GROUP BY Items.ManufacturerID, M1.ManufacturerID, M1.Manufacturer_Name,  Batch_Products.TaxOnMRP, ItemCategories.Price_option, ItemCategories.CategoryID)   Manufact                    
 Group By [Manufacturer ID], [Manufacturer]                    
 END                      
END                    
                    
Drop table #tmpMfr            
Drop table #tmpProd
