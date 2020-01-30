CREATE PROCEDURE spr_list_stock_ledger_by_vendors_fmcg(@VENDOR nvarchar(2550),   
@ShowItems nvarchar(50), @StockVal nvarchar(100))          
AS          
  
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
Create table #tmpVendor(VendorName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @VENDOR='%'     
   Insert into #tmpVendor select Vendor_Name from Vendors    
Else    
   Insert into #tmpVendor select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)    
  
DECLARE @ONHAND Decimal(18,6)        
DECLARE @FREE Decimal(18,6)        
DECLARE @DAMAGE Decimal(18,6)        
IF @ShowItems = 'Items with stock'      
BEGIN      
Select  g.VendorID,         
  "Vendor" = Vendors.Vendor_Name,           
  "Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0)  ,           
  "Total On Hand Value" =         
   case @StockVal        
   When 'PurchasePrice'  Then      
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.Purchase_Price, 0)) End) End)  
   When 'SalePrice' Then      
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.Sale_Price, 0)) End) End)  
--    When 'ECP' Then      
--    Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End) End)  
   When 'MRP' Then      
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(It.MRP, 0)End)),0)       
--    When 'Special Price' Then      
--    Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End) End)  
    Else      
    isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
   End,   
        
 "Saleable Stock" = isnull((select  sum(batch_products.Quantity) from           
     GRNAbstract, Batch_Products where         
     isnull(damage, 0) = 0 and isnull(free, 0) = 0 and GRNAbstract.VendorID = g.VendorID           
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0),        
 "Saleable Value" = isnull((select        
 case @StockVal        
 When 'PurchasePrice'  Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Purchase_Price, 0)) End)  
 When 'SalePrice' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Sale_Price, 0)) End)  
--  When 'ECP' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)  
 When 'MRP' Then      
 isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)       
--  When 'Special Price' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
 End  
     from GRNAbstract, Batch_Products, Items It, ItemCategories IC where         
  It.CategoryID = IC.CategoryID And  
     isnull(damage, 0) = 0 and isnull(free, 0) = 0 and GRNAbstract.VendorID = g.VendorID           
     AND Batch_Products.Product_Code = It.Product_Code       
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0),        
 "Free OnHand Qty" = isnull((select  sum(batch_products.Quantity) from           
     GRNAbstract, Batch_Products where         
     isnull(free, 0) = 1 and GRNAbstract.VendorID = g.VendorID           
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,       
 "Damages Qty" = isnull((select  sum(batch_products.Quantity) from           
     GRNAbstract, Batch_Products where         
     isnull(damage, 0) = 1 and GRNAbstract.VendorID = g.VendorID           
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,        
 "Damages Value" = isnull((select       
 case @StockVal        
 When 'PurchasePrice'  Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Purchase_Price, 0)) End)  
 When 'SalePrice' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Sale_Price, 0)) End)  
--  When 'ECP' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)  
 When 'MRP' Then      
 isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)       
--  When 'Special Price' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)  
 Else      
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
 End  
    From GRNAbstract, Batch_Products, Items It , ItemCategories IC where         
    isnull(damage, 0) = 1 and GRNAbstract.VendorID = g.VendorID           
    AND Batch_Products.Product_Code = It.Product_Code       
    AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0)        
from GRNAbstract g, Batch_Products, Vendors, Items It , ItemCategories IC  
WHERE  g.VendorID = Vendors.VendorID          
 And It.CategoryID = IC.CategoryID   
 AND Batch_Products.GRN_ID = g.GRNID          
 AND Vendors.Vendor_Name In (Select VendorName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVendor)
 AND Batch_Products.Product_Code = It.Product_Code       
 and vendors.active = 1      
GROUP BY         
 g.VendorID, Vendors.Vendor_Name         
HAVING ISNULL(SUM(QUANTITY), 0) > 0           
END      

ELSE      

BEGIN      
Select  g.VendorID,         
 "Vendor" = Vendors.Vendor_Name,           
 "Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0)  ,         
 "Total On Hand Value" =         
  case @StockVal        
  When 'PurchasePrice'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.Purchase_Price, 0)) End) End)  
  When 'SalePrice' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.Sale_Price, 0)) End) End)  
--   When 'ECP' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End) End)  
  When 'MRP' Then      
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(It.MRP, 0)End)),0)       
--   When 'Special Price' Then      
--   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End,        
 "Saleable Stock" = isnull((select  sum(batch_products.Quantity) from           
     GRNAbstract, Batch_Products where         
     isnull(damage, 0) = 0 and isnull(free, 0) = 0 and GRNAbstract.VendorID = g.VendorID           
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0),        
 "Saleable Value" = isnull((select       
 case @StockVal        
 When 'PurchasePrice'  Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Purchase_Price, 0)) End)  
 When 'SalePrice' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Sale_Price, 0)) End)  
--  When 'ECP' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)  
 When 'MRP' Then      
 isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)       
--  When 'Special Price' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)  
 Else      
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
 End  
     from GRNAbstract, Batch_Products, Items It , ItemCategories IC where         
  It.CategoryID = IC.CategoryID And  
     isnull(damage, 0) = 0 and isnull(free, 0) = 0 and GRNAbstract.VendorID = g.VendorID           
     AND Batch_Products.Product_Code = It.Product_Code            
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0),        
 "Free OnHand Qty" = isnull((select  sum(batch_products.Quantity) from           
     GRNAbstract, Batch_Products where         
     isnull(free, 0) = 1 and GRNAbstract.VendorID = g.VendorID           
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,        
 "Damages Qty" = isnull((select  sum(batch_products.Quantity) from           
     GRNAbstract, Batch_Products where         
     isnull(damage, 0) = 1 and GRNAbstract.VendorID = g.VendorID           
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0) ,        
 "Damages Value" = isnull((select       
 case @StockVal        
 When 'PurchasePrice'  Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PurchasePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Purchase_Price, 0)) End)  
 When 'SalePrice' Then      
 Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.SalePrice, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Sale_Price, 0)) End)  
--  When 'ECP' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)  
 When 'MRP' Then      
 isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)       
--  When 'Special Price' Then      
--  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)  
 Else      
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
 End  
     from GRNAbstract, Batch_Products, Items It , ItemCategories IC where         
  It.CategoryID = IC.CategoryID And  
     isnull(damage, 0) = 1 and GRNAbstract.VendorID = g.VendorID           
     AND Batch_Products.Product_Code = It.Product_Code       
     AND Batch_Products.GRN_ID = GRNAbstract.GRNID  ),0)        
from GRNAbstract g, Batch_Products, Vendors, items It , ItemCategories IC       
WHERE  g.VendorID = Vendors.VendorID           
 AND Batch_Products.GRN_ID = g.GRNID          
 AND It.CategoryID = IC.CategoryID  
 AND Batch_Products.Product_Code = It.Product_Code      
 AND Vendors.Vendor_Name In (Select VendorName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVendor)
 and vendors.active = 1      
GROUP BY         
 g.VendorID, Vendors.Vendor_Name         
END      
      
Drop table #tmpVendor    
    


