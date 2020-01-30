CREATE procedure sp_acc_loadclosingbalance(@accountid int,@fromdate datetime,@todate datetime)
as
Select BalanceDate,Debit,Credit
from BankClosingBalance
where BankAccountID = @accountid
and dbo.stripdatefromtime(BalanceDate)
between @fromdate and @todate


