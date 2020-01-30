


create procedure sp_acc_loadactivegroup(@mode integer,@KeyField nvarchar(30)=N'%')
as
select GroupName,GroupID 
from AccountGroup
where isnull([Active],0) =1
and GroupName like @KeyField







