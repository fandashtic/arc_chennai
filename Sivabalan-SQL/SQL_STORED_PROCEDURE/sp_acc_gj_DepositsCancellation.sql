CREATE Procedure sp_acc_gj_DepositsCancellation(@DOCUMENTID INT,@BackDate DATETIME=Null)      
AS      
Declare @DocumentDate datetime      
Declare @CollectionID Int    
Declare @Value float      
Declare @BankID int      
Declare @TransactionID int      
Declare @AccountID int      
Declare @DocumentNumber Int      
Declare @AccountID4 int      
Set @AccountID4 = 7  --Cheque on Hand      
      
Declare @AccountType Int      
Set @AccountType =92      
      
Declare @TransactionType Int      
Declare @CHEQUEDEPOSIT Int      
Set @CHEQUEDEPOSIT=5      
      
Create Table #TempBackdatedChequeDeposit(AccountID Int) --for backdated operation          
      
Select @TransactionType=TransactionType,@DocumentDate=DepositDate, @BankID=AccountID from Deposits where DepositID=@DOCUMENTID      
Select @AccountID=AccountID from Bank where BankID=@BankID      
If @TransactionType=@CHEQUEDEPOSIT --Cheque Deposit      
 Begin      
  Declare ScanCollections Cursor Static for      
  Select DocumentID,Value from Collections Where DepositID = @DOCUMENTID      
  Open ScanCollections      
  Fetch from ScanCollections Into @CollectionID,@Value      
  While @@Fetch_Status = 0       
   Begin      
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
    
      -- Entry for Cheque In Hand Account      
      execute sp_acc_insertGJ @TransactionID,@AccountID4,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Deposit of Cheque/DD - Cancellation",@DocumentNumber      
      Insert Into #TempBackdatedChequeDeposit(AccountID) Values(@AccountID4)            
      -- Entry for Bank Account      
      execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,0,@Value,@DocumentID,@AccountType,"Deposit of Cheque/DD - Cancellation",@DocumentNumber      
      Insert Into #TempBackdatedChequeDeposit(AccountID) Values(@AccountID)        
      --Update GeneralJournal Table with Collection ID    
      Update GeneralJournal Set ReferenceNumber = @CollectionID Where TransactionID = @TransactionID    
     End      
     Fetch Next from ScanCollections into @CollectionID,@Value      
   End      
  Close ScanCollections  
  DeAllocate ScanCollections  
 End      
      
If @BackDate Is Not Null          
Begin        
 Declare @TempAccountID Int        
 DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR        
 Select AccountID From #TempBackdatedChequeDeposit        
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
Drop Table #TempBackdatedChequeDeposit  


