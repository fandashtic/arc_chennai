
create procedure sp_get_comversion as
select componentname,version from 
comversion order by componentname

