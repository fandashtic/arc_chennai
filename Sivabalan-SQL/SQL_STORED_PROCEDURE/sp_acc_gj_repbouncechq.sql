CREATE Procedure sp_acc_gj_repbouncechq (@DOCUMENTID INT,@BackDate DATETIME=Null)
AS
--Journal entry for represent of bounced cheque
Declare @DocumentDate datetime
Declare @Value float
Declare @BankID int
Declare @CustomerID nvarchar(15)
Declare @TransactionID int
Declare @CustomerAccountID int
Declare @OtherAccountID Int
Declare @BankAccountID int
Declare @DocumentNumber Int
Declare @AccountType Int
Declare @Gift_Voucher Int

Set @Gift_Voucher = 114 /* Gift Voucher Customer */
Set @AccountType =3

Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation

Declare ScanCollections Cursor Keyset For
Select DocumentDate,Value,CustomerID,Deposit_To,Others from Collections where DepositID=@DOCUMENTID
Open ScanAccountMaster
Fetch From ScanCollections Into @DocumentDate,@Value,@CustomerID,@BankID,@OtherAccountID
While @@Fetch_Status=0
Begin
	Select @BankAccountID=AccountID from Bank where BankID=@BankID
	If @CustomerID=N'GIFT VOUCHER'
	Begin
		Set @CustomerAccountID=@Gift_Voucher
	End
	Else
	Begin
 	Select @CustomerAccountID=AccountID from Customer where CustomerID=@CustomerID
	End	
If @Value<>0
Begin
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last DocumentNumber from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	
	-- Entry for Bank Account
	execute sp_acc_insertGJ @TransactionID,@BankAccountID,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Represent of Bouncing Cheque",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@BankAccountID)
	If @CustomerAccountID is not null
	Begin
		-- Entry for Customer Account
		execute sp_acc_insertGJ @TransactionID,@CustomerAccountID,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Represent of Bouncing Cheque",@DocumentNumber
		Insert Into #TempBackdatedAccounts(AccountID) Values(@CustomerAccountID)
	End
	Else If @OtherAccountID is not null
	Begin
		-- Entry for Other Account
		execute sp_acc_insertGJ @TransactionID,@OtherAccountID,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Represent of Bouncing Cheque",@DocumentNumber
		Insert Into #TempBackdatedAccounts(AccountID) Values(@OtherAccountID)
	End
End
	Fetch Next From ScanCollections Into @DocumentDate, @Value,@CustomerID, @BankID, @OtherAccountID
End
Close ScanCollections
Deallocate ScanCollections

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
/*
Old procedure
Declare @AccountType Int
Set @AccountType =3

Select @DocumentDate=DocumentDate, @Value=Value,@CustomerID=CustomerID, @BankID=Deposit_To, @OtherAccountID=Others from Collections where DocumentID=@DOCUMENTID
Select @BankAccountID=AccountID from Bank where BankID=@BankID
Select @CustomerAccountID=AccountID from Customer where CustomerID=@CustomerID

If @Value<>0
Begin
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	
	-- Entry for Bank Account
	execute sp_acc_insertGJ @TransactionID,@BankAccountID,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Represent of Bouncing Cheque"
	If @CustomerAccountID is not null
	Begin
		-- Entry for Customer Account
		execute sp_acc_insertGJ @TransactionID,@CustomerAccountID,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Represent of Bouncing Cheque"
	End
	Else If @OtherAccountID is not null
	Begin
		-- Entry for Other Account
		execute sp_acc_insertGJ @TransactionID,@OtherAccountID,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Represent of Bouncing Cheque"
	End
End
*/
