create procedure sp_acc_checknewreference(@TransactionID Int,@AccountID Int)
as
Select 'Amount' = IsNull(Amount,0),'Balance' = IsNull(Balance,0)
From ManualJournal Where TransactionID = @TransactionID
and AccountID = @AccountID


