CREATE Procedure [dbo].[sp_define_beat]
as
select b.beatid, b.description ,s.salesmanid , s.salesman_name 
from beat b
Inner Join beat_salesman bs on b.beatid = bs.beatid
Left Outer Join salesman s on bs.salesmanid = s.salesmanid
where
--b.beatid = bs.beatid 
--and bs.salesmanid *= s.salesmanid 
--and 
b.Active = 1
group by b.beatid, b.description ,s.salesmanid , s.salesman_name 


