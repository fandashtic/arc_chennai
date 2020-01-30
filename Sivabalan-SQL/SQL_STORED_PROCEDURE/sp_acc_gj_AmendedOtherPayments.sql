CREATE Procedure sp_acc_gj_AmendedOtherPayments(@PaymentID INT,@BackDate DateTime=NULL)    
As    
DECLARE @PartyID INT    
DECLARE @ExpenseID INT    
DECLARE @DocumentID INT    
DECLARE @UniqueID INT    
DECLARE @PaymentMode INT,@PaymentDate DateTime    
DECLARE @Value Decimal(18,6),@BankID INT,@ChequeDate DateTime    
DECLARE @BankAccount INT     
DECLARE @Narration nVarChar(50)    
DECLARE @ExtraCol Decimal(18,6)    
DECLARE @AdjAmt Decimal(18,6)    
DECLARE @CurrentDate DateTime    
DECLARE @DDMode INT    
DECLARE @DDCharges Decimal(18,6)    
DECLARE @BANKCHARGES INT    
DECLARE @AccountMode INT
DECLARE @ExpenseAcID INT
DECLARE @ExpenseValue Decimal(18,6)
    
DECLARE @DOCUMENTTYPE INT    
DECLARE @CASH INT    
DECLARE @POSTDATEDCHEQUE INT    
DECLARE @DISCOUNT INT /* Constant to store the Discount AccountID*/    
DECLARE @OTHERCHARGES INT /* Constanat to store the OtherCharges AccountID*/    
    
Set @DOCUMENTTYPE=78    
Set @CASH=3    
Set @POSTDATEDCHEQUE=8    
Set @OTHERCHARGES=14    
Set @DISCOUNT=13    
Set @BANKCHARGES=9     
    
CREATE TABLE #TempBackDatedOtherPayment(AccountID INT) --for backdated operation    
    
Select @PaymentDate=[DocumentDate],@Value=IsNULL(Value,0),@PartyID=IsNULL([Others],0),    
@PaymentMode=[PaymentMode],@BankID=[BankID],@ChequeDate=[Cheque_Date],    
@ExpenseID=IsNULL(ExpenseAccount,0),@DDMode=IsNULL(DDMode,0),@AccountMode=IsNULL(AccountMode,0),
@DDCharges=IsNULL(DDCharges,0) from Payments Where [DocumentID]=@PaymentID    
    
Set @CurrentDate=dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(GetDate()))

Select @ExtraCol=SUM(IsNULL(ExtraCol,0)),@AdjAmt=SUM(IsNULL(Adjustment,0))     
from paymentdetail Where [PaymentID]=@PaymentID     
    
If @PartyID<>0 and @ExpenseID=0     
Begin    
 Begin Tran    
  Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
  Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
 Commit Tran    
    
 Begin Tran    
  Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
  Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
 Commit Tran    
    
 If @PaymentMode=0    
 Begin    
  If @Value<>0    
  Begin    
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@DocumentID,@CASH,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Cash Payment-Amended',@UniqueID)      
			Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@CASH)    
			
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Cash Payment-Amended',@UniqueID)      
			Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
  End     
 End    
 Else If @PaymentMode=1     
 Begin    
  Select @BankAccount=IsNULL([AccountID],0) from bank    
  Where [BankID]=@BankID    
  Set DateFormat DMY     
  /*to check whether the cheque is a current date cheque or postdated cheque*/     
		If (dbo.StripDateFromTime(@PaymentDate)<@CurrentDate) and (dbo.StripDateFromTime(@PaymentDate)<dbo.stripDateFromTime(@ChequeDate)) and  (dbo.stripDateFromTime(@ChequeDate)<=@CurrentDate)    
		Begin    
			If @Value<>0    
			Begin    
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@POSTDATEDCHEQUE,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)  
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@POSTDATEDCHEQUE)    
			End    
			If @Value<>0    
			Begin     
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
			End    
    
   Begin Tran    
    Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
    Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
   Commit Tran    
      
   Begin Tran    
    Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
    Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
   Commit Tran    
      
			If @Value<>0    
			Begin    
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@BankAccount,@ChequeDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@POSTDATEDCHEQUE)    
			End    
			If @Value<>0    
			Begin     
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@POSTDATEDCHEQUE,@ChequeDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
			End    
  End       
		Else If dbo.stripDateFromTime(@ChequeDate)=@CurrentDate or dbo.stripDateFromTime(@ChequeDate)<@CurrentDate    
		Begin    
   If @Value<>0    
   Begin    
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@BankAccount,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Current Date Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
				
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Current Date Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
			End
  End    
		Else If dbo.stripDateFromTime(@ChequeDate)>@CurrentDate    
		Begin    
			If @Value<>0    
			Begin    
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@POSTDATEDCHEQUE,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
				
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@POSTDATEDCHEQUE)    
			End    
		End    
 End    
 Else If @PaymentMode=2    
 Begin    
  If @DDMode=0    
  Begin    
   Set @BankAccount=@CASH    
   Set @Narration='DD Payment Amended-Cash'    
  End     
  Else If @DDMode=1    
  Begin    
   Select @BankAccount=IsNULL([AccountID],0) from bank    
   Where [BankID]=@BankID       
   Set @Narration='DD Payment Amended-BankAccount'    
  End    
  If @Value<>0    
  Begin    
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@BankAccount,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
  End    
  If @Value<>0    
  Begin     
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
  End    
      
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
   Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
  Commit Tran    
    
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
   Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
  Commit Tran    
    
  If @DDCharges<>0    
  Begin    
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@BankAccount,@PaymentDate,@DDCharges,0,@PaymentID,@DOCUMENTTYPE,'DD Payment Amended-DD Charges',@UniqueID)    
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BANKCHARGES)    
  End    
  If @DDCharges<>0    
  Begin     
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@BANKCHARGES,@PaymentDate,0,@DDCharges,@PaymentID,@DOCUMENTTYPE,'DD Payment Amended-DD Charges',@UniqueID)    
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
  End     
 End     
 Else If @PaymentMode=4 /* Bank Transfer Mode */
 Begin    
 	Select @BankAccount=IsNULL([AccountID],0) from bank    
  Where [BankID]=@BankID       
 	Set @Narration='Bank Transfer Payment-Amended'
		If @Value<>0    
		Begin    
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@DocumentID,@BankAccount,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
			Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
		End    
		If @Value<>0    
		Begin     
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
			Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
		End    
 End
     
 If (@ExtraCol>0) or (@AdjAmt>0)    
 Begin    
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
   Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
  Commit Tran      
    
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
   Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
  Commit Tran    
 End   
     
 If @ExtraCol>0    
 Begin    
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@DocumentID,@PartyID,@PaymentDate,@ExtraCol,0,@PaymentID,@DOCUMENTTYPE,'Extra Amount Paid-Amended',@UniqueID)    
		Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@OTHERCHARGES)    
		
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@DocumentID,@OTHERCHARGES,@PaymentDate,0,@ExtraCol,@PaymentID,@DOCUMENTTYPE,'Extra Amount Paid-Amended',@UniqueID)       
		Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
 End    
       
 If @AdjAmt>0     
 Begin    
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@DocumentID,@DISCOUNT,@PaymentDate,@AdjAmt,0,@PaymentID,@DOCUMENTTYPE,'Adjusted with Shortage Paid-Amended',@UniqueID)       
		Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
		
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@DocumentID,@PartyID,@PaymentDate,0,@AdjAmt,@PaymentID,@DOCUMENTTYPE,'Adjusted with Shortage Paid-Amended',@UniqueID)    
		Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@DISCOUNT)    
 End    
End    
Else If @PartyID<>0 and @ExpenseID<>0     
Begin    
 Begin Tran    
  Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
  Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
 Commit Tran    
    
 Begin Tran    
  Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
  Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
 Commit Tran    
    
 If @PaymentMode=0    
 Begin    
  If @Value<>0    
  Begin    
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@CASH,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Cash Payment-Amended',@UniqueID)      
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
      
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Cash Payment-Amended',@UniqueID)      
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@CASH)    
      
   Set @Narration='Cash Payment-Amended'    
  End     
 End    
 Else If @PaymentMode=1    
 Begin    
  Select @BankAccount=IsNULL([AccountID],0) from bank    
  Where [BankID]=@BankID    
  Set DateFormat DMY     
  /*to check whether the cheque is a current date cheque or postdated cheque*/     
		If (dbo.StripDateFromTime(@PaymentDate)<@CurrentDate) and (dbo.StripDateFromTime(@PaymentDate)<dbo.stripDateFromTime(@ChequeDate)) and  (dbo.stripDateFromTime(@ChequeDate)<=@CurrentDate)    
		Begin    
			If @Value<>0    
			Begin    
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@POSTDATEDCHEQUE,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
			End    
			If @Value<>0    
			Begin     
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@POSTDATEDCHEQUE)    
			End    
	    
	  Begin Tran    
	   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
	   Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
	  Commit Tran    
	     
	  Begin Tran    
	   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
	   Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
	  Commit Tran    
	    
			If @Value<>0    
			Begin  
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],   
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@BankAccount,@ChequeDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@POSTDATEDCHEQUE)    
			End    
			If @Value<>0    
			Begin     
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@POSTDATEDCHEQUE,@ChequeDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
			End    
		End       
		Else If dbo.stripDateFromTime(@ChequeDate)=@CurrentDate or dbo.stripDateFromTime(@ChequeDate)<@CurrentDate    
		Begin    
   If @Value<>0    
   Begin    
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@BankAccount,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Current Date Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
				
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Current Date Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
        
    Set @Narration='Current Date Cheque Payment-Amended'    
   End    
		End    
		Else If dbo.stripDateFromTime(@ChequeDate)>@CurrentDate    
		Begin    
   If @Value<>0    
   Begin    
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@POSTDATEDCHEQUE,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
				
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@POSTDATEDCHEQUE)    
				
				Set @Narration='Post Dated Cheque Payment-Amended'    
   End    
		End    
	End    
 Else If @PaymentMode=2    
 Begin    
  If @DDMode=0    
  Begin    
   Set @BankAccount=@CASH    
   Set @Narration='DD Payment Amended-Cash'    
  End     
  Else If @DDMode=1    
  Begin    
   Select @BankAccount=IsNULL([AccountID],0) from bank    
   Where [BankID]=@BankID       
   Set @Narration='DD Payment Amended-BankAccount'    
  End    
  If @Value<>0    
  Begin    
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@BankAccount,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
  End    
  If @Value<>0    
  Begin     
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
  End    
      
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
   Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
  Commit Tran    
    
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
   Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
  Commit Tran    
    
  If @DDCharges<>0    
  Begin    
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@BankAccount,@PaymentDate,@DDCharges,0,@PaymentID,@DOCUMENTTYPE,'DD Payment-Amended-DD Charges',@UniqueID)    
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BANKCHARGES)    
  End    
  If @DDCharges<>0    
  Begin     
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@BANKCHARGES,@PaymentDate,0,@DDCharges,@PaymentID,@DOCUMENTTYPE,'DD Payment-Amended-DD Charges',@UniqueID)    
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
  End     
 End      
 Else If @PaymentMode=4 /* Bank Transfer */    
 Begin    
 	Select @BankAccount=IsNULL([AccountID],0) from bank    
  Where [BankID]=@BankID
 	Set @Narration='Bank Transfer Payment-Amended'
 	If @Value<>0    
 	Begin    
 		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
 		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
 		Values(@DocumentID,@BankAccount,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
 		Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
 	End    
		If @Value<>0    
		Begin     
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
			Values(@DocumentID,@PartyID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
			Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
		End    
	End
 
 Begin Tran    
  Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
  Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
 Commit Tran    
    
 Begin Tran    
  Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
  Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
 Commit Tran    
    
 Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
 Values(@DocumentID,@PartyID,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
 Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    

 If @AccountMode=1
  Begin
   DECLARE ScanPaymentExpense CURSOR KEYSET FOR
   Select AccountID,Amount from PaymentExpense Where PaymentID=@PaymentID
   OPEN ScanPaymentExpense
   FETCH FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
   WHILE @@Fetch_Status=0
    Begin
					Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
					Values(@DocumentID,@ExpenseAcID,@PaymentDate,0,@ExpenseValue,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)  
					Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseAcID)  

     FETCH NEXT FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
    End
   CLOSE ScanPaymentExpense
   DEALLOCATE ScanPaymentExpense
  End
 Else
  Begin
		 Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		 Values(@DocumentID,@ExpenseID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)     
		 Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseID)    
		End
    
 If (@ExtraCol>0) or (@AdjAmt>0)    
 Begin    
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
   Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
  Commit Tran      
    
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
   Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
  Commit Tran    
 End    
     
 If @ExtraCol>0    
 Begin    
  Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
  [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
  Values(@DocumentID,@PartyID,@PaymentDate,@ExtraCol,0,@PaymentID,@DOCUMENTTYPE,'Extra Amount Paid-Amended',@UniqueID)    
  Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@OTHERCHARGES)    
    
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@DocumentID,@OTHERCHARGES,@PaymentDate,0,@ExtraCol,@PaymentID,@DOCUMENTTYPE,'Extra Amount Paid-Amended',@UniqueID)       
  Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
 End    
       
 If @AdjAmt>0     
 Begin    
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@DocumentID,@DISCOUNT,@PaymentDate,@AdjAmt,0,@PaymentID,@DOCUMENTTYPE,'Adjusted with Shortage Paid-Amended',@UniqueID)       
		Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@PartyID)    
		
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@DocumentID,@PartyID,@PaymentDate,0,@AdjAmt,@PaymentID,@DOCUMENTTYPE,'Adjusted with Shortage Paid-Amended',@UniqueID)    
		Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@DISCOUNT)    
 End    
End     
Else If @PartyID=0 and @ExpenseID<>0    
Begin    
 Begin Tran    
  Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
  Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
 Commit Tran    
    
 Begin Tran    
  Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
  Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
 Commit Tran    
    
 If @PaymentMode=0    
 Begin    
	 If @Value<>0    
  Begin    
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@CASH,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Cash Payment-Amended',@UniqueID)      
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@CASH)    
      
		 If @AccountMode=1
		  Begin
		   DECLARE ScanPaymentExpense CURSOR KEYSET FOR
		   Select AccountID,Amount from PaymentExpense Where PaymentID=@PaymentID
		   OPEN ScanPaymentExpense
		   FETCH FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
		   WHILE @@Fetch_Status=0
		    Begin
							Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
							[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
							Values(@DocumentID,@ExpenseAcID,@PaymentDate,0,@ExpenseValue,@PaymentID,@DOCUMENTTYPE,'Cash Payment-Amended',@UniqueID)  
							Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseAcID)  
		     
		     FETCH NEXT FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
		    End
		   CLOSE ScanPaymentExpense
		   DEALLOCATE ScanPaymentExpense
		  End
		 Else
		  Begin
		   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		   Values(@DocumentID,@ExpenseID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Cash Payment-Amended',@UniqueID)      
		   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseID)    
				End
  End     
 End    
 Else If @PaymentMode=1    
 Begin    
  Select @BankAccount=IsNULL([AccountID],0) from bank    
  Where [BankID]=@BankID    
  Set DateFormat DMY     
  /*to check whether the cheque is a current date cheque or postdated cheque*/     
		If (dbo.StripDateFromTime(@PaymentDate)<@CurrentDate) and (dbo.StripDateFromTime(@PaymentDate)<dbo.stripDateFromTime(@ChequeDate)) and  (dbo.stripDateFromTime(@ChequeDate)<=@CurrentDate)    
		Begin    
			If @Value<>0    
			Begin    
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@POSTDATEDCHEQUE,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@POSTDATEDCHEQUE)    
			End    
			If @Value<>0    
			Begin     
			 If @AccountMode=1
			  Begin
			   DECLARE ScanPaymentExpense CURSOR KEYSET FOR
			   Select AccountID,Amount from PaymentExpense Where PaymentID=@PaymentID
			   OPEN ScanPaymentExpense
			   FETCH FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
			   WHILE @@Fetch_Status=0
			    Begin
								Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
								[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
								Values(@DocumentID,@ExpenseAcID,@PaymentDate,0,@ExpenseValue,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)  
								Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseAcID)  
			     
			     FETCH NEXT FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
			    End
			   CLOSE ScanPaymentExpense
			   DEALLOCATE ScanPaymentExpense
			  End
			 Else
			  Begin
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
						Values(@DocumentID,@ExpenseID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
						Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseID)    
					End
		 End    
		 
   Begin Tran    
    Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
    Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
   Commit Tran    
      
   Begin Tran    
    Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
    Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
   Commit Tran 
    
			If @Value<>0    
			Begin    
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@BankAccount,@ChequeDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@POSTDATEDCHEQUE)    
			End    
			If @Value<>0    
			Begin     
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@POSTDATEDCHEQUE,@ChequeDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
			End    
  End       
		Else If dbo.stripDateFromTime(@ChequeDate)=@CurrentDate or dbo.stripDateFromTime(@ChequeDate)<@CurrentDate   
		Begin    
			If @Value<>0    
			Begin    
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@BankAccount,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Current Date Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
				
			 If @AccountMode=1
			  Begin
			   DECLARE ScanPaymentExpense CURSOR KEYSET FOR
			   Select AccountID,Amount from PaymentExpense Where PaymentID=@PaymentID
			   OPEN ScanPaymentExpense
			   FETCH FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
			   WHILE @@Fetch_Status=0
			    Begin
								Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
								[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
								Values(@DocumentID,@ExpenseAcID,@PaymentDate,0,@ExpenseValue,@PaymentID,@DOCUMENTTYPE,'Current Date Cheque Payment-Amended',@UniqueID)  
								Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseAcID)  
			     
			     FETCH NEXT FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
			    End
			   CLOSE ScanPaymentExpense
			   DEALLOCATE ScanPaymentExpense
			  End
			 Else
			  Begin
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
						Values(@DocumentID,@ExpenseID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Current Date Cheque Payment-Amended',@UniqueID)    
						Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseID)    
					End
			End    
		End    
		Else If dbo.stripDateFromTime(@ChequeDate)>@PaymentDate     
		Begin    
   If @Value<>0    
   Begin    
				Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
				Values(@DocumentID,@POSTDATEDCHEQUE,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
				Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@POSTDATEDCHEQUE)    
				
			 If @AccountMode=1
			  Begin
			   DECLARE ScanPaymentExpense CURSOR KEYSET FOR
			   Select AccountID,Amount from PaymentExpense Where PaymentID=@PaymentID
			   OPEN ScanPaymentExpense
			   FETCH FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
			   WHILE @@Fetch_Status=0
			    Begin
								Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
								[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
								Values(@DocumentID,@ExpenseAcID,@PaymentDate,0,@ExpenseValue,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)  
								Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseAcID)  
			     
			     FETCH NEXT FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
			    End
			   CLOSE ScanPaymentExpense
			   DEALLOCATE ScanPaymentExpense
			  End
			 Else
			  Begin
						Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
						[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
						Values(@DocumentID,@ExpenseID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,'Post Dated Cheque Payment-Amended',@UniqueID)    
						Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseID)    
					End
   End    
		End    
	End    
	Else If @PaymentMode=2    
 Begin    
  If @DDMode=0    
  Begin    
   Set @BankAccount=@CASH    
   Set @Narration='DD Payment Amended-Cash'    
  End     
  Else If @DDMode=1    
  Begin    
   Select @BankAccount=IsNULL([AccountID],0) from bank    
   Where [BankID]=@BankID       
   Set @Narration='DD Payment Amended-BankAccount'    
  End    
  If @Value<>0  
  Begin    
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@BankAccount,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
  End    
  If @Value<>0    
  Begin     
		 If @AccountMode=1
		  Begin
		   DECLARE ScanPaymentExpense CURSOR KEYSET FOR
		   Select AccountID,Amount from PaymentExpense Where PaymentID=@PaymentID
		   OPEN ScanPaymentExpense
		   FETCH FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
		   WHILE @@Fetch_Status=0
		    Begin
							Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
							[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
							Values(@DocumentID,@ExpenseAcID,@PaymentDate,0,@ExpenseValue,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)  
							Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseAcID)  
		     
		     FETCH NEXT FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
		    End
		   CLOSE ScanPaymentExpense
		   DEALLOCATE ScanPaymentExpense
		  End
		 Else
		  Begin
		   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		   Values(@DocumentID,@ExpenseID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
		   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseID)    
				End
  End    
      
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
   Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
  Commit Tran   
    
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
   Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
  Commit Tran    
    
  If @DDCharges<>0    
  Begin    
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@BankAccount,@PaymentDate,@DDCharges,0,@PaymentID,@DOCUMENTTYPE,'DD Payment Amended-DD Charges',@UniqueID)    
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BANKCHARGES)    
  End    
  If @DDCharges<>0    
  Begin     
   Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
   Values(@DocumentID,@BANKCHARGES,@PaymentDate,0,@DDCharges,@PaymentID,@DOCUMENTTYPE,'DD Payment Amended-DD Charges',@UniqueID)    
   Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
  End     
 End    
 Else If @PaymentMode=4
 Begin    
		Select @BankAccount=IsNULL([AccountID],0) from bank    
		Where [BankID]=@BankID       
		Set @Narration='Bank Transfer Payment-Amended'
		If @Value<>0    
		Begin    
			Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])   
			Values(@DocumentID,@BankAccount,@PaymentDate,@Value,0,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
			Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@BankAccount)    
		End
		If @Value<>0    
		Begin     
		 If @AccountMode=1
		  Begin
		   DECLARE ScanPaymentExpense CURSOR KEYSET FOR
		   Select AccountID,Amount from PaymentExpense Where PaymentID=@PaymentID
		   OPEN ScanPaymentExpense
		   FETCH FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
		   WHILE @@Fetch_Status=0
		    Begin
							Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
							[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
							Values(@DocumentID,@ExpenseAcID,@PaymentDate,0,@ExpenseValue,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)  
							Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseAcID)  
		     
		     FETCH NEXT FROM ScanPaymentExpense INTO @ExpenseAcID,@ExpenseValue
		    End
		   CLOSE ScanPaymentExpense
		   DEALLOCATE ScanPaymentExpense
		  End
		 Else
		  Begin
					Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
					[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
					Values(@DocumentID,@ExpenseID,@PaymentDate,0,@Value,@PaymentID,@DOCUMENTTYPE,@Narration,@UniqueID)    
					Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseID)    
				End
		End    
 End

 If (@ExtraCol>0) or (@AdjAmt>0)    
 Begin     
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=24    
   Select @DocumentID=DocumentID-1 from DocumentNumbers Where DocType=24    
  Commit Tran      
    
  Begin Tran    
   Update DocumentNumbers Set DocumentID=DocumentID+1 Where DocType=51    
   Select @UniqueID=DocumentID-1 from DocumentNumbers Where DocType=51    
  Commit Tran    
 End    
    
 If @ExtraCol>0    
 Begin    
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@DocumentID,@ExpenseID,@PaymentDate,@ExtraCol,0,@PaymentID,@DOCUMENTTYPE,'Extra Amount Paid-Amended',@UniqueID)    
		Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@OTHERCHARGES)    
		
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@DocumentID,@OTHERCHARGES,@PaymentDate,0,@ExtraCol,@PaymentID,@DOCUMENTTYPE,'Extra Amount Paid-Amended',@UniqueID)       
		Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseID)    
	End    
       
 If @AdjAmt>0     
 Begin    
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@DocumentID,@DISCOUNT,@PaymentDate,@AdjAmt,0,@PaymentID,@DOCUMENTTYPE,'Adjusted with Shortage Paid-Amended',@UniqueID)       
		Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@ExpenseID)    
		
		Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],    
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])    
		Values(@DocumentID,@ExpenseID,@PaymentDate,0,@AdjAmt,@PaymentID,@DOCUMENTTYPE,'Adjusted with Shortage Paid-Amended',@UniqueID)    
		Insert INTO #TempBackDatedOtherPayment(AccountID) Values(@DISCOUNT)    
 End    
End    

If @BackDate Is Not NULL      
Begin    
 DECLARE @TempAccountID INT    
 DECLARE ScanTempBackDatedAccounts CURSOR KEYSet FOR    
 Select AccountID From #TempBackDatedOtherPayment    
 OPEN ScanTempBackDatedAccounts    
 FETCH FROM ScanTempBackDatedAccounts INTO @TempAccountID    
 WHILE @@FETCH_STATUS=0    
 Begin    
  Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID    
  FETCH NEXT FROM ScanTempBackDatedAccounts INTO @TempAccountID    
 End    
 CLOSE ScanTempBackDatedAccounts    
 DEALLOCATE ScanTempBackDatedAccounts    
End    
Drop Table #TempBackDatedOtherPayment 
