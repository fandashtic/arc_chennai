create procedure sp_ser_checkTaskisActive(@TaskID as nVarchar(50))
as
select TaskID,"Active" = isNull(Active,0)
from TaskMaster where TaskID = @TaskID
