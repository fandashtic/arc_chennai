
CREATE PROCEDURE sp_Get_Beat         
AS              
select b.Beatid, b.[Description] 
from Beat B 
where b.active=1
order by b.beatid 

