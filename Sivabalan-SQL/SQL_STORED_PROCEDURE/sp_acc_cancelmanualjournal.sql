CREATE procedure sp_acc_cancelmanualjournal(@transactionid integer,@BackDate datetime = NULL)
as 
Declare @AccountID Int
Declare @CurrentDate Datetime 
update GeneralJournal set [Status]=192 where [TransactionID]= @transactionid

-- -- Set @CurrentDate = dbo.stripdatefromtime(getdate())
Set @CurrentDate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))

If @BackDate Is Not Null  
Begin
	If dbo.stripdatefromtime(@BackDate) < @CurrentDate 
	Begin 
		Declare ScanManualJournal Cursor keyset for
		Select AccountID from GeneralJournal where
		TransactionID = @transactionid
		Open ScanManualJournal
		Fetch From ScanManualJournal Into @AccountID
		While @@FETCH_STATUS = 0 
		Begin
			Exec sp_acc_backdatedaccountopeningbalance @BackDate,@AccountID
			Fetch Next From ScanManualJournal Into @AccountID
		End
		Close ScanManualJournal
		Deallocate ScanManualJournal 
	End
End 

