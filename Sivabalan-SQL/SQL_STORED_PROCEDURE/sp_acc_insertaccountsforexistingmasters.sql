CREATE procedure sp_acc_insertaccountsforexistingmasters(@accountname nvarchar(255),@groupid integer,@nActive integer)
as
insert AccountsMaster([AccountName],[GroupID],[Active],[Fixed])
values(@accountname,@groupid,@nActive,0)


