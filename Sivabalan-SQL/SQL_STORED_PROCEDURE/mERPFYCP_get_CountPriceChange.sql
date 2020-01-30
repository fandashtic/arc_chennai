CREATE PROCEDURE mERPFYCP_get_CountPriceChange ( @yearenddate datetime )
AS
select Count(*) 
from downloadeditems where [id] in (
select max([id])
from downloadeditems where status = 0 
and DocumentType = 'PriceChange' and DocumentDate <= @yearenddate
group by product_id )
group by downloadeditems.companyid 
