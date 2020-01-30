CREATE procedure sp_acc_gj_pettycash (@paymentid integer,@BackDate DATETIME=Null)
as
declare @npaymentmode integer
declare @documentid integer,@ndoctype integer
declare @others integer

declare @paymentdate datetime  
declare @narration nvarchar(256)
declare @otheraccount integer
declare @value decimal(18,6)
declare @uniqueid integer
Declare @Multiple Integer
Declare @PettyCash Integer
Declare @AccountID Integer
Declare @Amount Decimal(18,6)

set @ndoctype=52        /* Constant to store the Document Type*/	
Set @PettyCash = 4 		/* Constant to store Pettycash ID */

Create Table #TempBackdatedPettyCash(AccountID Int) --for backdated operation

select @npaymentmode =[PaymentMode],@paymentdate =[DocumentDate],
@value = ISNULL([Value],0),@otheraccount = ISNULL([Others],0),@others = ExpenseAccount,
@Multiple = isnull(AccountMode,0)
from payments where [DocumentID]=@paymentid

set @narration = 'Petty Cash Payment'

If @otheraccount = @PettyCash /* OLD Implementation */
Begin
	If @Value > 0
	Begin
		begin tran
			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
			select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
		commit tran
		
		begin tran
			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
			select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
		commit tran
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		Values(@documentid,@others,@paymentdate,@value,0,@paymentid,@ndoctype,@narration,@uniqueid)
		Insert Into #TempBackdatedPettyCash(AccountID) Values(@others)
		
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
		Values(@documentid,@otheraccount,@paymentdate,0,@value,@paymentid,@ndoctype,@narration,@uniqueid)
		Insert Into #TempBackdatedPettyCash(AccountID) Values(@otheraccount)	
		Goto GetOut
	End
End
	
If @Value > 0
Begin
	If @otheraccount > 0
	Begin
		begin tran
			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
			select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
		commit tran
		
		begin tran
			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
			select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
		commit tran

		Exec sp_acc_insertGJ @documentid,@otheraccount,@paymentdate,@value,0,@paymentid,@ndoctype,
			 				 @narration,@uniqueid
		Exec sp_acc_insertGJ @documentid,@PettyCash,@paymentdate,0,@value,@paymentid,@ndoctype,
			 				 @narration,@uniqueid
		Insert Into #TempBackdatedPettyCash(AccountID) Values(@otheraccount)
		Insert Into #TempBackdatedPettyCash(AccountID) Values(@PettyCash)	
	End
	Set @uniqueid = 0

	If @Multiple > 0
	Begin
		begin tran
			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
			select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
		commit tran
		
		begin tran
			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
			select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
		commit tran

		Declare PettyCashDetails Cursor for
		Select AccountID,Amount from paymentexpense where PaymentID = @paymentid
		Open PettyCashDetails
		Fetch From PettyCashDetails INTO @AccountID,@Amount
		While @@Fetch_Status = 0
		Begin
			Exec sp_acc_insertGJ @documentid,@AccountID,@paymentdate,@Amount,0,@paymentid,@ndoctype,
				 				 @narration,@uniqueid
			Insert Into #TempBackdatedPettyCash(AccountID) Values(@AccountID)	
			Fetch Next From PettyCashDetails INTO @AccountID,@Amount
		End
		close PettyCashDetails
		Deallocate PettyCashDetails
	End
	Else
	Begin
		begin tran
			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
			select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
		commit tran
		
		begin tran
			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
			select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
		commit tran
		Exec sp_acc_insertGJ @documentid,@others,@paymentdate,@value,0,@paymentid,@ndoctype,
			 				 @narration,@uniqueid
		Insert Into #TempBackdatedPettyCash(AccountID) Values(@others)	
	End

	If @otheraccount > 0
	Begin
		Exec sp_acc_insertGJ @documentid,@otheraccount,@paymentdate,0,@value,@paymentid,@ndoctype,
			 				 @narration,@uniqueid
	End
	Else
	Begin
		Exec sp_acc_insertGJ @documentid,@PettyCash,@paymentdate,0,@value,@paymentid,@ndoctype,
			 				 @narration,@uniqueid
		Insert Into #TempBackdatedPettyCash(AccountID) Values(@PettyCash)	
	End
End
GetOut:
If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedPettyCash
	OPEN scantempbackdatedaccounts
	FETCH FROM scantempbackdatedaccounts INTO @TempAccountID
	WHILE @@FETCH_STATUS =0
	Begin
		Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID
		FETCH NEXT FROM scantempbackdatedaccounts INTO @TempAccountID
	End
	CLOSE scantempbackdatedaccounts
	DEALLOCATE scantempbackdatedaccounts
End
Drop Table #TempBackdatedPettyCash



