CREATE Procedure sp_acc_gj_RealisationCancel(@CollectionID INT,@BackDate DateTime=Null)    
AS      
Declare @RealisationDate DateTime      
Declare @ClearingAmount float      
Declare @BankCharges float      
Declare @BankID int      
Declare @CustomerID nVarChar(15)      
Declare @OtherAccountID Int      
Declare @ExpenseAccountID Int      
Declare @TransactionID int      
Declare @CustomerAccountID int      
Declare @BankAccountID int      
Declare @DocumentNumber Int      
Declare @AccountID5 int      
Declare @AccountType Int      
Declare @RealisationType Int    
Declare @BankChargesDebitID Int    
Declare @REALISATION_CANCEL Int    
Declare @BOUNCED_CANCEL Int    
Declare @Gift_Voucher Int  
Declare @DebitID INT  
  
Set @Gift_Voucher = 114 /* Gift Voucher Customer */    
Set @REALISATION_CANCEL = 4    
Set @BOUNCED_CANCEL = 5    
Set @AccountID5 = 9  /*Bank Charges*/    
Set @AccountType = 93  /*Realisation Type*/      
      
Create Table #TempBackdatedAccounts(AccountID Int)    
      
Select @RealisationDate=RealisationDate, @ClearingAmount=ClearingAmount, @RealisationType=IsNULL(Realised,0),@DebitID=DebitID,  
@BankChargesDebitID=IsNULL(BankChargesDebitID,0), @BankCharges=BankCharges, @CustomerID=CustomerID, @BankID=Deposit_To,       
@OtherAccountID=Others, @ExpenseAccountID=ExpenseAccount from Collections where DocumentID=@CollectionID      
Select @BankAccountID=AccountID from Bank where BankID=@BankID      
If @CustomerID=N'GIFT VOUCHER'  
Begin  
 Set @CustomerAccountID=@Gift_Voucher  
End  
Else  
Begin  
 Select @CustomerAccountID=AccountID from Customer where CustomerID=@CustomerID      
End  
  
If IsNULL(@DebitID,0) = 0  
 Exec sp_acc_gj_MultipleNote_ChqBounce_Cancel @CollectionID,@Backdate  
Else  
 Begin  
  If @RealisationType = @REALISATION_CANCEL   
   Begin  
    If @BankChargesDebitID <> 0    
     Begin    
      Exec sp_acc_gj_debitnotecancel @BankChargesDebitID, @BackDate    
     End    
   End  
  Else If @RealisationType = @BOUNCED_CANCEL  
   Begin    
    If @ClearingAmount <>0      
     Begin      
      Begin Tran      
       Update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24      
       Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
      Commit Tran      
      Begin Tran      
       Update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51      
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
      Commit Tran      
           
      Execute sp_acc_insertGJ @TransactionID,@BankAccountID,@RealisationDate,@ClearingAmount,0,@CollectionID,@AccountType,"Bouncing of Cheque - Cancel",@DocumentNumber      
      Insert Into #TempBackdatedAccounts(AccountID) Values(@BankAccountID)      
           
      If @CustomerAccountID is not null      
       Begin      
        Execute sp_acc_insertGJ @TransactionID,@CustomerAccountID,@RealisationDate,0,@ClearingAmount,@CollectionID,@AccountType,"Bouncing of Cheque - Cancel",@DocumentNumber      
        Insert Into #TempBackdatedAccounts(AccountID) Values(@CustomerAccountID)      
       End      
      Else If isnull(@OtherAccountID,0) <>0      
       Begin      
        Execute sp_acc_insertGJ @TransactionID,@OtherAccountID,@RealisationDate,0,@ClearingAmount,@CollectionID,@AccountType,"Bouncing of Cheque - Cancel",@DocumentNumber      
        Insert Into #TempBackdatedAccounts(AccountID) Values(@OtherAccountID)      
       End      
      Else If isnull(@OtherAccountID,0) = 0 and isnull(@ExpenseAccountID,0) <>0      
       Begin      
        Execute sp_acc_insertGJ @TransactionID,@ExpenseAccountID,@RealisationDate,0,@ClearingAmount,@CollectionID,@AccountType,"Bouncing of Cheque - Cancel",@DocumentNumber      
        Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseAccountID)      
       End      
     End      
    /*Entry for Bank Charges*/ 
  If @BankCharges<>0      
     Begin       
      Begin Tran      
       Update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24      
       Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
      Commit Tran      
      Begin Tran      
       Update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51      
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
      Commit Tran      
           
      Execute sp_acc_insertGJ @TransactionID,@BankAccountID,@RealisationDate,@BankCharges,0,@CollectionID,@AccountType,"Bouncing of Cheque - Cancel",@DocumentNumber      
      Execute sp_acc_insertGJ @TransactionID,@AccountID5,@RealisationDate,0,@BankCharges,@CollectionID,@AccountType,"Bouncing of Cheque - Cancel",@DocumentNumber      
           
      Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)      
      Insert Into #TempBackdatedAccounts(AccountID) Values(@BankAccountID)      
          
      Begin Tran      
       Update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24      
       Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24      
      Commit Tran      
      Begin Tran      
       Update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51      
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
      Commit Tran      
           
      Execute sp_acc_insertGJ @TransactionID,@AccountID5,@RealisationDate,@BankCharges,0,@CollectionID,@AccountType,"Bouncing of Cheque - Cancel",@DocumentNumber      
      Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)      
            
      If @CustomerAccountID is not null      
       Begin      
        Execute sp_acc_insertGJ @TransactionID,@CustomerAccountID,@RealisationDate,0,@BankCharges,@CollectionID,@AccountType,"Bouncing of Cheque - Cancel",@DocumentNumber      
        Insert Into #TempBackdatedAccounts(AccountID) Values(@CustomerAccountID)      
       End      
      Else If isnull(@OtherAccountID,0) <> 0      
       Begin      
        Execute sp_acc_insertGJ @TransactionID,@OtherAccountID,@RealisationDate,0,@BankCharges,@CollectionID,@AccountType,"Bouncing of Cheque - Cancel",@DocumentNumber      
        Insert Into #TempBackdatedAccounts(AccountID) Values(@OtherAccountID)      
       End      
      Else If isnull(@OtherAccountID,0) = 0 and isnull(@ExpenseAccountID,0) <>0      
       Begin      
        Execute sp_acc_insertGJ @TransactionID,@ExpenseAccountID,@RealisationDate,0,@BankCharges,@CollectionID,@AccountType,"Bouncing of Cheque - Cancel",@DocumentNumber      
        Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseAccountID)      
       End      
     End      
   End     
  /* Backdated Operation */      
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
