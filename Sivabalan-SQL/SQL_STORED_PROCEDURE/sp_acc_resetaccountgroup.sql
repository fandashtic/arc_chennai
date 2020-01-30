create procedure sp_acc_resetaccountgroup
as
Update AccountsMaster
Set GroupID = DefaultGroupID
Where IsNull(Fixed,0) = 1 
