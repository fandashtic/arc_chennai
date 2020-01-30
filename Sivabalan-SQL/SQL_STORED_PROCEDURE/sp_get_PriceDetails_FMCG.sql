CREATE procedure [dbo].[sp_get_PriceDetails_FMCG](@ProductCode nvarchar(30)) as  
  
select ProductName, Sale_Price, "Percentage" = a.Percentage, Price_Option, Track_Batches, Sale_Tax, Track_Inventory,   
 CAST(ISNULL(a.Percentage, 0) as nvarchar) + '+' + CAST(ISNULL(a.CST_Percentage, 0) as nvarchar),  
 CAST(ISNULL(b.Percentage, 0) as nvarchar) + '+' + CAST(ISNULL(b.CST_Percentage, 0) as nvarchar) ,
  ISNULL(a.LstApplicableOn, 0) 'LstApplicableOn',  ISNULL(a.LstPartOff, 0) 'LstPartOff',
  ISNULL(a.CstApplicableOn, 0) 'CstApplicableOn',  ISNULL(a.CstPartOff, 0) 'CstPartOff',
  ISNULL(b.LstApplicableOn, 0) 'TsLstApplicableOn',  ISNULL(b.LstPartOff, 0) 'TsLstPartOff',
  ISNULL(b.CstApplicableOn, 0) 'TsCstApplicableOn',  ISNULL(b.CstPartOff, 0) 'TsCstPartOff',
  ISNULL(a.Tax_Code,0) 'Tax_Code'
from Items, ItemCategories, Tax a, Tax b  
where Items.Product_code = @ProductCode and   
Items.CategoryID *= ItemCategories.CategoryID and   
Items.Sale_Tax *= a.Tax_Code and   
Items.TaxSuffered *= b.Tax_Code
