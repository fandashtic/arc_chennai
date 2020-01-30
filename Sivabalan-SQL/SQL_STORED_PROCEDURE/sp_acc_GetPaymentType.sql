create procedure sp_acc_GetPaymentType(@AccountID Int)
as
Select PaymentType from AccountsMaster,PaymentMode
Where AccountsMaster.AccountID = @AccountID
and AccountsMaster.RetailPaymentMode = PaymentMode.Mode

