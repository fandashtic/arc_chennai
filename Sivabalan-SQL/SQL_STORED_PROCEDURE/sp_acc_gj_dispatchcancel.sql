CREATE Procedure sp_acc_gj_dispatchcancel (@DispatchID INT,@BackDate DATETIME=Null)
AS
--Journal entry for Retail Invoice
Declare @DispatchDate datetime
Declare @Value float
Declare @TransactionID int
Declare @DocumentNumber int



Declare @AccountID1 int
Declare @AccountID2 int
Set @AccountID1 = 28 --Bills Receivable Account
Set @AccountID2 = 35  --Sales on DC Account
Declare @AccountType Int
Set @AccountType =45 --Dispatch

Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation

Select @DispatchDate=DispatchDate from DispatchAbstract where DispatchID=@DispatchID
Select @Value=sum(isnull(Quantity,0)*isnull(SalePrice,0)) from DispatchDetail where DispatchID=@DispatchID

If @Value<>0
Begin
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	-- Entry for Sales on DC Account
	execute sp_acc_insertGJ @TransactionID,@AccountID2,@DispatchDate,@Value,0,@DispatchID,@AccountType,"Dispatch Cancellation",@DocumentNumber
	-- Entry for Bills Receivable Account
	execute sp_acc_insertGJ @TransactionID,@AccountID1,@DispatchDate,0,@Value,@DispatchID,@AccountType,"Dispatch Cancellation",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)
End

/*Backdated Operation */

If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedAccounts
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
Drop Table #TempBackdatedAccounts


