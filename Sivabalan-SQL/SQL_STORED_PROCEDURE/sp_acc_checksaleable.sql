
create procedure sp_acc_checksaleable(@batchcode int)
as
select isnull(Saleable,0)
from Batch_Assets
where BatchCode = @batchcode



