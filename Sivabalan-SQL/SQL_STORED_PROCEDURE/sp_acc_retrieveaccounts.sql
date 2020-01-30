


CREATE procedure sp_acc_retrieveaccounts(@naccountgroup integer,@naccessmode integer)
as 
if @naccessmode=1 
begin
	select groupid,groupname from
	accountgroup where [ParentGroup]=@naccountgroup
	and isnull([Active],0)=1
end
else
if @naccessmode=2 
begin
 select accountid,accountname,groupid from accountsmaster
end











