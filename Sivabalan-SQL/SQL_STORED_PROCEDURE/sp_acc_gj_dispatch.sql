CREATE Procedure sp_acc_gj_dispatch (@DispatchID INT,@BackDate DATETIME=Null)
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
Set @AccountType =44 --Dispatch

Create Table #TempBackdatedAccountsDispatch(AccountID Int) --for backdated operation

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
	-- Entry for Cash Account
	execute sp_acc_insertGJ @TransactionID,@AccountID1,@DispatchDate,@Value,0,@DispatchID,@AccountType,"Dispatch",@DocumentNumber
	-- Entry for Sales Account
	execute sp_acc_insertGJ @TransactionID,@AccountID2,@DispatchDate,0,@Value,@DispatchID,@AccountType,"Dispatch",@DocumentNumber
	Insert Into #TempBackdatedAccountsDispatch(AccountID) Values(@AccountID1)
	Insert Into #TempBackdatedAccountsDispatch(AccountID) Values(@AccountID2)
End

/*Backdated Operation */

If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccountsDispatch CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedAccountsDispatch
	OPEN scantempbackdatedaccountsDispatch
	FETCH FROM scantempbackdatedaccountsDispatch INTO @TempAccountID
	WHILE @@FETCH_STATUS =0
	Begin
		Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID
		FETCH NEXT FROM scantempbackdatedaccountsDispatch INTO @TempAccountID
	End
	CLOSE scantempbackdatedaccountsDispatch
	DEALLOCATE scantempbackdatedaccountsDispatch
End
Drop Table #TempBackdatedAccountsDispatch



