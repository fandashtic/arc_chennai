
CREATE PROCEDURE sp_get_PriceChange(@COMPANYID NVARCHAR(15))

AS

select * from downloadeditems where [id] in (
select max([id])
from downloadeditems where status = 0 
AND CompanyID = @COMPANYID
AND DocumentType = 'PriceChange'
group by product_id )order by companyid


