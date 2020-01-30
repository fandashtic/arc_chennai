CREATE procedure sp_acc_cancelinternalcontradetail(@contraid int,@denominations nvarchar(2000),
@fromaccountid int,@toaccountid int)
as
Declare @CASH int
Set @CASH = 1
Update ContraDetail
Set Denominations = @denominations
where ContraID = @contraid
and PaymentType = @CASH
and FromAccountID = @fromaccountid
and ToAccountID = @toaccountid



