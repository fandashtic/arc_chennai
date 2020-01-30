CREATE Procedure [dbo].[sp_Get_AdjRefInfo] (@InvoiceID Int, @TransType int = 0)
As
if @TransType = 0
	Begin
		Select AdjustmentReference.DocumentType, AdjustmentReference.ReferenceID,
		DebitNote.Memo, DebitNote.NoteValue, AdjustmentReason.AdjReasonID
		From AdjustmentReference
		Inner Join DebitNote on AdjustmentReference.ReferenceID = DebitNote.DebitID
		Left Outer Join AdjustmentReason on DebitNote.Memo = AdjustmentReason.Reason
		Where AdjustmentReference.InvoiceID = @InvoiceID And
		--AdjustmentReference.ReferenceID = DebitNote.DebitID And
		--DebitNote.Memo *= AdjustmentReason.Reason And
		AdjustmentReference.DocumentType = 5 
		and TransactionType = 0
		
		Union All
		
		Select AdjustmentReference.DocumentType, AdjustmentReference.ReferenceID,
		CreditNote.Memo, 0 - CreditNote.NoteValue, AdjustmentReason.AdjReasonID
		From AdjustmentReference
		Inner Join CreditNote on AdjustmentReference.ReferenceID = CreditNote.CreditID
		Left Outer Join AdjustmentReason on CreditNote.Memo = AdjustmentReason.Reason
		Where AdjustmentReference.InvoiceID = @InvoiceID And
		--AdjustmentReference.ReferenceID = CreditNote.CreditID And
		--CreditNote.Memo *= AdjustmentReason.Reason And
		AdjustmentReference.DocumentType = 2 
		and TransactionType = 0
	End
Else
	Begin
		Select AdjustmentReference.DocumentType, AdjustmentReference.ReferenceID,
		DebitNote.Memo, 0 - DebitNote.NoteValue, AdjustmentReason.AdjReasonID
		From AdjustmentReference
		Inner Join DebitNote on AdjustmentReference.ReferenceID = DebitNote.DebitID
		Left Outer Join AdjustmentReason on DebitNote.Memo = AdjustmentReason.Reason
		Where AdjustmentReference.InvoiceID = @InvoiceID And
		--AdjustmentReference.ReferenceID = DebitNote.DebitID And
		--DebitNote.Memo *= AdjustmentReason.Reason And
		AdjustmentReference.DocumentType = 2 and TransactionType = 1
		
		Union All
		
		Select AdjustmentReference.DocumentType, AdjustmentReference.ReferenceID,
		CreditNote.Memo, CreditNote.NoteValue, AdjustmentReason.AdjReasonID
		From AdjustmentReference
		Inner Join CreditNote on AdjustmentReference.ReferenceID = CreditNote.CreditID
		Left Outer Join AdjustmentReason on CreditNote.Memo = AdjustmentReason.Reason
		Where AdjustmentReference.InvoiceID = @InvoiceID And
		--AdjustmentReference.ReferenceID = CreditNote.CreditID And
		--CreditNote.Memo *= AdjustmentReason.Reason And
		AdjustmentReference.DocumentType = 5 and TransactionType = 1
	End

