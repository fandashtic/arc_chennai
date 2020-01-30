CREATE Procedure sp_acc_checktransactionexists(@PaymentID int)
As
Declare @DocID int
Declare @Amount float
Declare @DocType int
Declare @Adjustment float
Declare @OriginalID nVarchar(50)
Declare @DocumentDate Datetime
Declare @DocumentValue float
Declare @CreateNew Int
Declare @PartyID Int
Declare @Value float
Declare @Ref nVarchar(255)
Declare @PartyType Int
Declare @GetDate Datetime
Declare @ExpenseAccount Int

Set @ExpenseAccount = 15 -- Misellaneous account

Declare @CREDIT_NOTE Int
Declare @ADVANCE Int
Declare @APV Int
Declare @DEBIT_NOTE Int
Declare @ARV Int
Declare @COLLECTION_ADVANCE Int
Declare @NEW_REFERENCE_DR Int
Declare @NEW_REFERENCE_CR Int

Set @CREDIT_NOTE = 2
Set @ADVANCE = 3
Set @APV = 4
Set @DEBIT_NOTE = 5
Set @ARV = 6
Set @COLLECTION_ADVANCE = 7
Set @NEW_REFERENCE_DR = 8
Set @NEW_REFERENCE_CR = 9 

Set @PartyType = 1
Select @PartyID = isnull(Others,0) From Payments Where DocumentID = @PaymentID

Declare GetAdjustedDocs Cursor Static For
Select DocumentID, AdjustedAmount, DocumentType, Adjustment, DocumentDate, 
OriginalID, DocumentValue
From PaymentDetail 
Where PaymentID = @PaymentID
Open GetAdjustedDocs
Fetch From GetAdjustedDocs InTo @DocID, @Amount, @DocType, @Adjustment, @DocumentDate,
@OriginalID, @DocumentValue
While @@Fetch_Status = 0
Begin
	Set @CreateNew  = 0
	If @DocType = @DEBIT_NOTE
	Begin
		If not exists (Select DebitID From DebitNote Where DebitID = @DocID)
		Begin
			Set @CreateNew = 1
		End
	End
	Else If @DocType = @ADVANCE
	Begin
		If not exists (Select DocumentID From Payments Where DocumentID = @DocID)
		Begin
			Set @CreateNew = 1
		End
	End
	Else If @DocType = @ARV
	Begin
		If not exists (Select DocumentID From ARVAbstract Where DocumentID = @DocID)
		Begin
			Set @CreateNew = 1
		End
	End
	Else If @DocType = @APV
	Begin
		If not exists (Select DocumentID from APVAbstract Where DocumentID = @DocID)
		Begin
			Set @CreateNew = 2
		End
	End
	Else If @DocType = @COLLECTION_ADVANCE
	Begin
		If not exists(Select DocumentID From Collections Where DocumentID = @DocID)
		Begin
			Set @CreateNew = 2
		End
	End
	Else If @DocType = @CREDIT_NOTE
	Begin
		If not exists (Select CreditID From CreditNote Where CreditID = @DocID)
		Begin
			Set @CreateNew = 2
		End
	End
	Else If @DocType = @NEW_REFERENCE_DR
	Begin
		If not exists (Select NewRefID From ManualJournal Where NewRefID = @DocID)
		Begin
			Set @CreateNew = 1
		End
	End
	Else If @DocType = @NEW_REFERENCE_CR 
	Begin
		If not exists (Select NewRefID from ManualJournal Where NewRefID = @DocID)
		Begin
			Set @CreateNew = 2
		End
	End

	Set @Value = @Amount + @Adjustment
	Set @Ref = @OriginalID + N',' + Cast(@DocumentDate As nVarchar) + N',' + Cast(@DocumentValue As nVarchar)
-- -- 	Set @GetDate = getdate()
	Set @GetDate = dbo.Sp_Acc_GetOperatingDate(getdate())

	If @CreateNew = 1
	Begin
		exec sp_acc_insert_DebitNote1 2,@PartyID,@Value,@GetDate,@Ref,0,@OriginalID
		Update DebitNote Set AccountID =@ExpenseAccount Where IsNull(DebitID,0)=@@Identity
		-- Exec sp_acc_gj_debitnote @@Identity
	End
	Else If @CreateNew = 2
	Begin
		exec sp_acc_insert_CreditNote 2,@PartyID,@Value,@GetDate,@Ref,@OriginalID					
		Update CreditNote Set AccountID =@ExpenseAccount Where IsNull(CreditID,0)=@@Identity
		-- Exec sp_acc_gj_creditnote @@Identity
	End
	Fetch Next From GetAdjustedDocs InTo @DocID, @Amount, @DocType, @Adjustment, 
	@DocumentDate, @OriginalID, @DocumentValue
End
Close GetAdjustedDocs
DeAllocate GetAdjustedDocs

