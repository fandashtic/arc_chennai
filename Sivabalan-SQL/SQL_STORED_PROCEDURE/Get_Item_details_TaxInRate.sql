CREATE Procedure Get_Item_details_TaxInRate @Product_Code nvarchar(30), @Locality int = 1       
As      
Select        
  Product_Code,         
  ProductName,      
  Isnull(TaxInclusive,0) IsTI ,       
  (Case @Locality       
  When 2 then      
   Isnull(a.cst_Percentage,0)      
  Else      
   Isnull(a.Percentage,0)       
  End) Sale_Tax_Per  ,    
  (Case @Locality       
  When 2 then      
   Isnull(b.cst_Percentage,0)      
  Else      
   Isnull(b.Percentage,0)       
  End) TaxSuffered,  
  Vat,  
  CollectTaxSuffered,  
  MRP    
from  Items
Left Outer Join Tax  a On Items.Sale_Tax = a.Tax_Code
Right Outer Join Tax b On  b.Tax_Code = items.TaxSuffered   
Where Items.Product_Code like @Product_Code      
   
