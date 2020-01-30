CREATE procedure [dbo].[sp_calculate_componenttax](@ComboId int,@Locality int)  
as  
if(@Locality=1)  
select t1.component_item_code,"Purchase Price"=case items.purchased_at when 1 then t1.Pts when 2 then t1.ptr end,Quantity,"Tax"=case Free when 1 then 0 else Isnull(percentage,0) end,t1.PTS,t1.PTR,t1.ECP,t1.specialPrice,items.taxsuffered,1 as TaxType 
from  combo_components t1 
Inner Join items on t1.component_item_code=items.product_code 
Left Outer Join tax on items.taxsuffered = tax.tax_code
where t1.comboId=@comboid 
--and t1.component_item_code=items.product_code  
--and items.taxsuffered*=tax.tax_code  
else  
select t1.component_item_code,"Purchase Price"=case items.purchased_at when 1 then t1.Pts when 2 then t1.ptr end,Quantity,"Tax"=case Free when 1 then 0 else Isnull(cst_percentage,0) end,t1.PTS,t1.PTR,t1.ECP,t1.specialPrice,items.taxsuffered,2 as TaxType 
from combo_components t1
Inner Join items on t1.component_item_code = items.product_code
Left Outer Join tax on items.taxsuffered = tax.tax_code
where t1.comboId=@ComboId 
--and t1.component_item_code=items.product_code  
--and items.taxsuffered*=tax.tax_code  
