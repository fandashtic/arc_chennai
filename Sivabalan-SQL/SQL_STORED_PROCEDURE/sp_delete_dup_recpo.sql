create procedure sp_delete_dup_recpo(@ponumber as int)
as
declare @pocode  int
declare @brcode nvarchar(20)
declare @dcount  int

select @pocode = poreference , @brcode = branchforumcode 
from poabstractreceived 
where ponumber = @ponumber

select @dcount = count(*) from poabstractreceived 
where ponumber <> @ponumber
and poreference = @pocode
and branchforumcode = @brcode

if @dcount > 0
begin
update poabstractreceived set status = status | 128 where ponumber = @ponumber
select 1
end
else
begin
select 0
end


