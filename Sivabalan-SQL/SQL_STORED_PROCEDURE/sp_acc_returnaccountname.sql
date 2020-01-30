CREATE procedure sp_acc_returnaccountname(@accountid int)
as
set dateformat dmy
select AccountName,AccountID,'Balance' = dbo.sp_acc_getaccountbalance(AccountID,dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate())))
from AccountsMaster
where AccountID = @accountid

