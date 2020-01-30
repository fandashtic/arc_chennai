





CREATE procedure sp_acc_loadspecificaccounts
as
select AccountName,AccountID from AccountsMaster 
where AccountID not in (select AccountID from Bank)
and AccountID not in (3,4,8) 






