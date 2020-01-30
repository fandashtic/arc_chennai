CREATE Procedure sp_acc_prn_cus_CreditNoteDetail (@DocumentID int)
as
DECLARE @MULTIPLE 	INT
Create Table #CreditNoteDetail
(
	ExpenseId Int,
	Amount Decimal(18,6)
)

Select @MULTIPLE = Isnull(AccountMode,0) from CreditNote 
where CreditID = @DocumentID

If @MULTIPLE = 1
Begin
	Insert into #CreditNoteDetail
	Select AccountID,NoteValue from NoteDetail where 
	NoteID = @DocumentID and NoteType = 2
End
Else
Begin
	Insert into #CreditNoteDetail
	Select AccountID,NoteValue from CreditNote where 
	CreditID = @DocumentID 
End

Select 
"Expense Account" = dbo.getaccountname(isnull(#CreditNoteDetail.ExpenseId,0)),
"Note Value" = Amount
From #CreditNoteDetail

