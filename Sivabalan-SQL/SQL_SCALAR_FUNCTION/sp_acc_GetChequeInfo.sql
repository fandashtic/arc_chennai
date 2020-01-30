CREATE function sp_acc_GetChequeInfo(@DocRef INT,@DocType INT,@CollectionID INT)        
Returns nVarChar(4000)
As        
Begin      
DECLARE @RETAILINVOICE INT        
DECLARE @RETAILINVOICEAMENDMENT INT        
DECLARE @RETAILINVOICECANCELLATION INT        
DECLARE @INVOICE INT        
DECLARE @INVOICEAMENDMENT INT        
DECLARE @INVOICECANCELLATION INT        
DECLARE @SALESRETURN INT        
DECLARE @BILL INT        
DECLARE @BILLAMENDMENT INT        
DECLARE @BILLCANCELLATION INT        
DECLARE @PURCHASERETURN INT        
DECLARE @PURCHASERETURNCANCELLATION INT        
DECLARE @COLLECTIONS INT        
DECLARE @DEPOSITS INT        
DECLARE @BOUNCECHEQUE INT        
DECLARE @REPOFBOUNCECHEQUE INT        
DECLARE @PAYMENTS INT        
DECLARE @PAYMENTCANCELLATION INT        
DECLARE @AUTOENTRY INT        
DECLARE @DEBITNOTE INT        
DECLARE @CREDITNOTE INT        
DECLARE @CLAIMSTOVENDOR INT        
DECLARE @CLAIMSSETTLEMENT INT        
DECLARE @CLAIMSCANCELLATION INT        
DECLARE @COLLECTIONCANCELLATION INT        
DECLARE @MANUALJOURNAL INT        
DECLARE @ARV_AMENDMENT INT        
DECLARE @APV_AMENDMENT INT      
DECLARE @MANUALJOURNALINVOICE INT        
DECLARE @MANUALJOURNALSALESRETURN INT        
DECLARE @MANUALJOURNALBILL INT        
DECLARE @MANUALJOURNALPURCHASERETURN INT        
DECLARE @MANUALJOURNALCOLLECTIONS INT        
DECLARE @MANUALJOURNALPAYMENTS INT        
DECLARE @MANUALJOURNALDEBITNOTE INT        
DECLARE @MANUALJOURNALCREDITNOTE INT        
DECLARE @MANUALJOURNALOLDREF INT        
DECLARE @CONTRAENTRYCANCELLATION INT        
DECLARE @MANUALJOURNALAPV INT        
DECLARE @MANUALJOURNALARV INT        
DECLARE @MANUALJOURNALOTHERPAYMENTS INT        
DECLARE @MANUALJOURNALOTHERRECEIPTS INT        
DECLARE @MANUALJOURNALOTHERDEBITNOTE INT        
DECLARE @MANUALJOURNALOTHERCREDITNOTE INT        
DECLARE @SALESRETURNCANCELLATION INT        
DECLARE @DISPATCH INT        
DECLARE @DISPATCHCANCELLATION INT        
DECLARE @APV INT        
DECLARE @APVCANCELLATION INT        
DECLARE @ARV INT        
DECLARE @ARVCANCELLATION INT        
DECLARE @STOCKTRANSFERIN INT        
DECLARE @STOCKTRANSFEROUT INT        
DECLARE @PETTYCASH INT        
DECLARE @PETTYCASHCANCELLATION INT        
DECLARE @GRN INT        
DECLARE @GRNCANCELLATION INT        
DECLARE @DEBITNOTECANCELLATION INT        
DECLARE @CREDITNOTECANCELLATION INT        
DECLARE @STOCKTRANSFERINCANCELLATION INT        
DECLARE @STOCKTRANSFEROUTCANCELLATION INT        
DECLARE @STOCKTRANSFERINAMENDMENT INT        
DECLARE @STOCKTRANSFEROUTAMENDMENT INT        
DECLARE @DISPATCHAMENDMENT INT        
DECLARE @SALESRETURNAMENDMENT INT        
DECLARE @GRNAMENDMENT INT        
DECLARE @PURCHASERETURNAMENDMENT INT        
DECLARE @INTERNALCONTRA INT        
DECLARE @INTERNALCONTRACANCELLATION INT        
DECLARE @COLLECTIONAMENDMENT INT        
DECLARE @PAYMENT_AMENDMENT INT        
DECLARE @DocumentDesc nVarChar(50)        
DECLARE @MANUALJOURNAL_NEWREFERENCE INT        
DECLARE @MANUALJOURNALCLAIMS INT        
DECLARE @DocumentNumber INT        
        
SET @RETAILINVOICE = 1        
SET @RETAILINVOICEAMENDMENT = 2        
SET @RETAILINVOICECANCELLATION =3        
SET @INVOICE =4        
SET @INVOICEAMENDMENT = 5        
SET @INVOICECANCELLATION = 6        
SET @SALESRETURN = 7        
SET @BILL = 8        
SET @BILLAMENDMENT = 9        
SET @BILLCANCELLATION = 10        
SET @PURCHASERETURN = 11        
SET @PURCHASERETURNCANCELLATION = 12        
SET @COLLECTIONS = 13        
SET @DEPOSITS =14        
SET @BOUNCECHEQUE = 15        
SET @REPOFBOUNCECHEQUE = 16        
SET @PAYMENTS = 17        
SET @PAYMENTCANCELLATION = 18        
SET @AUTOENTRY = 19        
SET @DEBITNOTE = 20        
SET @CREDITNOTE = 21        
SET @CLAIMSTOVENDOR = 22        
SET @CLAIMSSETTLEMENT = 23        
SET @CLAIMSCANCELLATION = 24        
SET @COLLECTIONCANCELLATION = 25        
SET @MANUALJOURNAL = 26        
SET @MANUALJOURNALINVOICE =28        
SET @MANUALJOURNALSALESRETURN =29        
SET @MANUALJOURNALBILL =30        
SET @MANUALJOURNALPURCHASERETURN =31        
SET @MANUALJOURNALCOLLECTIONS =32        
SET @MANUALJOURNALPAYMENTS =33        
SET @MANUALJOURNALDEBITNOTE =34        
SET @MANUALJOURNALCREDITNOTE =35        
SET @MANUALJOURNALOLDREF =37        
SET @CONTRAENTRYCANCELLATION =38        
SET @SALESRETURNCANCELLATION =40        
SET @GRN = 41        
SET @GRNCANCELLATION =42        
SET @DISPATCH = 44        
SET @DISPATCHCANCELLATION = 45        
SET @APV = 46        
SET @APVCANCELLATION =47        
SET @ARV = 48        
SET @ARVCANCELLATION = 49        
SET @PETTYCASH =52        
SET @PETTYCASHCANCELLATION =53        
SET @STOCKTRANSFERIN = 54        
SET @STOCKTRANSFEROUT = 55        
SET @MANUALJOURNALAPV = 60        
SET @MANUALJOURNALARV = 61        
SET @MANUALJOURNALOTHERPAYMENTS = 62        
SET @MANUALJOURNALOTHERRECEIPTS = 63        
SET @DEBITNOTECANCELLATION = 64        
SET @CREDITNOTECANCELLATION = 65        
SET @GRNAMENDMENT = 66        
SET @STOCKTRANSFERINCANCELLATION =67        
SET @STOCKTRANSFEROUTCANCELLATION =68        
SET @STOCKTRANSFERINAMENDMENT =69        
SET @STOCKTRANSFEROUTAMENDMENT =70        
SET @DISPATCHAMENDMENT=71        
SET @SALESRETURNAMENDMENT=72        
SET @PURCHASERETURNAMENDMENT = 73        
SET @INTERNALCONTRA = 74        
SET @INTERNALCONTRACANCELLATION = 75        
SET @COLLECTIONAMENDMENT=77        
SET @PAYMENT_AMENDMENT = 78        
SET @MANUALJOURNALOTHERDEBITNOTE = 79        
SET @MANUALJOURNALOTHERCREDITNOTE = 80        
SET @MANUALJOURNAL_NEWREFERENCE = 81        
SET @MANUALJOURNALCLAIMS = 82        
SET @ARV_AMENDMENT = 83        
SET @APV_AMENDMENT = 84      
      
DECLARE @TransactionType INT      
DECLARE @CustomerID nVarchar(15)      
DECLARE @VendorID nVarchar(15)      
DECLARE @OthersID INT      
DECLARE @ExpenseID INT      
DECLARE @ChequeNumber INT      
DECLARE @ChequeBook nVarchar(50)    
DECLARE @AccountName nVarchar(255)      
DECLARE @ReturnValue nVarChar(4000)
DECLARE @WithDrawlMode INT    
DECLARE @DepositID INT  
DECLARE @BankID INT  
DECLARE @BankCode nVarchar(50)
DECLARE @BankName nVarchar(50)
DECLARE @BranchCode nVarchar(50)
DECLARE @BranchName nVarchar(50)
DECLARE @ChequeDate DateTime
      
DECLARE @CASH_WITHDRAWL INT    
DECLARE @CHEQUE_DEPOSIT INT      
DECLARE @ACCOUNT_TRANSFER INT    
    
SET @CASH_WITHDRAWL = 2    
SET @CHEQUE_DEPOSIT = 5      
SET @ACCOUNT_TRANSFER = 6    
    
SET @CollectionID = IsNull(@CollectionID,0)      
      
If @DocType = @DEPOSITS       
 Begin      
  Select @TransactionType = TransactionType from Deposits Where DepositID = @DocRef      
  If @TransactionType = @CHEQUE_DEPOSIT      
   Begin      
    Select @CustomerID = CustomerID, @OthersID = Others, @ExpenseID = ExpenseAccount, @ChequeNumber = ChequeNumber, @ChequeDate = ChequeDate, @BankCode = BankCode, @BranchCode = BranchCode from Collections Where DocumentID = @CollectionID      
    If @CustomerID Is Not NULL      
     Begin      
      Select @AccountName = AccountName from AccountsMaster Where AccountID = (Select AccountID from Customer Where CustomerID = @CustomerID)      
     End      
    Else      
     Begin      
      If @OthersID Is Not NULL      
       Begin      
        Select @AccountName = AccountName from AccountsMaster Where AccountID = @OthersID      
       End      
      Else      
       Begin      
        Select @AccountName = AccountName from AccountsMaster Where AccountID = @ExpenseID      
       End      
     End      
    Select @BankName = BankName from BankMaster Where BankCode = @BankCode
    Select @BranchName = BranchName from BranchMaster Where BankCode = @BankCode And BranchCode = @BranchCode
    Set @ReturnValue = @AccountName + N' - ' + CAST(IsNull(@ChequeNumber,'') AS nVarchar) + N' - ' + CAST(IsNull(@ChequeDate,'') AS nVarchar) + N' - ' + CAST(IsNull(@BankName,'') AS nVarchar) + N' - ' + CAST(IsNull(@BranchName,'') AS nVarchar)
   End      
  Else If @TransactionType = @CASH_WITHDRAWL    
   Begin    
    Select @WithDrawlMode = IsNull(WithDrawlType,0) from Deposits Where DepositID = @DocRef    
    If @WithDrawlMode = 1    
     Begin    
      Select @ChequeBook = IsNull(Cheque_Book_Name,N'') + N':' + CAST(IsNull(ChequeNo,'') as nVarchar), @ChequeDate = ChequeDate from Deposits,Cheques
      Where Deposits.ChequeID = Cheques.ChequeID And Deposits.DepositID = @DocRef    
     End    
    Else if @WithDrawlMode = 2    
     Begin    
      Select @ChequeBook = dbo.LookupDictionaryItem('WithDrawl Slip : ',Default) + CAST(IsNull(ChequeNo,'') As nVarchar), @ChequeDate = ChequeDate from Deposits Where DepositID = @DocRef    
     End    
    Select @BankCode = BankCode, @BranchCode = BranchCode from Bank Where AccountID = (Select AccountID from Deposits Where DepositID = @DocRef)
    Select @BankName = BankName from BankMaster Where BankCode = @BankCode
    Select @BranchName = BranchName from BranchMaster Where BankCode = @BankCode And BranchCode = @BranchCode
    Set @ReturnValue = @ChequeBook + N' - ' + CAST(IsNull(@ChequeDate,'')As nVarChar) + N' - ' + CAST(IsNull(@BankName,'') AS nVarchar) + N' - ' + CAST(IsNull(@BranchName,'') AS nVarchar) 
   End    
  Else If @TransactionType = @ACCOUNT_TRANSFER    
   Begin    
    Select @AccountName = AccountName from AccountsMaster Where AccountID = (Select AccountID from Deposits Where DepositID = @DocRef)    
    Select @WithDrawlMode = IsNull(WithDrawlType,0) from Deposits Where DepositID = @DocRef    
    If @WithDrawlMode = 1    
     Begin    
      Select @ChequeBook = IsNull(Cheque_Book_Name,N'') + N' - ' + CAST(IsNull(ChequeNo,'') as nVarchar), @ChequeDate = ChequeDate from Deposits,Cheques    
      Where Deposits.ChequeID = Cheques.ChequeID And Deposits.DepositID = @DocRef    
     End    
    Else if @WithDrawlMode = 2    
     Begin    
      Select @ChequeBook = dbo.LookupDictionaryItem('WithDrawl Slip : ',Default) + CAST(IsNull(ChequeNo,'') As nVarchar), @ChequeDate = ChequeDate from Deposits Where DepositID = @DocRef    
     End    
    If IsNull(@ChequeBook,N'') = N''    
     Begin    
      Set @ReturnValue = @AccountName    
     End    
    Else    
     Begin    
      Select @BankCode = BankCode, @BranchCode = BranchCode from Bank Where AccountID = (Select AccountID from Deposits Where DepositID = @DocRef)
      Select @BankName = BankName from BankMaster Where BankCode = @BankCode
      Select @BranchName = BranchName from BranchMaster Where BankCode = @BankCode And BranchCode = @BranchCode
      Set @ReturnValue = @AccountName + dbo.LookupDictionaryItem(' - Cheque No : ',Default) + CAST(IsNull(@ChequeBook,'') As nVarchar) + N' - ' + CAST(IsNull(@ChequeDate,'')As nVarChar) + N' - ' + CAST(IsNull(@BankName,'') AS nVarchar) + N' - ' + CAST(IsNull(@BranchName,'') AS nVarchar)
     End    
   End    
  Else      
   Begin      
    Set @ReturnValue = ''      
   End      
 End      
Else If @DocType = @BOUNCECHEQUE    
 Begin    
  Select @CustomerID = CustomerID, @OthersID = Others, @ExpenseID = ExpenseAccount, @ChequeNumber = ChequeNumber, @ChequeDate = ChequeDate, @BankCode = BankCode, @BranchCode = BranchCode from Collections Where DocumentID = @DocRef      
  If @CustomerID Is Not NULL      
   Begin      
    Select @AccountName = AccountName from AccountsMaster Where AccountID = (Select AccountID from Customer Where CustomerID = @CustomerID)      
   End      
  Else      
   Begin      
    If @OthersID Is Not NULL      
     Begin      
      Select @AccountName = AccountName from AccountsMaster Where AccountID = @OthersID      
     End      
    Else      
     Begin      
      Select @AccountName = AccountName from AccountsMaster Where AccountID = @ExpenseID      
     End      
   End      
  Select @BankName = BankName from BankMaster Where BankCode = @BankCode
  Select @BranchName = BranchName from BranchMaster Where BankCode = @BankCode And BranchCode = @BranchCode
  Set @ReturnValue = @AccountName + N' - ' + CAST(IsNull(@ChequeNumber,'') AS nVarchar) + N' - ' + CAST(IsNull(@ChequeDate,'') AS nVarchar) + N' - ' + CAST(IsNull(@BankName,'') AS nVarchar) + N' - ' + CAST(IsNull(@BranchName,'') AS nVarchar) 
 End    
Else If @DocType = @PAYMENTS Or @DocType = @PAYMENT_AMENDMENT Or @DocType = @PAYMENTCANCELLATION      
 Begin      
  Select @VendorID = VendorID, @OthersID = Others, @ExpenseID = ExpenseAccount, @ChequeNumber = Cheque_Number, @ChequeBook = IsNull(Cheque_Book_Name,N'') + ':' + CAST(IsNull(Cheque_Number,'')AS nVarChar), @ChequeDate = Cheque_Date, @BankCode = Payments.BankCode, @BranchCode = BranchCode from Payments,Cheques Where DocumentID = @DocRef And Payments.Cheque_ID = Cheques.ChequeID
  If @ChequeNumber is Not NULL And @ChequeNumber <> 0  
   Begin  
    If @VendorID Is Not NULL      
     Begin      
      Select @AccountName = AccountName from AccountsMaster Where AccountID = (Select AccountID from Vendors Where VendorID = @VendorID)      
     End      
    Else      
     Begin      
      If @OthersID Is Not NULL      
       Begin      
        Select @AccountName = AccountName from AccountsMaster Where AccountID = @OthersID      
       End      
      Else      
       Begin      
        Select @AccountName = AccountName from AccountsMaster Where AccountID = @ExpenseID      
       End      
     End      
    Select @BankName = BankName from BankMaster Where BankCode = @BankCode
    Select @BranchName = BranchName from BranchMaster Where BankCode = @BankCode And BranchCode = @BranchCode
    Set @ReturnValue = @AccountName + N' - ' + CAST(IsNull(@ChequeBook,'') AS nVarchar) + N' - ' + CAST(IsNull(@ChequeDate,'') AS nVarchar) + N' - ' + CAST(IsNull(@BankName,'') AS nVarchar) + N' - ' + CAST(IsNull(@BranchName,'') AS nVarchar) 
   End      
 End  
Else If @DocType = @COLLECTIONS Or @DocType = @COLLECTIONAMENDMENT Or @DocType = @COLLECTIONCANCELLATION      
 Begin      
  Select @DepositID = DepositID, @ChequeNumber = ChequeNumber, @ChequeDate = ChequeDate, @BankCode = BankCode, @BranchCode = BranchCode from Collections Where DocumentID = @DocRef      
  If @DepositID Is Not NULL  
   Begin  
    Select @AccountName = Account_Number from Bank,Deposits Where Bank.BankID = Deposits.AccountID And Deposits.DepositID = @DepositID  
    Select @BankName = BankName from BankMaster Where BankCode = @BankCode
    Select @BranchName = BranchName from BranchMaster Where BankCode = @BankCode And BranchCode = @BranchCode
    Set @ReturnValue = @AccountName + N' - ' + CAST(IsNull(@ChequeNumber,'') AS nVarchar) + N' - ' + CAST(IsNull(@ChequeDate,'') AS nVarchar) + N' - ' + CAST(IsNull(@BankName,'') AS nVarchar) + N' - ' + CAST(IsNull(@BranchName,'') AS nVarchar) 
   End  
 End      
Return ISNull(@ReturnValue,'')      
End
