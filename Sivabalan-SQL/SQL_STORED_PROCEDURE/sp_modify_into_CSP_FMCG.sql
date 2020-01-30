CREATE Procedure sp_modify_into_CSP_FMCG (@Categoryid int)
as
update batch_products set batch_products.SalePrice = items.Sale_Price
from items, batch_products 
where Items.product_code = batch_products.product_code 
	and isnull(free,0) = 0
	and IsNull(batch_products.SalePrice,0) = 0 
	and Items.Categoryid = @Categoryid

