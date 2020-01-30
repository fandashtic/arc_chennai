CREATE Procedure sp_acc_gj_MultipleNote_ChqBounce_Cancel(@CollectionID INT,@BackDate DateTime=NULL)      
As      
Declare @GIFT_VOUCHER Int      
Declare @REALISATION_CANCEL Int        
Declare @BOUNCED_CANCEL Int        
Declare @DISCOUNT_ACCOUNT INT      
Declare @OTHERCHARGES_ACCOUNT INT      
Declare @BANKCHARGES_ACCOUNT INT      
Declare @CustomerID nVarChar(50)      
Declare @BankID INT      
Declare @CustomerAcID INT      
Declare @OthersAcID INT      
Declare @ExpenseAcID INT      
Declare @BankAcID INT      
Declare @TransactionID INT      
Declare @DocumentNumber INT      
Declare @BounceType INT      
Declare @ERPCollection INT      
Declare @PrefixType INT      
Declare @DocumentID INT      
Declare @DocumentType INT      
Declare @DocumentDate DateTime      
Declare @RealisationDate DateTime      
Declare @AdjustedAmount Decimal(18,6)      
Declare @ExtraCollection Decimal(18,6)      
Declare @Adjustment Decimal(18,6)      
Declare @TotExtraCollection Decimal(18,6)      
Declare @TotAdjustment Decimal(18,6)      
Declare @BankCharges Decimal(18,6)      
Declare @CollBalance Decimal(18,6)  
Declare @TempAccountID INT      
Declare @TempBackDate DateTime      
Declare @RealisationType Int        
Declare @BankChargesDebitID Int      
      
Set @GIFT_VOUCHER = 114       
Set @DISCOUNT_ACCOUNT = 13      
Set @OTHERCHARGES_ACCOUNT = 14      
Set @BANKCHARGES_ACCOUNT = 9      
Set @REALISATION_CANCEL = 4        
Set @BOUNCED_CANCEL = 5        
Set @BounceType = 93      
      
If Exists(Select * from Collections Where DocumentID=@CollectionID And CustomerID Is NOT NULL)      
 Set @ERPCollection = 1      
Else      
 Set @ERPCollection = 0      
      
CREATE Table #TempBakDatedAccounts(AccountID INT, BackDate DateTime)      
      
Select @OthersAcID=IsNULL(Others,0),@ExpenseAcID=IsNULL(ExpenseAccount,0),@CustomerID=CustomerID,      
@RealisationType=IsNULL(Realised,0),@BankChargesDebitID=IsNULL(BankChargesDebitID,0),      
@BankCharges=IsNULL(BankCharges,0),@BankID=Deposit_To from Collections Where DocumentID=@CollectionID      
Select @BankAcID=AccountID from Bank Where BankID=@BankID      
If @CustomerID = N'GIFT VOUCHER'        
 Set @CustomerAcID=@GIFT_VOUCHER        
Else        
 Select @CustomerAcID=AccountID from Customer Where CustomerID=@CustomerID       
      
If @RealisationType = @REALISATION_CANCEL       
 Begin      
  If @BankChargesDebitID <> 0        
   Begin        
    Exec sp_acc_gj_debitnotecancel @BankChargesDebitID,@BackDate        
   End        
 End      
Else If @RealisationType = @BOUNCED_CANCEL      
 Begin       
  If (Select Count(*) from CollectionDetail Where CollectionID=@CollectionID) > 0      
   Begin      
    DECLARE ScanCollections CURSOR KEYSET FOR      
     Select DocumentID,DocumentType,DocumentDate,AdjustedAmount,Adjustment,      
     ExtraCollection from CollectionDetail Where CollectionID=@CollectionID      
    OPEN ScanCollections      
    FETCH FROM ScanCollections INTO @DocumentID,@DocumentType,@DocumentDate,@AdjustedAmount,@Adjustment,@ExtraCollection      
    While @@FETCH_STATUS = 0      
     Begin      
      If @DocumentType = 8      
       Begin       
        Select @PrefixType=PrefixType from ManualJournal Where NewRefID=@DocumentID      
       End      
      If @DocumentType=1 Or @DocumentType=2 Or @DocumentType=3 Or (@DocumentType=7 And @ERPCollection=1) Or (@DocumentType=6 And @ERPCollection=0) Or (@DocumentType=8 And @PrefixType=2)      
       Begin      
        Set @TotExtraCollection = IsNULL(@TotExtraCollection,0) - IsNULL(@ExtraCollection,0)      
        Set @TotAdjustment = IsNULL(@TotAdjustment,0) - IsNULL(@Adjustment,0)      
        If @AdjustedAmount <> 0      
         Begin       
          Begin Tran        
           Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24      
           Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24      
          Commit Tran        
          Begin Tran        
           Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51
           Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
          Commit Tran        
      
          If @CustomerAcID Is NOT NULL      
           Begin        
            Execute sp_acc_InsertGJ @TransactionID,@CustomerAcID,@DocumentDate,@AdjustedAmount,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
            Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@CustomerAcID,@DocumentDate)      
           End        
          Else If IsNULL(@OthersAcID,0) <> 0      
           Begin        
            Execute sp_acc_InsertGJ @TransactionID,@OthersAcID,@DocumentDate,@AdjustedAmount,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
            Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@OthersAcID,@DocumentDate)      
           End        
          Else If IsNULL(@OthersAcID,0) = 0 and IsNULL(@ExpenseAcID,0) <> 0        
           Begin        
            Execute sp_acc_InsertGJ @TransactionID,@ExpenseAcID,@DocumentDate,@AdjustedAmount,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
            Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@ExpenseAcID,@DocumentDate)      
           End        
          Execute sp_acc_InsertGJ @TransactionID,@BankAcID,@DocumentDate,0,@AdjustedAmount,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
          Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BankAcID,@DocumentDate)      
         End      
       End      
      Else If @DocumentType=4 Or @DocumentType=5 Or (@DocumentType=7 And @ERPCollection=0) Or (@DocumentType=6 And @ERPCollection=1) Or (@DocumentType=8 And @PrefixType=1)      
       Begin      
        Set @TotExtraCollection = IsNULL(@TotExtraCollection,0) + IsNULL(@ExtraCollection,0)      
        Set @TotAdjustment = IsNULL(@TotAdjustment,0) + IsNULL(@Adjustment,0)      
        If @AdjustedAmount <> 0      
         Begin       
          Begin Tran        
           Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24      
           Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24      
          Commit Tran        
          Begin Tran        
           Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51      
           Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
          Commit Tran        
      
          Execute sp_acc_InsertGJ @TransactionID,@BankAcID,@DocumentDate,@AdjustedAmount,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
          Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BankAcID,@DocumentDate)      
          If @CustomerAcID Is NOT NULL      
           Begin        
            Execute sp_acc_InsertGJ @TransactionID,@CustomerAcID,@DocumentDate,0,@AdjustedAmount,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
            Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@CustomerAcID,@DocumentDate)      
           End        
          Else If IsNULL(@OthersAcID,0) <> 0      
           Begin        
            Execute sp_acc_InsertGJ @TransactionID,@OthersAcID,@DocumentDate,0,@AdjustedAmount,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
            Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@OthersAcID,@DocumentDate)      
           End        
          Else If IsNULL(@OthersAcID,0) = 0 and IsNULL(@ExpenseAcID,0) <> 0        
           Begin        
            Execute sp_acc_InsertGJ @TransactionID,@ExpenseAcID,@DocumentDate,0,@AdjustedAmount,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
            Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@ExpenseAcID,@DocumentDate)      
           End      
         End      
       End      
      FETCH Next FROM ScanCollections INTO @DocumentID,@DocumentType,@DocumentDate,@AdjustedAmount,@Adjustment,@ExtraCollection      
     End      
    CLOSE ScanCollections      
    DEALLOCATE ScanCollections      
    -------------------------------Entry for Extra Collections-------------------------------
    Select @CollBalance=Balance,@DocumentDate=DocumentDate,@RealisationDate=RealisationDate from Collections Where DocumentID=@CollectionID      
    Set @TotExtraCollection = IsNULL(@TotExtraCollection,0)      
    Set @TotAdjustment = IsNULL(@TotAdjustment,0)      

    If @CollBalance > 0      
     Begin       
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24      
       Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24      
      Commit Tran        
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51      
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
      Commit Tran        
  
      Execute sp_acc_InsertGJ @TransactionID,@BankAcID,@DocumentDate,@CollBalance,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
      Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BankAcID,@DocumentDate)      
      If @CustomerAcID Is NOT NULL      
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@CustomerAcID,@DocumentDate,0,@CollBalance,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@CustomerAcID,@DocumentDate)      
       End        
      Else If IsNULL(@OthersAcID,0) <> 0      
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@OthersAcID,@DocumentDate,0,@CollBalance,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@OthersAcID,@DocumentDate)      
       End        
      Else If IsNULL(@OthersAcID,0) = 0 and IsNULL(@ExpenseAcID,0) <> 0        
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@ExpenseAcID,@DocumentDate,0,@CollBalance,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@ExpenseAcID,@DocumentDate)      
       End      
     End      
    -------------------------------Entry for Extra Collections--------------------------------
    If @TotExtraCollection > 0      
     Begin      
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24      
       Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24      
      Commit Tran        
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51      
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
      Commit Tran        
      
      Execute sp_acc_InsertGJ @TransactionID,@BankAcID,@DocumentDate,@TotExtraCollection,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber            
      Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BankAcID,@DocumentDate)      
      If @CustomerAcID Is NOT NULL      
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@CustomerAcID,@DocumentDate,0,@TotExtraCollection,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@CustomerAcID,@DocumentDate)      
       End        
      Else If IsNULL(@OthersAcID,0) <> 0      
  Begin        
        Execute sp_acc_InsertGJ @TransactionID,@OthersAcID,@DocumentDate,0,@TotExtraCollection,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@OthersAcID,@DocumentDate)      
       End        
      Else If IsNULL(@OthersAcID,0) = 0 and IsNULL(@ExpenseAcID,0) <> 0        
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@ExpenseAcID,@DocumentDate,0,@TotExtraCollection,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@ExpenseAcID,@DocumentDate)      
       End      
     End      
    Else If @TotExtraCollection < 0      
     Begin      
      Set @TotExtraCollection = ABS(@TotExtraCollection)      
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24      
       Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24      
      Commit Tran        
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51      
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
      Commit Tran        
      
      If @CustomerAcID Is NOT NULL      
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@CustomerAcID,@DocumentDate,@TotExtraCollection,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@CustomerAcID,@DocumentDate)      
       End        
      Else If IsNULL(@OthersAcID,0) <> 0      
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@OthersAcID,@DocumentDate,@TotExtraCollection,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@OthersAcID,@DocumentDate)      
       End        
      Else If IsNULL(@OthersAcID,0) = 0 and IsNULL(@ExpenseAcID,0) <> 0        
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@ExpenseAcID,@DocumentDate,@TotExtraCollection,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@ExpenseAcID,@DocumentDate)      
       End      
      Execute sp_acc_InsertGJ @TransactionID,@BankAcID,@DocumentDate,0,@TotExtraCollection,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
      Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BankAcID,@DocumentDate)      
     End      
    -----------------------------------Entry for Bank Charges----------------------------------      
    If @BankCharges <> 0      
     Begin      
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24      
       Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24      
      Commit Tran        
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51      
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
      Commit Tran        
             
      Execute sp_acc_InsertGJ @TransactionID,@BankAcID,@RealisationDate,@BankCharges,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
      Execute sp_acc_InsertGJ @TransactionID,@BANKCHARGES_ACCOUNT,@RealisationDate,0,@BankCharges,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
      Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BANKCHARGES_ACCOUNT,@RealisationDate)      
      Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BankAcID,@RealisationDate)      
              
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24      
       Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24      
      Commit Tran        
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51      
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
      Commit Tran        
      
      Execute sp_acc_InsertGJ @TransactionID,@BANKCHARGES_ACCOUNT,@RealisationDate,@BankCharges,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
      Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BANKCHARGES_ACCOUNT,@RealisationDate)            
      If @CustomerAcID Is NOT NULL      
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@CustomerAcID,@RealisationDate,0,@BankCharges,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@CustomerAcID,@RealisationDate)      
       End        
      Else If IsNULL(@OthersAcID,0) <> 0      
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@OthersAcID,@RealisationDate,0,@BankCharges,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@OthersAcID,@RealisationDate)      
       End        
      Else If IsNULL(@OthersAcID,0) = 0 and IsNULL(@ExpenseAcID,0) <> 0        
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@ExpenseAcID,@RealisationDate,0,@BankCharges,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@ExpenseAcID,@RealisationDate)      
       End        
     End      
   End      
  Else      
   Begin      
    Select @AdjustedAmount=Value,@DocumentDate=DocumentDate,@RealisationDate=RealisationDate from Collections Where DocumentID=@CollectionID      
    If @AdjustedAmount <> 0      
     Begin       
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24      
       Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24      
      Commit Tran        
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51      
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
      Commit Tran        
      
      Execute sp_acc_InsertGJ @TransactionID,@BankAcID,@DocumentDate,@AdjustedAmount,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
      Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BankAcID,@DocumentDate)                
      If @CustomerAcID Is NOT NULL      
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@CustomerAcID,@DocumentDate,0,@AdjustedAmount,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@CustomerAcID,@DocumentDate)      
       End        
      Else If IsNULL(@OthersAcID,0) <> 0      
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@OthersAcID,@DocumentDate,0,@AdjustedAmount,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@OthersAcID,@DocumentDate)      
       End        
      Else If IsNULL(@OthersAcID,0) = 0 and IsNULL(@ExpenseAcID,0) <> 0        
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@ExpenseAcID,@DocumentDate,0,@AdjustedAmount,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@ExpenseAcID,@DocumentDate)      
       End        
     End      
    -----------------------------------Entry for Bank Charges----------------------------------      
    If @BankCharges <> 0      
     Begin      
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24      
       Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24      
      Commit Tran        
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51      
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
      Commit Tran        
             
      Execute sp_acc_InsertGJ @TransactionID,@BankAcID,@RealisationDate,@BankCharges,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
      Execute sp_acc_InsertGJ @TransactionID,@BANKCHARGES_ACCOUNT,@RealisationDate,0,@BankCharges,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
      Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BANKCHARGES_ACCOUNT,@RealisationDate)      
      Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BankAcID,@RealisationDate)      
              
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24      
       Select @TransactionID=DocumentID-1 from DocumentNumbers Where DocType=24      
      Commit Tran        
      Begin Tran        
       Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51      
       Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51      
      Commit Tran        
            
      Execute sp_acc_InsertGJ @TransactionID,@BANKCHARGES_ACCOUNT,@RealisationDate,@BankCharges,0,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
      Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@BANKCHARGES_ACCOUNT,@RealisationDate)      
      If @CustomerAcID Is NOT NULL      
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@CustomerAcID,@RealisationDate,0,@BankCharges,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@CustomerAcID,@RealisationDate)      
       End        
      Else If IsNULL(@OthersAcID,0) <> 0      
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@OthersAcID,@RealisationDate,0,@BankCharges,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@OthersAcID,@RealisationDate)      
       End        
      Else If IsNULL(@OthersAcID,0) = 0 and IsNULL(@ExpenseAcID,0) <> 0        
       Begin        
        Execute sp_acc_InsertGJ @TransactionID,@ExpenseAcID,@RealisationDate,0,@BankCharges,@CollectionID,@BounceType,'Bouncing of Cheque - Cancel',@DocumentNumber      
        Insert Into #TempBakDatedAccounts(AccountID,BackDate) Values(@ExpenseAcID,@RealisationDate)      
       End        
     End      
   End      
 End      
-----------------------------------Backdated Operation---------------------------------------      
DECLARE ScanTempBackdatedAccounts CURSOR KEYSET FOR      
 Select AccountID,Min(BackDate) From #TempBakDatedAccounts Group By AccountID       
OPEN ScanTempBackdatedAccounts        
FETCH FROM ScanTempBackdatedAccounts INTO @TempAccountID,@TempBackdate      
WHILE @@FETCH_STATUS = 0        
 Begin        
  Exec sp_acc_backdatedaccountopeningbalance @TempBackdate,@TempAccountID      
  FETCH NEXT FROM ScanTempBackdatedAccounts INTO @TempAccountID,@TempBackdate      
 End      
CLOSE ScanTempBackdatedAccounts      
DEALLOCATE ScanTempBackdatedAccounts
