CREATE Procedure sp_modify_into_CSP (@Categoryid int)
as
update batch_products set batch_products.PTS = items.PTS, batch_products.PTR = Items.PTR , 
	batch_products.ECP = Items.ECP, batch_products.company_price = Items.company_price 
from items, batch_products 
where Items.product_code = batch_products.product_code 
	and isnull(free,0) = 0
	and IsNull(batch_products.PTS,0) = 0 
	and IsNull(batch_products.PTR,0) = 0 
	and IsNull(batch_products.ECP,0) = 0 
	and IsNull(batch_products.company_price,0) = 0 
	and Items.Categoryid = @Categoryid


