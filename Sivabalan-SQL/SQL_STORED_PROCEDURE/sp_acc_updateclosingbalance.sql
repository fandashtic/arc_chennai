CREATE procedure sp_acc_updateclosingbalance(@bankaccountid int,
@balancedate datetime,@debit decimal(18,6),@credit decimal(18,6),
@transactiondate datetime)
as

If exists(Select Top 1 BankAccountID from BankClosingBalance where BankAccountID = @bankaccountid
and dbo.stripdatefromtime(BalanceDate) = @balancedate)
Begin
	update BankClosingBalance
	Set Debit = @debit,
	    Credit = @credit
	where BankAccountID = @bankaccountid
	and dbo.stripdatefromtime(BalanceDate) = @balancedate
End
Else
Begin
	Insert BankClosingBalance (BankAccountID,
				   BalanceDate,
				   Debit,
				   Credit,
				   TransactionDate)
			    Values(@bankaccountid,
				   @balancedate,
                	           @debit,
				   @credit,
				   @transactiondate)
End


