CREATE PROCEDURE spr_list_stock_ledger_vendor_details(@VENDOR nvarchar(15),   
 @ShowItems nvarchar(50), @StockVal nvarchar(100),  
 @ItemCode nvarchar(2550), @ItemName nvarchar(255))            
AS          
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
if @ItemCode = N'%'  
 Insert InTo #tmpProd Select Product_code From Items  
Else  
 Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)  
  
--This table is to display the categories in the Order  
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)    
Exec sp_CatLevelwise_ItemSorting   
  
if @ShowItems = N'Items with stock'      
begin      
 Select  i.Product_Code,         
  "Item Code" = i.Product_Code,           
  "Item Name" = i.ProductName,           
  "On Hand Qty" = CAST(ISNULL(SUM(QUANTITY), 0) AS nvarchar)   + N' ' + CAST(UOM.Description AS nvarchar),    
  
  "On Hand SIT Qty" = CAST((Select IsNull(SUM( IR.Pending),0)  from InvoiceDetailReceived IR, InvoiceAbstractReceived AR  
     Where AR.InvoiceID = IR.InvoiceID  
     And AR.Status & 64 = 0
  And AR.VendorID = @VENDOR  
  And IR.Product_Code = i.Product_Code) AS nvarchar)  
  + N' ' + CAST(UOM.Description AS nvarchar),        
  
  "Conversion Unit" = CAST(CAST(ISNULL(SUM(QUANTITY), 0) * i.ConversionFactor AS Decimal(18,6)) AS nvarchar)  + N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),          
 "Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(i.Product_Code, SUM(IsNull(QUANTITY, 0))) As nvarchar) + N'' +  CAST((SELECT Description From UOM Where UOM = i.ReportingUOM ) AS nvarchar),  
--   "Reporting UOM" = CAST(CAST(ISNULL(SUM(QUANTITY), 0) / (CASE i.ReportingUOM WHEN 0 THEN 1 ELSE i.ReportingUOM END)AS Decimal(18,6)) AS nvarchar)   + ' ' + CAST((SELECT Description From UOM Where UOM = i.ReportingUOM ) AS nvarchar),          
  "On Hand Value" =         
  case @StockVal        
  When N'PTS'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.PTS, 0)) End) End)  
  When N'PTR' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.PTR, 0)) End) End)  
  When N'ECP' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.ECP, 0)) End) End)  
  When N'MRP' Then      
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I.MRP, 0)End)),0)       
  When N'Special Price' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.Company_Price, 0)) End) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End,      
  
  "On Hand SIT Value" =  IsNull((Select             
   case @StockVal              
   When 'PTS'  Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.PTS, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.PTS, 0)) End) End)        
   When 'PTR' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.PTR, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.PTR, 0)) End) End)        
   When 'ECP' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull((Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End), 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.ECP, 0)) End) End)        
   When 'MRP' Then            
   isnull(Sum((Case IR.SalePrice When 0 Then 0 Else isnull(IR.Pending, 0) * isnull(It.MRP, 0)End)),0)             
   When 'Special Price' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.Company_Price, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.Company_Price, 0)) End) End)        
   Else            
   isnull(Sum(isnull(IR.Pending, 0) * isnull((Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End), 0)),0)                
   End  
   From ItemCategories ICAT, InvoiceDetailReceived IR, Items It, InvoiceAbstractReceived GA  
  WHERE GA.InvoiceID = IR.InvoiceID  
  And GA.Status & 64 = 0
  And GA.VendorID = @VENDOR  
  AND ICAT.CategoryID = It.CategoryID  
  And IR.Product_Code = It.Product_Code  
  And It.Product_Code = i.Product_Code),0),  
   
 "Free OnHand Qty" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(free, 0) = 1 And IsNull(Damage, 0) <> 1 and batch_products.Product_code = i.Product_code and GRNAbstract.VendorID = g.VendorID        
   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,       
  
 "Free SIT Qty" = IsNull((select  sum( IR.Pending) from                 
     InvoiceAbstractReceived GA, InvoiceDetailReceived IR   
  where GA.VendorID = @VENDOR   
     And GA.Status & 64 = 0 
     AND GA.InvoiceID = IR.InvoiceID                
  AND IR.Product_Code = i.Product_Code  
  And (IsNull(IR.SalePrice,0) = 0)),0),   
     
 "Damages Qty" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(damage, 0) = 1 and batch_products.Product_code = i.Product_code and  GRNAbstract.VendorID = g.VendorID       
   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,          
 "Damages Value" = isnull((select       
 case @StockVal        
 When N'PTS'  Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTS, 0)) End)  
 When N'PTR' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTR, 0)) End)  
 When N'ECP' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)  
 When N'MRP' Then      
 IsNull(Sum(Case IsNull(Free, 0) When 1 Then 0 Else isnull(Quantity, 0) * isnull(It.MRP, 0) End ), 0)  
 When N'Special Price' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)  
 Else      
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
 End  
  from  GRNAbstract, Batch_Products, Items It , ItemCategories IC where It.CategoryID = IC.CategoryID And isnull(damage, 0) = 1 and  batch_products.Product_code = i.Product_code and         
   Batch_Products.Product_Code = It.Product_Code AND         
   GRNAbstract.VendorID = g.VendorID AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0),           
 "Saleable Stock" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(damage, 0) = 0 and isnull(free, 0) = 0 and GRNAbstract.VendorID = g.VendorID       
   and  batch_products.Product_code = i.Product_code   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0)          
      
 FROM        
  Items i
  Inner Join  Batch_Products On  i.Product_Code = Batch_Products.Product_Code           
  Inner Join  GRNAbstract g On Batch_Products.GRN_ID = g.GRNID          
  Left Outer Join  UOM On i.UOM = UOM.UOM          
  Left Outer Join  ConversionTable On i.ConversionUnit = ConversionTable.ConversionID           
  Inner Join ItemCategories IC On I.CategoryID = IC.CategoryID  
  Inner Join  #tempCategory1 T1 On i.CategoryID = T1.CategoryID             
 WHERE    g.VendorID = @VENDOR          
  AND i.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
--  and i.active = 1      
 And ISNULL(Batch_Products.Quantity, 0) > 0      
 GROUP BY T1.IDS,i.Product_Code, i.ProductName,           
  i.ConversionUnit, i.ReportingUnit, i.ReportingUOM,            
  UOM.Description, ConversionTable.ConversionUnit, i.ConversionFactor  , g.vendorid        
Order By T1.IDS  
end      
else      
begin      
 Select  i.Product_Code,         
  "Item Code" = i.Product_Code,           
  "Item Name" = i.ProductName,           
  "On Hand Qty" = CAST(ISNULL(SUM(QUANTITY), 0) AS nvarchar)   + N' ' + CAST(UOM.Description AS nvarchar),           
  
  "On Hand SIT Qty" = CAST((Select IsNull(SUM(IR.Pending),0)  from InvoiceDetailReceived IR, InvoiceAbstractReceived GA  
     Where GA.InvoiceID = IR.InvoiceID  
  And GA.Status & 64 = 0
  And GA.VendorID = @VENDOR  
  And IR.Product_Code = i.Product_Code) AS nvarchar)  
  + N' ' + CAST(UOM.Description AS nvarchar),              
    
  "Conversion Unit" = CAST(CAST(ISNULL(SUM(QUANTITY), 0) * i.ConversionFactor AS Decimal(18,6)) AS nvarchar)  + N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),          
 "Reporting UOM" = Cast(dbo.sp_Get_ReportingUOMQty(i.Product_Code, SUM(IsNull(QUANTITY, 0))) As nvarchar) + N'' +  CAST((SELECT Description From UOM Where UOM = i.ReportingUOM ) AS nvarchar),  
  
--  "Reporting UOM" = CAST(CAST(ISNULL(SUM(QUANTITY), 0) / (CASE i.ReportingUOM WHEN 0 THEN 1 ELSE i.ReportingUOM END)AS Decimal(18,6)) AS nvarchar)   + ' ' + CAST((SELECT Description From UOM Where UOM = i.ReportingUOM ) AS nvarchar),          
  "On Hand Value" =         
  case @StockVal        
  When N'PTS'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.PTS, 0)) End) End)  
  When N'PTR' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.PTR, 0)) End) End)  
  When N'ECP' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.ECP, 0)) End) End)  
  When N'MRP' Then      
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(I.MRP, 0)End)),0)       
  When N'Special Price' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(I.Company_Price, 0)) End) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End,    
  
  "On Hand SIT Value" =  IsNull((Select             
   case @StockVal              
   When 'PTS'  Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.PTS, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.PTS, 0)) End) End)        
   When 'PTR' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.PTR, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.PTR, 0)) End) End)        
   When 'ECP' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull((Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End), 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.ECP, 0)) End) End)        
   When 'MRP' Then            
   isnull(Sum((Case IR.SalePrice When 0 Then 0 Else isnull(IR.Pending, 0) * isnull(It.MRP, 0)End)),0)             
   When 'Special Price' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.Company_Price, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.Company_Price, 0)) End) End)        
   Else            
   isnull(Sum(isnull(IR.Pending, 0) * isnull((Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End), 0)),0)                
   End  
   From ItemCategories ICAT, InvoiceDetailReceived IR, Items It, InvoiceAbstractReceived GA  
  WHERE GA.InvoiceID = IR.InvoiceID  
  And GA.Status & 64 = 0
  And GA.VendorID = @VENDOR  
  AND ICAT.CategoryID = It.CategoryID  
  And IR.Product_Code = It.Product_Code  
  And It.Product_Code = i.Product_Code),0),  
  
     
 "Free OnHand Qty" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(free, 0) = 1 And IsNull(Damage, 0) <> 1 and batch_products.Product_code = i.Product_code and GRNAbstract.VendorID = g.VendorID        
   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,         
  
 "Free SIT Qty" = IsNull((select  sum( IR.Pending) from                 
     InvoiceAbstractReceived GA, InvoiceDetailReceived IR   
  where GA.VendorID = @VENDOR  
     AND GA.InvoiceID = IR.InvoiceID                
  And GA.Status & 64 = 0
  AND IR.Product_Code = i.Product_Code  
  And (IsNull(IR.SalePrice,0) = 0)),0),   
   
 "Damages Qty" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(damage, 0) = 1 and batch_products.Product_code = i.Product_code and  GRNAbstract.VendorID = g.VendorID       
   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,          
      
 "Damages Value" = isnull((select       
 case @StockVal        
 When N'PTS'  Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End)  
 When N'PTR' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End)  
 When N'ECP' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
 When N'MRP' Then      
 IsNull(Sum(Case IsNull(Free, 0) When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0) End ), 0)  
 When N'Special Price' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
 Else      
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
 End  
   from  GRNAbstract, Batch_Products, Items , ItemCategories IC where Items.CategoryID = IC.CategoryID And isnull(damage, 0) = 1 and  batch_products.Product_code = i.Product_code and         
   Batch_products.Product_Code = Items.Product_Code AND       
   GRNAbstract.VendorID = g.VendorID AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0),           
      
 "Saleable Stock" = isnull((select sum(batch_products.Quantity) from GRNAbstract, Batch_Products where isnull(damage, 0) = 0 and isnull(free, 0) = 0 and GRNAbstract.VendorID = g.VendorID       
   and  batch_products.Product_code = i.Product_code   AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0),          
  
 "Saleable SIT Qty" = IsNull((select  sum( IR.Pending) from                 
     InvoiceAbstractReceived GA, InvoiceDetailReceived IR   
  where GA.VendorID = @VENDOR   
     AND GA.InvoiceID = IR.InvoiceID   
  And GA.Status & 64 = 0             
  AND IR.Product_Code = i.Product_Code  
  And (IsNull(IR.SalePrice,0) > 0)),0)    
  
 FROM        
  Items i
  Inner Join Batch_Products On i.Product_Code = Batch_Products.Product_Code           
  Inner Join GRNAbstract g On Batch_Products.GRN_ID = g.GRNID          
  Left Outer Join UOM On i.UOM = UOM.UOM          
  Left Outer Join ConversionTable On i.ConversionUnit = ConversionTable.ConversionID   
  Inner Join ItemCategories IC On I.CategoryID = IC.CategoryID  
  Inner Join  #tempCategory1 T1 On i.CategoryID = T1.CategoryID             
 WHERE   g.VendorID = @VENDOR          
  AND i.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
--  and i.active = 1      
 GROUP BY T1.IDS, i.Product_Code, i.ProductName,           
  i.ConversionUnit, i.ReportingUnit, i.ReportingUOM,            
  UOM.Description, ConversionTable.ConversionUnit, i.ConversionFactor  , g.vendorid        
 Order By T1.IDS  
end  


