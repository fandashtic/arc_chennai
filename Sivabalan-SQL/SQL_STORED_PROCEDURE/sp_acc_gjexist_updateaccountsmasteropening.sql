CREATE Procedure sp_acc_gjexist_updateaccountsmasteropening
As
Declare @AccountID int
Declare @Amount Decimal (18,6)
DECLARE scanoutstanading CURSOR KEYSET FOR
Select AccountID,Sum(Amount) from TempOpeningDetails Group By AccountID
OPEN scanoutstanading
FETCH FROM scanoutstanading INTO @AccountID,@Amount
While @@FETCH_STATUS=0
Begin
	If IsNull(@Amount,0) <> 0
	Begin
		Update AccountsMaster Set OpeningBalance=IsNull(OpeningBalance,0)+ @Amount Where AccountID=@AccountID
	End
	FETCH NEXT FROM scanoutstanading INTO @AccountID,@Amount
End
CLOSE scanoutstanading
DEALLOCATE scanoutstanading

