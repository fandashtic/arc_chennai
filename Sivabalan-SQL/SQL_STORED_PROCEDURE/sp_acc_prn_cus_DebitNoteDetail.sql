CREATE Procedure sp_acc_prn_cus_DebitNoteDetail (@DocumentID int)
as
DECLARE @MULTIPLE 	INT
Create Table #DebitNoteDetail
(
	ExpenseId Int,
	Amount Decimal(18,6)
)

Select @MULTIPLE = Isnull(AccountMode,0) from DebitNote 
where DebitID = @DocumentID

If @MULTIPLE = 1
Begin
	Insert into #DebitNoteDetail
	Select AccountID,NoteValue from NoteDetail where 
	NoteID = @DocumentID and NoteType = 1
End
Else
Begin
	Insert into #DebitNoteDetail
	Select AccountID,NoteValue from DebitNote where 
	DebitID = @DocumentID 
End

Select 
"Expense Account" = dbo.getaccountname(isnull(#DebitNoteDetail.ExpenseId,0)),
"Note Value" = Amount
From #DebitNoteDetail

