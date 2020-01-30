
CREATE PROCEDURE sp_get_CntMasterCatalog

AS

select null, null, Count(*) 
from downloadeditems where [id] in (
select max([id])
from downloadeditems where status = 0 
and DocumentType = 'MasterCatalog'
group by product_id )


