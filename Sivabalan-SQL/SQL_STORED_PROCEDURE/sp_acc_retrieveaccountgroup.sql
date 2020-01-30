




CREATE procedure sp_acc_retrieveaccountgroup(@customerid nvarchar(50))
as
Declare @accountid integer
select AccountGroup.GroupID,AccountGroup.GroupName from Customer,AccountsMaster,AccountGroup
where Company_Name = @customerid and Customer.AccountID = AccountsMaster.AccountID
and AccountsMaster.GroupID = AccountGroup.GroupID      






