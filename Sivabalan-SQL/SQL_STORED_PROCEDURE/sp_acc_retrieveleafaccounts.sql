


CREATE procedure sp_acc_retrieveleafaccounts(@accountgroup integer)
as 
select accountid,accountname,groupid,Active from accountsmaster where [GroupID]=@accountgroup



