
CREATE PROCEDURE sp_get_MasterCatalog

AS

select * from downloadeditems where [id] in (
select max([id])
from downloadeditems 
where status = 0 
AND CompanyID is NULL
AND DocumentType = 'MasterCatalog'
group by product_id )


