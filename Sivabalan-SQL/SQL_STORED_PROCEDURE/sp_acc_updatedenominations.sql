





CREATE procedure sp_acc_updatedenominations(@denominationcount decimal(18,6),@denominationtitle nvarchar(50))
as
update Denominations
set [DenominationCount]= isnull([DenominationCount],0)- @denominationcount
where [DenominationTitle]=@denominationtitle






