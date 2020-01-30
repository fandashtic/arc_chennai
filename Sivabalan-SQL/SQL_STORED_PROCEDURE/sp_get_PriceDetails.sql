CREATE procedure [dbo].[sp_get_PriceDetails](@ProductCode nvarchar(30)) as    
    
select  ProductName, Sale_Price, "Percentage" = b.Percentage, Price_Option, Track_Batches, Sale_Tax, Track_Inventory, ECP, PTS, PTR, Company_Price,    
 CAST(ISNULL(b.Percentage, 0) as nvarchar) + '+' + CAST(ISNULL(b.CST_Percentage, 0) as nvarchar),    
 CAST(ISNULL(a.Percentage, 0) as nvarchar) + '+' + CAST(ISNULL(a.CST_Percentage, 0) as nvarchar), Purchase_Price,  
  ISNULL(b.LstApplicableOn, 0) 'LstApplicableOn',  ISNULL(b.LstPartOff, 0) 'LstPartOff',  
  ISNULL(b.CstApplicableOn, 0) 'CstApplicableOn',  ISNULL(b.CstPartOff, 0) 'CstPartOff',  
  ISNULL(a.LstApplicableOn, 0) 'TsLstApplicableOn',  ISNULL(a.LstPartOff, 0) 'TsLstPartOff',  
  ISNULL(a.CstApplicableOn, 0) 'TsCstApplicableOn',  ISNULL(a.CstPartOff, 0) 'TsCstPartOff',  
  ISNULL(b.Tax_Code,0) 'Tax_Code',
  ISNULL(a.Tax_Code,0) 'TaxSuff_Code'      
from Items
Left Outer Join ItemCategories on Items.CategoryID = ItemCategories.CategoryID
Left Outer Join Tax b on Items.Sale_Tax = b.Tax_Code
Left Outer Join Tax a on Items.TaxSuffered = a.Tax_Code
where Items.Product_code = @ProductCode 
--and     
--Items.CategoryID *= ItemCategories.CategoryID and     
--Items.Sale_Tax *= b.Tax_Code and    
--Items.TaxSuffered *= a.Tax_Code    
  


