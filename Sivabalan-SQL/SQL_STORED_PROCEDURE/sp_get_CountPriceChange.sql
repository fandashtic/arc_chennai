
CREATE PROCEDURE sp_get_CountPriceChange

AS

select Count(*) 
from downloadeditems where [id] in (
select max([id])
from downloadeditems where status = 0 
and DocumentType = 'PriceChange'
group by product_id )
group by downloadeditems.companyid 

