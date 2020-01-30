CREATE Procedure sp_acc_gj_chequebounce (@DOCUMENTID INT,@BackDate DATETIME=Null)  
AS  
--Journal entry for cheque bounce, (?parameter DocumentID get from the code because bounce chq is update procedure)  
Declare @RealisationDate datetime  
Declare @ClearingAmount float  
Declare @BankCharges float  
Declare @BankID int  
Declare @CustomerID nvarchar(15)  
Declare @OtherAccountID Int  
Declare @ExpenseAccountID Int  
Declare @TransactionID int  
Declare @CustomerAccountID int  
Declare @BankAccountID int  
Declare @DocumentNumber Int  
Declare @AccountID5 int  
Declare @Gift_Voucher Int  
Declare @DebitID INT  
  
Set @AccountID5 = 9  --Bank Charges  
set @Gift_Voucher = 114 -- Gift Voucher Custoemr  
Declare @AccountType Int  
Set @AccountType = 15  --Collection type  
  
Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation  
  
--Retrive the following fields from collection table  
Select @RealisationDate=RealisationDate, @ClearingAmount=ClearingAmount,   
@BankCharges=BankCharges, @CustomerID=CustomerID, @BankID=Deposit_To,@DebitID=DebitID,  
@OtherAccountID=Others,@ExpenseAccountID = ExpenseAccount from Collections where DocumentID=@DOCUMENTID  
Select @BankAccountID=AccountID from Bank where BankID=@BankID  
  
If @CustomerID = N'GIFT VOUCHER'  
Begin  
 Set @CustomerAccountID = @Gift_Voucher  
End  
Else  
Begin  
 Select @CustomerAccountID=AccountID from Customer where CustomerID=@CustomerID  
End  
  
If IsNULL(@DebitID,0) = 0  
 Exec sp_acc_gj_MultipleNote_ChqBounce @DOCUMENTID,@BackDate  
Else   
 Begin  
  If @ClearingAmount <> 0  
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
   If @CustomerAccountID is not null  
   Begin  
    -- Entry for Customer Account  
    execute sp_acc_insertGJ @TransactionID,@CustomerAccountID,@RealisationDate,@ClearingAmount,0,@DocumentID,@AccountType,"Bouncing of Cheque",@DocumentNumber  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@CustomerAccountID)  
   End  
   Else If isnull(@OtherAccountID,0) <>0  
   Begin  
    -- Entry for Other Account  
    execute sp_acc_insertGJ @TransactionID,@OtherAccountID,@RealisationDate,@ClearingAmount,0,@DocumentID,@AccountType,"Bouncing of Cheque",@DocumentNumber  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@OtherAccountID)  
   End  
   Else If isnull(@OtherAccountID,0) = 0 and isnull(@ExpenseAccountID,0) <>0  
   Begin  
    -- Entry for expense Account(if only expense)  
    execute sp_acc_insertGJ @TransactionID,@ExpenseAccountID,@RealisationDate,@ClearingAmount,0,@DocumentID,@AccountType,"Bouncing of Cheque",@DocumentNumber  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseAccountID)  
   End  
   -- Entry for Bank Account  
   execute sp_acc_insertGJ @TransactionID,@BankAccountID,@RealisationDate,0,@ClearingAmount,@DocumentID,@AccountType,"Bouncing of Cheque",@DocumentNumber  
   Insert Into #TempBackdatedAccounts(AccountID) Values(@BankAccountID)  
  End  
    
  If @BankCharges<>0  
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
     
   -- Entry for Bank Charges Account  
   execute sp_acc_insertGJ @TransactionID,@AccountID5,@RealisationDate,@BankCharges,0,@DocumentID,@AccountType,"Bouncing of Cheque",@DocumentNumber  
   -- Entry for Bank Account  
   execute sp_acc_insertGJ @TransactionID,@BankAccountID,@RealisationDate,0,@BankCharges,@DocumentID,@AccountType,"Bouncing of Cheque",@DocumentNumber  
   Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)  
   Insert Into #TempBackdatedAccounts(AccountID) Values(@BankAccountID)  
    
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
    
   If @CustomerAccountID is not null  
   Begin  
    -- Entry for customer account  
    execute sp_acc_insertGJ @TransactionID,@CustomerAccountID,@RealisationDate,@BankCharges,0,@DocumentID,@AccountType,"Bouncing of Cheque",@DocumentNumber  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@CustomerAccountID)  
   End  
   Else If isnull(@OtherAccountID,0) <> 0  
   Begin  
    -- Entry for other account  
    execute sp_acc_insertGJ @TransactionID,@OtherAccountID,@RealisationDate,@BankCharges,0,@DocumentID,@AccountType,"Bouncing of Cheque",@DocumentNumber  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@OtherAccountID)  
   End  
   Else If isnull(@OtherAccountID,0) = 0 and isnull(@ExpenseAccountID,0) <>0  
   Begin  
    -- Entry for expense account(if only expense)  
    execute sp_acc_insertGJ @TransactionID,@ExpenseAccountID,@RealisationDate,@BankCharges,0,@DocumentID,@AccountType,"Bouncing of Cheque",@DocumentNumber  
    Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseAccountID)  
   End  
   -- Entry for Bank Charges Account  
   execute sp_acc_insertGJ @TransactionID,@AccountID5,@RealisationDate,0,@BankCharges,@DocumentID,@AccountType,"Bouncing of Cheque",@DocumentNumber  
   Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)  
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
 End  
Drop Table #TempBackdatedAccounts
