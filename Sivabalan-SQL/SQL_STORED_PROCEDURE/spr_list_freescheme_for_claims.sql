CREATE procedure spr_list_freescheme_for_claims (@ManufacturerID int)                  
as                  
select  SchemeSale.Product_Code,                 
  "Free Item Code" = SchemeSale.Product_Code,                   
  "Free Item Name" = Items.ProductName,                 
  "Pending" = sum(SchemeSale.Pending),             
--  "Cost (Rs)" = SUM(SchemeSale.Cost) / Sum(SchemeSale.Free),            
  "Cost (Rs)" = Max(Items.PTR),
  "TaxSuffered" = IsNull((Select Percentage From Tax where Tax_code = Items.TaxSuffered),0),
  "Remarks" = Schemes.SchemeName,                 
  Type,                 
  "Free Qty" = SUM(Schemesale.Free) ,"SaleType" = SaleType  
from SchemeSale, Items, Schemes , InvoiceAbstract                  
where   Type = Schemes.SchemeID and                   
  Schemes.SchemeType in (17, 18) AND                  
  SchemeSale.Product_Code = Items.Product_Code AND                  
  Items.ManufacturerID = @ManufacturerID AND                  
  (ISNULL(SchemeSale.Claimed, 0) & 1) = 0 AND (ISNULL(SchemeSale.Flags, 0) & 1) = 1              
  and isnull(SchemeSale.Pending, 0) > 0               
  and isnull(SchemeSale.Cost, 0) > 0             
  and SchemeSale.InvoiceID = InvoiceAbstract.InvoiceID            
  and (InvoiceAbstract.Status & 192) = 0             
  And Schemes.SecondaryScheme = 1            
  And Schemes.Active = 1            
  And Isnull(SchemeSale.Saletype,0)<>1      
Group By SchemeSale.Product_code, Items.ProductName, Schemes.SchemeName, Type,SaleType,Items.TaxSuffered -- , isnull(SchemeSale.Pending, 0)                
UNION ALL                  
-- Item Based Amount [Quantity/Value]
select  SchemeSale.Product_Code,                 
  "Item Code" = SchemeSale.Product_Code,                 
  "Item Name" = Items.ProductName,                   
  "Pending" = Sum(isnull(SchemeSale.Pending, 0)),    
  "Cost (Rs)" = Sum(SchemeSale.Cost) /Sum(Schemesale.Free),                   
  "TaxSuffered" = IsNull((Select Percentage From Tax where Tax_code = Items.TaxSuffered),0),
  "Remarks" = Schemes.SchemeName,                 
  Type,                 
  "Quantity" = Sum(Schemesale.Free),"SaleType" = SaleType  
from SchemeSale, Items, Schemes , InvoiceAbstract                  
where   Type = Schemes.SchemeID AND                  
  Schemes.SchemeType in (20, 82) AND                  
  SchemeSale.Product_Code = Items.Product_Code AND                  
  Items.ManufacturerID = @ManufacturerID AND                  
  (ISNULL(SchemeSale.Claimed, 0) & 1) = 0 AND (ISNULL(SchemeSale.Flags, 0) & 1) = 1              
  and isnull(SchemeSale.Pending, 0) > 0                
  and isnull(SchemeSale.Cost, 0) > 0             
  and SchemeSale.InvoiceID = InvoiceAbstract.InvoiceID            
  and (InvoiceAbstract.Status & 192) = 0             
  And Schemes.SecondaryScheme = 1            
  And Schemes.Active = 1          
 group by SchemeSale.Product_Code,Schemes.schemetype,Items.ProductName,    
Schemes.SchemeName,SchemeSale.Type,SchemeSale.SaleType,Items.TaxSuffered
UNION ALL              
-- Item Based Percentage [Quantity/Value]    
select  SchemeSale.Product_Code,                 
  "Item Code" = SchemeSale.Product_Code,                 
  "Item Name" = Items.ProductName,                   
  "Pending" = isnull(SchemeSale.Pending, 0),       
  "Cost (Rs)" = round((SchemeSale.Cost*SchemeSale.Value/100)/SchemeSale.Free, 2),                 
  "TaxSuffered" = IsNull((Select Percentage From Tax where Tax_code = Items.TaxSuffered),0),
  "Remarks" = Schemes.SchemeName,                 
  Type,                 
  "Quantity" = Schemesale.Free,"SaleType" = SaleType  
from SchemeSale, Items, Schemes , InvoiceAbstract                  
where   Type = Schemes.SchemeID AND                   
  Schemes.SchemeType in (19, 81) AND                   
  SchemeSale.Product_Code = Items.Product_Code AND                  
  Items.ManufacturerID = @ManufacturerID AND                  
  (ISNULL(SchemeSale.Claimed, 0) & 1) = 0 AND (ISNULL(SchemeSale.Flags, 0) & 1) = 1              
  and isnull(SchemeSale.Pending, 0) > 0              
  and isnull(SchemeSale.Cost, 0) > 0              
  and SchemeSale.InvoiceID = InvoiceAbstract.InvoiceID            
  and (InvoiceAbstract.Status & 192) = 0             
  And Schemes.SecondaryScheme = 1            
  And Schemes.Active = 1          
UNION ALL            
select  SchemeSale.Product_Code,                 
  "Item Code" = SchemeSale.Product_Code,                 
  "Item Name" = Items.ProductName,                   
  "Pending" = isnull(SchemeSale.Pending, 0),      
--  "Cost (Rs)" = round((SchemeSale.Cost)/SchemeSale.Free, 2),                 
  "Cost (Rs)" = (Items.PTR),
  "TaxSuffered" = IsNull((Select Percentage From Tax where Tax_code = Items.TaxSuffered),0),
  "Remarks" = Schemes.SchemeName,                 
  Type,                 
  "Quantity" = Schemesale.Free,"SaleType" = SaleType  
from SchemeSale, Items, Schemes , InvoiceAbstract       
where   Type = Schemes.SchemeID AND                   
  Schemes.SchemeType in(3, 4) AND                   
  SchemeSale.Product_Code = Items.Product_Code AND                  
  Items.ManufacturerID = @ManufacturerID AND                  
  (ISNULL(SchemeSale.Claimed, 0) & 1) = 0 AND (ISNULL(SchemeSale.Flags, 0) & 1) = 1              
  and isnull(SchemeSale.Pending, 0) > 0               
  and isnull(SchemeSale.Cost, 0) > 0             
  and SchemeSale.InvoiceID = InvoiceAbstract.InvoiceID            
  and (InvoiceAbstract.Status & 192) = 0             
  And Schemes.SecondaryScheme = 1            
  And Schemes.Active = 1          
UNION All          
-- Item Based Same/Diff in STO          
select  SchemeSale.Product_Code,                   
  "Item Code" = SchemeSale.Product_Code,                   
  "Item Name" = Items.ProductName,                     
  "Pending" = isnull(SchemeSale.Pending, 0),          
--  "Cost (Rs)" = (SchemeSale.Cost / SchemeSale.Free),        
  "Cost (Rs)" = (Items.PTR),
  "TaxSuffered" = IsNull((Select Percentage From Tax where Tax_code = Items.TaxSuffered),0),
  "Remarks" = Schemes.SchemeName,                   
  Type,                   
  "Quantity" = Schemesale.Free,"SaleType" = SaleType  
from SchemeSale, Items, Schemes , StockTransferoutabstract                    
where   Type = Schemes.SchemeID and                   
  Schemes.SchemeType in (17, 18) AND                  
  SchemeSale.Product_Code = Items.Product_Code AND                  
  Items.ManufacturerID = @ManufacturerID AND                  
  (ISNULL(SchemeSale.Claimed, 0) & 1) = 0 AND (ISNULL(SchemeSale.Flags, 0) & 1) = 1              
  and isnull(SchemeSale.Pending, 0) > 0               
  and isnull(SchemeSale.Cost, 0) > 0             
  and SchemeSale.InvoiceID = StockTransferoutabstract.DocSerial          
  and (StockTransferoutabstract.Status & 128) = 0             
  And Schemes.SecondaryScheme = 1            
  And Schemes.Active = 1            
  And Schemesale.Saletype = 1          
UNION ALL      
select  SchemeSale.Product_Code,                 
  "Item Code" = SchemeSale.Product_Code,                 
  "Item Name" = Items.ProductName,                   
  "Pending" = isnull(SchemeSale.Pending, 0),    
--  "Cost (Rs)" = round((SchemeSale.Cost*SchemeSale.Value/100)/SchemeSale.Free, 2),                 
  "Cost (Rs)" = (Items.PTR),
  "TaxSuffered" = IsNull((Select Percentage From Tax where Tax_code = Items.TaxSuffered),0),
  "Remarks" = Schemes.SchemeName,                 
  Type,                 
  "Quantity" = Schemesale.Free,"SaleType" = SaleType  
from SchemeSale, Items, Schemes , InvoiceAbstract      
where   Type = Schemes.SchemeID       
  AND Schemes.SchemeType in (21, 22)      
  AND SchemeSale.Product_Code = Items.Product_Code       
  AND Items.ManufacturerID = @ManufacturerID       
  AND (ISNULL(SchemeSale.Claimed, 0) & 1) = 0       
  AND (ISNULL(SchemeSale.Flags, 0) & 1) = 1              
  and isnull(SchemeSale.Pending, 0) > 0                
  and isnull(SchemeSale.Cost, 0) > 0         
  and SchemeSale.InvoiceID = InvoiceAbstract.InvoiceID            
  and (InvoiceAbstract.Status & 192) = 0             
  And Schemes.SecondaryScheme = 1            
  And Schemes.Active = 1        
UNION ALL      
select  SchemeSale.Product_Code,                 
  "Item Code" = SchemeSale.Product_Code,                 
  "Item Name" = Items.ProductName,                   
  "Pending" = isnull(SchemeSale.Pending, 0),                
  --"Cost (Rs)" = SchemeSale.Cost / Schemesale.Free,                 
  "Cost (Rs)" = (Items.PTR),
  "TaxSuffered" = IsNull((Select Percentage From Tax where Tax_code = Items.TaxSuffered),0),
  "Remarks" = Schemes.SchemeName,                 
  Type,                 
  "Quantity" = Schemesale.Free,"SaleType" = SaleType  
from SchemeSale, Items, Schemes , InvoiceAbstract      
where   Type = Schemes.SchemeID       
  AND Schemes.SchemeType in (83, 84, 97, 99)       
  AND SchemeSale.Product_Code = Items.Product_Code       
  AND Items.ManufacturerID = @ManufacturerID       
  AND (ISNULL(SchemeSale.Claimed, 0) & 1) = 0       
  AND (ISNULL(SchemeSale.Flags, 0) & 1) = 1              
  and isnull(SchemeSale.Pending, 0) > 0                
  and isnull(SchemeSale.Cost, 0) > 0         
  and SchemeSale.InvoiceID = InvoiceAbstract.InvoiceID            
  and (InvoiceAbstract.Status & 192) = 0             
  And Schemes.SecondaryScheme = 1            
  And Schemes.Active = 1        

