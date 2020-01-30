CREATE procedure sp_acc_cancelcontra(@depositid integer,@denominations nvarchar(50))
as
update Deposits
set Status =192,
Denominations = @denominations
where DepositID = @depositid 

