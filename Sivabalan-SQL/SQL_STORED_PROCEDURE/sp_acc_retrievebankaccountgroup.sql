




CREATE procedure sp_acc_retrievebankaccountgroup(@accountno nvarchar(50))
as
select AccountGroup.GroupID,AccountGroup.GroupName from Bank,AccountsMaster,AccountGroup
where Account_Number = @accountno and Bank.AccountID = AccountsMaster.AccountID
and AccountsMaster.GroupID = AccountGroup.GroupID      





