
Create Procedure sp_acc_import_updatecustomeropeningbalance
As
Declare @CustOpenBal Decimal(18,6),@AccountID Int

DECLARE scandebitcreditnote CURSOR KEYSET FOR
Select sum(balance),Customer.AccountID from DebitNote,Customer where DebitNote.CustomerID=Customer.CustomerID Group By DebitNote.CustomerID,Customer.AccountID
UNION ALL
Select sum(balance),Customer.AccountID from CreditNote,Customer where CreditNote.CustomerID=Customer.CustomerID Group By CreditNote.CustomerID,Customer.AccountID
OPEN scandebitcreditnote
FETCH FROM scandebitcreditnote INTO @CustOpenBal,@AccountID
While @@FETCH_STATUS = 0
Begin
	Update AccountsMaster Set OpeningBalance= IsNull(OpeningBalance,0) + IsNull(@CustOpenBal,0) where AccountID=@AccountID
	FETCH NEXT FROM scandebitcreditnote INTO @CustOpenBal,@AccountID
End
CLOSE scandebitcreditnote
DEALLOCATE scandebitcreditnote

