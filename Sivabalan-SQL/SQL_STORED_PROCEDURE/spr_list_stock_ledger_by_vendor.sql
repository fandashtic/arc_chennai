CREATE PROCEDURE spr_list_stock_ledger_by_vendor(@VENDOR nvarchar(2550),         
 @ShowItems nvarchar(50), @StockVal nvarchar(100),       
 @ItemCode nvarchar(2550))                
AS                
        
Declare @Delimeter as Char(1)          
Set @Delimeter=Char(15)          
      
Declare @tmpVendor table(VendorName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
Declare @tmpProd table(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
      
if @VENDOR='%'           
   Insert into @tmpVendor select Vendor_Name from Vendors          
Else          
   Insert into @tmpVendor select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)          
      
if @ItemCode = '%'      
 Insert InTo @tmpProd Select Product_code From Items      
Else      
 Insert into @tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)      
        
DECLARE @ONHAND Decimal(18,6)              
DECLARE @FREE Decimal(18,6)              
DECLARE @DAMAGE Decimal(18,6)              
IF @ShowItems = 'Items with stock'            
BEGIN            
Select  g.VendorID,               
  "Vendor" = Vendors.Vendor_Name,                 
  "Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0)  ,     
  
 "Total SIT Qty" = IsNull((Select SUM( IR.Pending) FROM InvoiceDetailReceived IR,  InvoiceAbstractReceived GA  
  WHERE IR.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And GA.InvoiceID = IR.InvoiceID 
  And GA.Status & 64 = 0 
  And GA.VendorID = g.VendorID),0),  
  
  "Total On Hand Value" =               
   case @StockVal              
   When 'PTS'  Then            
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.PTS, 0)) End) End)        
   When 'PTR' Then            
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.PTR, 0)) End) End)        
   When 'ECP' Then            
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End) End)        
   When 'MRP' Then            
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(It.MRP, 0)End)),0)             
   When 'Special Price' Then            
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End) End)        
   Else            
   isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
   End,         
  
  "Total SIT Value" =  IsNull((Select             
   case @StockVal              
   When 'PTS'  Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.PTS, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.PTS, 0)) End) End)        
   When 'PTR' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.PTR, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.PTR, 0)) End) End)        
   When 'ECP' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * IsNull((Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End),0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.ECP, 0)) End) End)        
   When 'MRP' Then            
   isnull(Sum((Case IR.SalePrice When 0 Then 0 Else isnull(IR.Pending, 0) * isnull(It.MRP, 0)End)),0)             
   When 'Special Price' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.Company_Price, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.Company_Price, 0)) End) End)        
   Else            
   isnull(Sum(isnull(IR.Pending, 0) * IsNull((Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End),0)),0)                
   End  
   From ItemCategories ICAT, InvoiceDetailReceived IR, Items It, InvoiceAbstractReceived GA  
  WHERE IR.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And GA.InvoiceID = IR.InvoiceID  
  And GA.Status & 64 = 0 
  And GA.VendorID = g.VendorID  
  AND ICAT.CategoryID = It.CategoryID  
  And It.Product_Code = IR.Product_Code),0),  
              
 "Saleable Stock" = isnull((select  sum(batch_products.Quantity) from                 
     GRNAbstract, Batch_Products where               
     isnull(damage, 0) = 0 and isnull(free, 0) = 0 and GRNAbstract.VendorID = g.VendorID                 
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID        
  AND Batch_Products.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)),0),              
  
 "Saleable SIT Qty" = IsNull((select  sum( IR.Pending) from                 
     InvoiceAbstractReceived GA, InvoiceDetailReceived IR   
  where GA.VendorID = g.VendorID   
     AND GA.InvoiceID = IR.InvoiceID       
     And GA.Status & 64 = 0          
  AND IR.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And (IsNull(IR.SalePrice,0) > 0)),0),              
  
 "Saleable Value" = isnull((select              
 case @StockVal              
 When 'PTS'  Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTS, 0)) End)        
 When 'PTR' Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTR, 0)) End)        
 When 'ECP' Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)        
 When 'MRP' Then            
 IsNull(Sum(Case IsNull(Free, 0) When 1 Then 0 Else isnull(Quantity, 0) * isnull(It.MRP, 0) End ), 0)      
 When 'Special Price' Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)        
 Else            
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
 End        
 from GRNAbstract, Batch_Products, Items It, ItemCategories IC   
 where               
 isnull(damage, 0) = 0 and isnull(free, 0) = 0   
 AND It.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
 And It.CategoryID = IC.CategoryID  
 and GRNAbstract.VendorID = g.VendorID                 
 AND Batch_Products.Product_Code = It.Product_Code             
 AND Batch_Products.GRN_ID = GRNAbstract.GRNID),0),     
  
  "Saleable SIT Value" =  IsNull((Select             
   case @StockVal              
   When 'PTS'  Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.PTS, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.PTS, 0)) End) End)        
   When 'PTR' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.PTR, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.PTR, 0)) End) End)        
   When 'ECP' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * IsNull((Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End),0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.ECP, 0)) End) End)        
   When 'MRP' Then            
   isnull(Sum((Case IR.SalePrice When 0 Then 0 Else isnull(IR.Pending, 0) * isnull(It.MRP, 0)End)),0)             
 When 'Special Price' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.Company_Price, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.Company_Price, 0)) End) End)        
   Else            
   isnull(Sum(isnull(IR.Pending, 0) * IsNull((Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End),0)),0)                
   End  
   From ItemCategories ICAT, InvoiceDetailReceived IR, Items It, InvoiceAbstractReceived GA  
  WHERE IR.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And GA.InvoiceID = IR.InvoiceID
  And GA.Status & 64 = 0   
  And GA.VendorID = g.VendorID  
  AND ICAT.CategoryID = It.CategoryID  
  And It.Product_Code = IR.Product_Code  
  And IsNull(IR.SalePrice,0) > 0),0),  
  
           
 "Free OnHand Qty" = isnull((select  sum(batch_products.Quantity)   
 from GRNAbstract, Batch_Products   
 where               
 isnull(free, 0) = 1 And IsNull(Damage, 0) <> 1   
 AND Batch_Products.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
 and GRNAbstract.VendorID = g.VendorID                 
 AND Batch_Products.GRN_ID = GRNAbstract.GRNID),0),              
  
 "Free SIT Qty" = IsNull((select  sum( IR.Pending) from                 
     InvoiceAbstractReceived GA, InvoiceDetailReceived IR   
  where GA.VendorID = g.VendorID   
     AND GA.InvoiceID = IR.InvoiceID  
     And GA.Status & 64 = 0              
  AND IR.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And (IsNull(IR.SalePrice,0) = 0)),0),   
  
 "Damages Qty" = isnull((select  sum(batch_products.Quantity) from                 
  GRNAbstract, Batch_Products where               
  isnull(damage, 0) = 1 and GRNAbstract.VendorID = g.VendorID                 
  AND Batch_Products.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  AND Batch_Products.GRN_ID = GRNAbstract.GRNID),0) ,              
 "Damages Value" = isnull((select             
 case @StockVal              
 When 'PTS'  Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTS, 0)) End)        
 When 'PTR' Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTR, 0)) End)        
 When 'ECP' Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)        
 When 'MRP' Then            
 IsNull(Sum(Case IsNull(Free, 0) When 1 Then 0 Else isnull(Quantity, 0) * isnull(It.MRP, 0) End ), 0)      
 When 'Special Price' Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)        
 Else            
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
 End        
    From GRNAbstract, Batch_Products, Items It , ItemCategories IC   
 where               
    isnull(damage, 0) = 1   
 AND It.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
 and GRNAbstract.VendorID = g.VendorID                 
    AND Batch_Products.Product_Code = It.Product_Code             
    AND Batch_Products.GRN_ID = GRNAbstract.GRNID),0)              
From GRNAbstract g, Batch_Products, Vendors, Items It , ItemCategories IC        
WHERE    
 vendors.active = 1            
 AND Vendors.Vendor_Name In (Select VendorName COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpVendor)       
 AND It.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)      
 and g.VendorID = Vendors.VendorID                
 And It.CategoryID = IC.CategoryID         
 AND Batch_Products.GRN_ID = g.GRNID                
 AND Batch_Products.Product_Code = It.Product_Code             
 GROUP BY               
 g.VendorID, Vendors.Vendor_Name               
HAVING ISNULL(SUM(QUANTITY), 0) > 0                 
END            
ELSE            
BEGIN            
Select  g.VendorID,               
 "Vendor" = Vendors.Vendor_Name,                 
 "Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0),      
  
 "Total SIT Qty" = IsNull(( Select SUM( IR.Pending) FROM InvoiceDetailReceived IR, InvoiceAbstractReceived GA  
  WHERE IR.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And GA.InvoiceID = IR.InvoiceID
  And GA.Status & 64 = 0  
  And GA.VendorID = g.VendorID),0),  
           
 "Total On Hand Value" =               
  case @StockVal              
  When 'PTS'  Then            
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.PTS, 0)) End) End)        
  When 'PTR' Then            
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.PTR, 0)) End) End)        
  When 'ECP' Then            
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End) End)        
  When 'MRP' Then            
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(It.MRP, 0)End)),0)             
  When 'Special Price' Then            
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End,        
  
  "Total SIT Value" =  IsNull((Select             
   case @StockVal              
   When 'PTS'  Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.PTS, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.PTS, 0)) End) End)        
   When 'PTR' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.PTR, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.PTR, 0)) End) End)        
   When 'ECP' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * IsNull((Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End), 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.ECP, 0)) End) End)        
   When 'MRP' Then            
   isnull(Sum((Case IR.SalePrice When 0 Then 0 Else isnull(IR.Pending, 0) * isnull(It.MRP, 0)End)),0)             
   When 'Special Price' Then            
   Sum(Case ICAT.Price_Option When 1 Then (Isnull(IR.Pending, 0) * Isnull(IR.Company_Price, 0)) Else (Case IR.SalePrice When 0 Then 0 Else (Isnull(IR.Pending, 0) * Isnull(It.Company_Price, 0)) End) End)        
   Else            
   isnull(Sum(isnull(IR.Pending, 0) * IsNull((Case IT.Purchased_At When 1 then IR.PTS Else IR.PTR End),0)),0)                
   End  
   From ItemCategories ICAT, InvoiceDetailReceived IR, Items It, InvoiceAbstractReceived GA  
  WHERE IR.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And GA.InvoiceID = IR.InvoiceID  
  And GA.Status & 64 = 0
  And GA.VendorID = g.VendorID  
  AND ICAT.CategoryID = It.CategoryID  
  And It.Product_Code = IR.Product_Code),0),        
  
 "Saleable Stock" = isnull((select  sum(batch_products.Quantity) from                 
     GRNAbstract, Batch_Products   
  where               
     isnull(damage, 0) = 0 and isnull(free, 0) = 0   
  AND Batch_Products.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  and GRNAbstract.VendorID = g.VendorID                 
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID),0),    
  
 "Saleable SIT Qty" = IsNull((select  sum( IR.Pending) from                 
     InvoiceAbstractReceived GA, InvoiceDetailReceived IR   
  where GA.VendorID = g.VendorID   
     AND GA.InvoiceID = IR.InvoiceID                
     And GA.Status & 64 = 0
  AND IR.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And (IsNull(IR.SalePrice,0) > 0)),0),              
  
 "Saleable Value" = isnull((select             
case @StockVal              
When 'PTS'  Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTS, 0)) End)        
 When 'PTR' Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTR, 0)) End)        
 When 'ECP' Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)        
 When 'MRP' Then            
 isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)             
 When 'Special Price' Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)        
 Else            
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
 End        
     from GRNAbstract, Batch_Products, Items It , ItemCategories IC   
  where               
     isnull(damage, 0) = 0 and isnull(free, 0) = 0   
  AND It.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And It.CategoryID = IC.CategoryID   
  and GRNAbstract.VendorID = g.VendorID                 
     AND Batch_Products.Product_Code = It.Product_Code                  
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID),0),       
  
  
  "Saleable SIT Value" =  IsNull((Select             
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
  WHERE IR.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And GA.InvoiceID = IR.InvoiceID  
  And GA.Status & 64 = 0
  And GA.VendorID = g.VendorID  
  AND ICAT.CategoryID = It.CategoryID  
  And It.Product_Code = IR.Product_Code  
  And IsNull(IR.SalePrice,0) > 0),0),  
  
 "Free OnHand Qty" = isnull((select  sum(batch_products.Quantity) from                 
     GRNAbstract, Batch_Products where               
     isnull(free, 0) = 1 And IsNull(Damage, 0) <> 1   
  AND Batch_Products.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  and GRNAbstract.VendorID = g.VendorID                 
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID),0) ,       
  
 "Free SIT Qty" = IsNull((select  sum( IR.Pending) from                 
     InvoiceAbstractReceived GA, InvoiceDetailReceived IR   
  where GA.VendorID = g.VendorID   
     AND GA.InvoiceID = IR.InvoiceID                
     And GA.Status & 64 = 0
  AND IR.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And (IsNull(IR.SalePrice,0) = 0)),0),          
  
 "Damages Qty" = isnull((select  sum(batch_products.Quantity) from                 
     GRNAbstract, Batch_Products   
  where               
     isnull(damage, 0) = 1   
  AND Batch_Products.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  and GRNAbstract.VendorID = g.VendorID                 
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID),0) ,              
 "Damages Value" = isnull((select             
 case @StockVal              
 When 'PTS'  Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTS, 0)) End)        
 When 'PTR' Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTR, 0)) End)        
 When 'ECP' Then            
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)        
 When 'MRP' Then            
 IsNull(Sum(Case IsNull(Free, 0) When 1 Then 0 Else isnull(Quantity, 0) * isnull(It.MRP, 0) End ), 0)      
 When 'Special Price' Then        
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)        
 Else            
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
 End        
     from GRNAbstract, Batch_Products, Items It , ItemCategories IC   
  where               
     isnull(damage, 0) = 1   
  AND It.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
  And It.CategoryID = IC.CategoryID  
     and GRNAbstract.VendorID = g.VendorID                 
     AND Batch_Products.Product_Code = It.Product_Code             
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID),0)              
from GRNAbstract g, Batch_Products, Vendors, items It , ItemCategories IC             
WHERE    
 vendors.active = 1            
 AND Vendors.Vendor_Name In (Select VendorName COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpVendor)      
 AND it.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)      
 and g.VendorID = Vendors.VendorID                 
 AND Batch_Products.GRN_ID = g.GRNID                
 AND It.CategoryID = IC.CategoryID        
 AND Batch_Products.Product_Code = It.Product_Code            
 GROUP BY               
 g.VendorID, Vendors.Vendor_Name               
END          

