CREATE procedure [dbo].[spr_list_stock_ledger_vendor_details_FMCG](@VENDOR nvarchar(15), 
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

if @ShowItems = 'Items with stock'      
begin      
 Select  i.Product_Code,         
  "Item Code" = i.Product_Code,           
  "Item Name" = i.ProductName,           
  "On Hand Qty" = CAST(ISNULL(SUM(QUANTITY), 0) AS nvarchar)   + ' ' + CAST(UOM.Description AS nvarchar),           
  "Conversion Unit" = CAST(CAST(ISNULL(SUM(QUANTITY), 0) * i.ConversionFactor AS Decimal(18,6)) AS nvarchar)  + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),          
  "Reporting UOM" = CAST(CAST(ISNULL(SUM(QUANTITY), 0) / (CASE i.ReportingUnit WHEN 0 THEN 1 ELSE i.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)   + ' ' + CAST((SELECT Description From UOM Where UOM = i.ReportingUOM ) AS nvarchar),          
  "On Hand Value" =         
  case @StockVal        
  When 'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.Sale_Price, 0)) End) End)  
  When 'PTR' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.Purchase_Price, 0)) End) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.ECP, 0)) End) End)  
   When 'MRP' Then      
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I.MRP, 0)End)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.Company_Price, 0)) End) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End,       
 "Free OnHand Qty" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(free, 0) = 1 and batch_products.Product_code = i.Product_code and GRNAbstract.VendorID = g.VendorID        
   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,          
 "Damages Qty" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(damage, 0) = 1 and batch_products.Product_code = i.Product_code and  GRNAbstract.VendorID = g.VendorID       
   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,          
 "Damages Value" = isnull((select       
 case @StockVal        
 When 'SalePrice'  Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Sale_Price, 0)) End)  
 When 'PurchasePrice' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Purchase_Price, 0)) End)  
--  When 'ECP' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)  
  When 'MRP' Then      
  isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)       
--  When 'Special Price' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)  
 Else      
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
 End  
  from  GRNAbstract, Batch_Products, Items It , ItemCategories IC where It.CategoryID = IC.CategoryID And isnull(damage, 0) = 1 and  batch_products.Product_code = i.Product_code and         
   Batch_Products.Product_Code = It.Product_Code AND         
   GRNAbstract.VendorID = g.VendorID AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0),           
 "Saleable Stock" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(damage, 0) = 0 and isnull(free, 0) = 0 and GRNAbstract.VendorID = g.VendorID       
   and  batch_products.Product_code = i.Product_code   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0)          
      
 FROM        
  Items i, Batch_Products, GRNAbstract g, UOM, ConversionTable , ItemCategories IC          
 WHERE   i.Product_Code = Batch_Products.Product_Code           
  AND I.CategoryID = IC.CategoryID  
  AND Batch_Products.GRN_ID = g.GRNID          
  AND g.VendorID = @VENDOR          
  AND i.UOM *= UOM.UOM          
  AND i.ConversionUnit *= ConversionTable.ConversionID          
  And i.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
  and i.active = 1      
  and ISNULL(Batch_Products.Quantity, 0) > 0      
 GROUP BY i.Product_Code, i.ProductName,           
  i.ConversionUnit, i.ReportingUnit, i.ReportingUOM,            
  UOM.Description, ConversionTable.ConversionUnit, i.ConversionFactor  , g.vendorid        
end      
else      
begin      
 Select  i.Product_Code,         
  "Item Code" = i.Product_Code,           
  "Item Name" = i.ProductName,           
  "On Hand Qty" = CAST(ISNULL(SUM(QUANTITY), 0) AS nvarchar)   + ' ' + CAST(UOM.Description AS nvarchar),           
  "Conversion Unit" = CAST(CAST(ISNULL(SUM(QUANTITY), 0) * i.ConversionFactor AS Decimal(18,6)) AS nvarchar)  + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),          
  "Reporting UOM" = CAST(CAST(ISNULL(SUM(QUANTITY), 0) / (CASE i.ReportingUnit WHEN 0 THEN 1 ELSE i.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)   + ' ' + CAST((SELECT Description From UOM Where UOM = i.ReportingUOM ) AS nvarchar),          
  "On Hand Value" =         
  case @StockVal        
  When 'SalePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.Sale_Price, 0)) End) End)  
  When 'PurchasePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.Purchase_Price, 0)) End) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.ECP, 0)) End) End)  
   When 'MRP' Then      
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I.MRP, 0)End)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.Company_Price, 0)) End) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End,       
 "Free OnHand Qty" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(free, 0) = 1 and batch_products.Product_code = i.Product_code and GRNAbstract.VendorID = g.VendorID        
   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,          
 "Damages Qty" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(damage, 0) = 1 and batch_products.Product_code = i.Product_code and GRNAbstract.VendorID = g.VendorID       
   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,          
      
 "Damages Value" = isnull((select       
 case @StockVal        
 When 'SalePrice'  Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Sale_Price, 0)) End)  
 When 'PurchasePrice' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Purchase_Price, 0)) End)  
--  When 'ECP' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
  When 'MRP' Then      
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
--  When 'Special Price' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
 Else      
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
 End  
   from  GRNAbstract, Batch_Products, Items , ItemCategories IC where Items.CategoryID = IC.CategoryID And isnull(damage, 0) = 1 and  batch_products.Product_code = i.Product_code and         
   Batch_products.Product_Code = Items.Product_Code AND       
   GRNAbstract.VendorID = g.VendorID AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0),           
      
 "Saleable Stock" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(damage, 0) = 0 and isnull(free, 0) = 0 and GRNAbstract.VendorID = g.VendorID       
   and  batch_products.Product_code = i.Product_code   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0)          
 FROM        
  Items i, Batch_Products, GRNAbstract g, UOM , ConversionTable , ItemCategories IC
 WHERE   i.Product_Code = Batch_Products.Product_Code           
  AND Batch_Products.GRN_ID = g.GRNID          
  AND I.CategoryID = IC.CategoryID  
  AND g.VendorID = @VENDOR          
  AND i.UOM *= UOM.UOM     
  AND i.ConversionUnit *= ConversionTable.ConversionID          
  And i.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
  and i.active = 1      
 GROUP BY i.Product_Code, i.ProductName,           
  i.ConversionUnit, i.ReportingUnit, i.ReportingUOM,            
  UOM.Description, ConversionTable.ConversionUnit, i.ConversionFactor  , g.vendorid   
end
