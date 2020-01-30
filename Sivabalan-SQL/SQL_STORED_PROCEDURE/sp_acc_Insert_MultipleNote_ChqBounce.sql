Create Procedure sp_acc_Insert_MultipleNote_ChqBounce(@CollectionID INT,@PartyType INT,      
@PartyID nVarChar(50),@ChqNo nVarChar(50),@BankAccount INT)      
As      
Declare @DISCOUNT_ACCOUNT INT      
Declare @OTHERCHARGES_ACCOUNT INT      
Declare @CHEQUEBOUNCE INT      
Declare @CHEQUEBOUNCECR INT      
Declare @DocumentID INT      
Declare @DocumentType INT      
Declare @DocumentDate DateTime      
Declare @Remarks nVarChar(255)      
Declare @OriginalID nVarChar(30)      
Declare @ERPCollection INT      
Declare @PrefixType INT      
Declare @CollBalance Decimal(18,6)    
Declare @AdjustedAmount Decimal(18,6)      
Declare @ExtraCollection Decimal(18,6)      
Declare @Adjustment Decimal(18,6)      
Declare @TotExtraCollection Decimal(18,6)      
Declare @TotAdjustment Decimal(18,6)      
Declare @DebitNoteID int

Declare  @tmpcolid int
Declare @tmp nvarchar(4000)
Declare @tmpDebitID Table(DocumentID Int)
Insert Into @tmpDebitID Values (0)
Set @DISCOUNT_ACCOUNT = 13      
Set @OTHERCHARGES_ACCOUNT = 14      
Set @CHEQUEBOUNCE = 2      
Set @CHEQUEBOUNCECR = 5      
      
If Exists(Select * from Collections Where DocumentID=@CollectionID And CustomerID Is NOT NULL)      
 Set @ERPCollection = 1      
Else      
 Set @ERPCollection = 0      
      
If (Select Count(*) from CollectionDetail Where CollectionID=@CollectionID) > 0      
 Begin      
  DECLARE ScanCollections CURSOR KEYSET FOR      
   Select DocumentID,DocumentType,DocumentDate,AdjustedAmount,OriginalID,      
   ExtraCollection,Adjustment from CollectionDetail Where CollectionID=@CollectionID      
  OPEN ScanCollections      
  FETCH FROM ScanCollections INTO @DocumentID,@DocumentType,@DocumentDate,@AdjustedAmount,@OriginalID,@ExtraCollection,@Adjustment      
  While @@FETCH_STATUS = 0      
   Begin      
    Set @Remarks=N'Bouncing Amount Cheque No:' + CAST(@ChqNo As nVarChar) + Char(13) + Char(10) + CAST(@OriginalID As nVarChar)      
    If @DocumentType = 8      
     Begin       
      Select @PrefixType=PrefixType from ManualJournal Where NewRefID=@DocumentID      
     End      
    If @DocumentType=1 Or @DocumentType=2 Or @DocumentType=3 Or (@DocumentType=7 And @ERPCollection=1) Or (@DocumentType=6 And @ERPCollection=0) Or (@DocumentType=8 And @PrefixType=2)      
     Begin      
      Exec sp_acc_Insert_CreditNote_Realisation @PartyType,@PartyID,@AdjustedAmount,@DocumentDate,@Remarks,@BankAccount,@CHEQUEBOUNCECR      
      Exec sp_acc_Insert_BounceNote @CollectionID,@@Identity,2
      
      Set @TotExtraCollection = IsNULL(@TotExtraCollection,0) - IsNULL(@ExtraCollection,0)      
      Set @TotAdjustment = IsNULL(@TotAdjustment,0) - IsNULL(@Adjustment,0)      
     End      
    Else If @DocumentType=4 Or @DocumentType=5 Or (@DocumentType=7 And @ERPCollection=0) Or (@DocumentType=6 And @ERPCollection=1) Or (@DocumentType=8 And @PrefixType=1)      
     Begin      
      Exec sp_acc_insert_DebitNote_Realisation @PartyType,@PartyID,@AdjustedAmount,@DocumentDate,@Remarks,@BankAccount,@CHEQUEBOUNCE      
      -- To update Debit details in ChequeCollDetails Table to Consolidate the Debit Note with Invoice Details for ITC
      Set @DebitNoteID = @@Identity
      Exec sp_acc_Insert_BounceNote @CollectionID,@@Identity,1   
		
		   Select Top 1 @tmpcolid = DocumentID from ChequeColldetails where CollectionID =@CollectionID and documenttype = 5 And isnull(debitID,0) = 0 And DocumentID not in (Select DocumentID From @tmpDebitID)

			Insert Into @tmpDebitID Values (@tmpcolid)

		   If(Select count(*) from chequecolldetails where isnull(DebitID,0) = @tmpcolID) = 1
					Update ChequeCollDetails Set DebitID =@DebitNoteID, ChqStatus = 2 Where DebitID =@tmpColid
			Else
					Update ChequeCollDetails Set DebitID =@DebitNoteID, ChqStatus = 2 Where CollectionID=@CollectionID and DocumentID=@DocumentID

      Set @TotExtraCollection = IsNULL(@TotExtraCollection,0) + IsNULL(@ExtraCollection,0)      
      Set @TotAdjustment = IsNULL(@TotAdjustment,0) + IsNULL(@Adjustment,0)      

     End      
    FETCH Next FROM ScanCollections INTO @DocumentID,@DocumentType,@DocumentDate,@AdjustedAmount,@OriginalID,@ExtraCollection,@Adjustment      
   End      
  CLOSE ScanCollections      
  DEALLOCATE ScanCollections      
  -----------------------------Entry for Collection Balance Value----------------------------  
  Select @CollBalance=Balance,@DocumentDate=DocumentDate,@OriginalID=FullDocID from Collections Where DocumentID=@CollectionID      
  Set @Remarks=N'Bouncing Amount Cheque No:' + CAST(@ChqNo As nVarChar) + Char(13) + Char(10) + CAST(@OriginalID As nVarChar)      
  Set @TotExtraCollection = IsNULL(@TotExtraCollection,0)      
  Set @TotAdjustment = IsNULL(@TotAdjustment,0)      
  If @CollBalance > 0    
   Begin     
    Exec sp_acc_insert_DebitNote_Realisation @PartyType,@PartyID,@CollBalance,@DocumentDate,@Remarks,@BankAccount,@CHEQUEBOUNCE    
    Exec sp_acc_Insert_BounceNote @CollectionID,@@Identity,1      
   End    
  ------------------------------Entry for Additional Adjustments-----------------------------  
  If @TotExtraCollection > 0      
   Begin      
    Exec sp_acc_insert_DebitNote_Realisation @PartyType,@PartyID,@TotExtraCollection,@DocumentDate,@Remarks,@BankAccount,@CHEQUEBOUNCE  
    Exec sp_acc_Insert_BounceNote @CollectionID,@@Identity,1      
   End      
  Else If @TotExtraCollection < 0      
   Begin      
    Set @TotExtraCollection = ABS(@TotExtraCollection)      
    Exec sp_acc_Insert_CreditNote_Realisation @PartyType,@PartyID,@TotExtraCollection,@DocumentDate,@Remarks,@BankAccount,@CHEQUEBOUNCE  
    Exec sp_acc_Insert_BounceNote @CollectionID,@@Identity,2  
   End      
 End      
Else      
 Begin      
  Select @AdjustedAmount=Value,@DocumentDate=DocumentDate,@OriginalID=FullDocID from Collections Where DocumentID=@CollectionID      
  Set @Remarks=N'Bouncing Amount Cheque No:' + CAST(@ChqNo As nVarChar) + Char(13) + Char(10) + CAST(@OriginalID As nVarChar)      
  Exec sp_acc_insert_DebitNote_Realisation @PartyType,@PartyID,@AdjustedAmount,@DocumentDate,@Remarks,@BankAccount,@CHEQUEBOUNCE      
  Exec sp_acc_Insert_BounceNote @CollectionID,@@Identity,1      
 End  
