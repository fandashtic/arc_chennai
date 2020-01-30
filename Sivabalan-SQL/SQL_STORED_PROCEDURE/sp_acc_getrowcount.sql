CREATE procedure sp_acc_getrowcount(@accountid int,@fromdate datetime,@todate datetime)
as
Select count(*) from BankClosingBalance
where BankAccountID = @accountid
and dbo.stripdatefromtime(BalanceDate)
between @fromdate and @todate


