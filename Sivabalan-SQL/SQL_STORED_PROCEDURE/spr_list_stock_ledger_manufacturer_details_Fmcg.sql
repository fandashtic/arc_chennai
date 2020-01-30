CREATE PROCEDURE [dbo].[spr_list_stock_ledger_manufacturer_details_Fmcg](@MANUFACTURER int, 
																 @FROM_DATE datetime, 
																 @UnUsed nvarchar(50), 
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
Select  Items.Product_Code,         
 "Item Code" = Items.Product_Code,           
 "Item Name" = Items.ProductName,           
 "Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)   + ' ' + CAST(UOM.Description AS nvarchar),           
 "Conversion Unit" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) * Items.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),          
 "Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(Items.Product_Code, ISNULL(OpeningDetails.Opening_Quantity, 0)) As nvarchar) 
--  CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)   
  + ' ' + CAST((SELECT Description       
   From UOM Where UOM = Items.ReportingUOM) AS nvarchar),          
  "On Hand Value" =     
	 case @StockVal      
	 When 'SalePrice' Then     
	 ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0)))          
	 When 'PurchasePrice' Then     
	 ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0)))          
-- 	 When 'ECP' Then     
-- 	 ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))          
 	 When 'MRP' Then     
 	 ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))          
-- 	 When 'Special Price' Then     
-- 	 ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))          
	 Else    
	 (ISNULL(OpeningDetails.Opening_Value, 0))        
	 End,    
 "Tax Suffered (%)" = IsNull(OpeningDetails.TaxSuffered_Value,0),    
 "Tax Suffered" = ISNULL(OpeningDetails.Opening_Value * (OpeningDetails.TaxSuffered_Value/100), 0),    
  "Total On Hand Value" =             
  case @StockVal                
  When 'SalePrice' Then               
  Cast(ISNULL((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))            
  When 'PurchasePrice' Then               
  Cast(ISNULL((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))            
--   When 'ECP' Then               
--   Cast(ISNULL((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))            
   When 'MRP' Then               
   Cast(ISNULL((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))       
--   When 'Special Price' Then               
--   Cast(ISNULL((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6
-- ))            
  Else            
  Cast(ISNULL((OpeningDetails.Opening_Value + (OpeningDetails.Opening_Value * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))            
  End,     
 "Saleable Stock" = (ISNULL(openingdetails.Opening_Quantity,0) - ISNULL(openingdetails.Free_Saleable_Quantity,0) - ISNULL(openingdetails.Damage_Opening_Quantity,0)),        
 "Saleable Value" =         
 case @StockVal          
 When 'SalePrice' Then         
 (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Sale_Price, 0))            
 When 'PurchasePrice' Then         
 (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Purchase_Price, 0))            
--  When 'ECP' Then         
--  (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))            
  When 'MRP' Then         
  (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))            
--  When 'Special Price' Then         
--  (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))            
 Else        
 (isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))        
 End,        
 "Free OnHand Qty" = isnull(openingdetails.Free_Saleable_Quantity, 0),          
 "Damages Qty" = isnull(openingdetails.Damage_Opening_Quantity,0),          
    
 "Damages Value" =       
 case @StockVal        
 When 'SalePrice' Then       
 (isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Sale_Price, 0))          
 When 'PurchasePrice' Then      
 (Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Purchase_Price, 0))          
--  When 'ECP' Then      
--  (Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0))          
  When 'MRP' Then      
  (Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0))          
--  When 'Special Price' Then      
--  (Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0))          
 Else      
 isnull((openingdetails.Damage_Opening_Value), 0)          
 End       
from    Items
Inner Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code           
Left Outer Join UOM On Items.UOM = UOM.UOM
Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID                     
WHERE OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)          
 AND Items.ManufacturerID = @MANUFACTURER          
 And Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
 and items.active = 1 And 
 (Case @UnUsed When '%' Then 1 Else ISNULL(OpeningDetails.Opening_Quantity, 0) End) <> 0
END          
ELSE          
BEGIN  
Select  a.Product_Code,         
 "Item Code" = a.Product_Code,         
 "Item Name" = a.ProductName,           
 "Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar) + ' ' + CAST(UOM.Description AS nvarchar),           
 "Conversion Unit" = CAST(CAST(ISNULL(SUM(Quantity), 0) * a.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),          
 "Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(a.Product_Code, ISNULL(SUM(Quantity), 0)) As nvarchar) 
 --CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE a.ReportingUnit WHEN 0 THEN 1 ELSE a.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)   
 + ' ' + CAST((SELECT Description From UOM Where UOM = a.ReportingUOM) AS nvarchar),          
        
 "On Hand Value" =       
	 case @StockVal      
	 When 'SalePrice'  Then    
	 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Sale_Price, 0)) End) End)
	 When 'PurchasePrice' Then    
	 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Purchase_Price, 0)) End) End)
-- 	 When 'ECP' Then    
-- 	 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.ECP, 0)) End) End)
 	 When 'MRP' Then    
 	 isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(a.MRP, 0)End)),0)     
-- 	 When 'Special Price' Then    
-- 	 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Company_Price, 0)) End) End)
	 Else    
	 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)        
	 End,     
 "Tax Suffered (%)" = Cast(IsNull((Tax.Percentage),0) as nvarchar),       
 "Tax suffered" =     
Case isnull(Batch_Products.TaxOnMRP,0)      
When 1 Then      
        Case Isnull(ItemCategories.Price_option, 0)       
        When 1 Then      
        ISNULL(Round(SUM((QUANTITY * Batch_Products.SalePrice) * (Batch_Products.TaxSuffered / (100 - Batch_Products.TaxSuffered) )),2), 0)      
        Else      
        ISNULL(Round(SUM((QUANTITY * a.Sale_Price) * (Batch_Products.TaxSuffered / (100 - Batch_Products.TaxSuffered))),2), 0)       
        End      
Else      
 Case Isnull(ItemCategories.Price_option, 0)      
 When 1 Then      
	ISNULL(Round(SUM((QUANTITY * Batch_Products.PurchasePrice) * (Batch_Products.TaxSuffered / (100 - Batch_Products.TaxSuffered) )),2), 0)      
 Else   
 	ISNULL(Round(SUM((Case [Free] When 1 Then 0 Else (QUANTITY * a.Purchase_Price) * (Batch_Products.TaxSuffered / 100)End)),2), 0)         
 End      
End,    
  "Total On Hand Value" =             
  case @StockVal                
  When 'SalePrice' Then               
  ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.SalePrice + Round(QUANTITY * Batch_Products.SalePrice * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * a.Sale_Price + Round(QUANTITY * a.Sale_Price * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)                                                              
  When 'PurchasePrice' Then              
  ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.PurchasePrice + Round(QUANTITY * Batch_Products.PurchasePrice * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * a.Purchase_Price + Round(QUANTITY * a.Purchase_Price * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)
--   When 'ECP' Then               
--   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.ECP + Round(QUANTITY * Batch_Products.ECP * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * a.ECP + Round(QUANTITY * a.ECP * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)
   When 'MRP' Then               
   ISNULL(SUM( (Case [Free] When 1 Then 0 Else QUANTITY * a.MRP + Round(QUANTITY * a.MRP * (Batch_Products.TaxSuffered / 100),2)End) ), 0)               
--   When 'Special Price' Then               
--   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.Company_Price + Round(QUANTITY * Batch_Products.Company_Price * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * a.Company_Price + 
-- Round(QUANTITY * a.Company_Price * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)
  Else            
  ISNULL(SUM(QUANTITY * PurchasePrice + Round(QUANTITY * PurchasePrice * (Batch_Products.TaxSuffered / 100),2)), 0)               
   End,        
 "Saleable Stock" = ISNULL((select Sum(Quantity) from batch_products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.ManufacturerID = @MANUFACTURER And Items.Product_Code = a.Product_Code),0),    
  "Saleable Value" = Isnull((Select         
 case @StockVal        
 When 'SalePrice'  Then      
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)  
 When 'PurchasePrice' Then      
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)  
--  When 'ECP' Then      
--  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
  When 'MRP' Then      
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
--  When 'Special Price' Then      
--  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
 Else      
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
 End       
  from batch_products, Items, ItemCategories where Items.CategoryID = ItemCategories.CategoryID AND Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.ManufacturerID = @MANUFACTURER       
   And Items.Product_Code = a.Product_Code),0),      
 "Free OnHand Qty" = ISNULL((select sum(Quantity) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and free <> 0 And Items.ManufacturerID = @MANUFACTURER And Items.Product_Code = a.Product_Code),0),          
 "Damages Qty" = ISNULL((select sum(Quantity) from Batch_Products, Items where Items.Product_Code = Batch_Products.Product_Code and damage <> 0 And Items.ManufacturerID = @MANUFACTURER And Items.Product_Code = a.Product_Code),0),          
    
   "Damages Value" = isnull((select        
 case @StockVal        
 When 'SalePrice'  Then      
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)  
 When 'PurchasePrice' Then      
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)  
--  When 'ECP' Then      
--  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
  When 'MRP' Then      
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
--  When 'Special Price' Then      
--  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
 Else      
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
 End            
from Batch_Products, Items, ItemCategories where Items.CategoryID = ItemCategories.CategoryID AND Items.Product_Code = Batch_Products.Product_Code and damage <> 0 And Items.ManufacturerID = @MANUFACTURER And Items.Product_Code = a.Product_Code),0)       
from Items a
 Left Outer Join Batch_Products On a.Product_Code = Batch_Products.Product_Code 
 Left Outer Join UOM On a.UOM = UOM.UOM          
 Left Outer Join ConversionTable On a.ConversionUnit = ConversionTable.ConversionID          
 Inner Join ItemCategories On ItemCategories.CategoryID = a.CategoryID    
 Left Outer Join Tax On Tax.Tax_Code = a.TaxSuffered           
WHERE a.ManufacturerID = @MANUFACTURER          
 and a.active = 1           
 And a.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
GROUP BY a.Product_Code, a.ProductName, a.UOM, a.ConversionUnit,     
 a.ConversionFactor, a.ReportingUnit, a.ReportingUOM, ConversionTable.ConversionUnit,        
 UOM.Description, Batch_Products.TaxOnMRP, ItemCategories.Price_option, Tax.Percentage 
 Having 
 (Case @UnUsed When '%' Then 1 Else ISNULL(SUM(Quantity), 0) End) <> 0
--Having ISNULL(SUM(Quantity), 0) <> 0    
END         





