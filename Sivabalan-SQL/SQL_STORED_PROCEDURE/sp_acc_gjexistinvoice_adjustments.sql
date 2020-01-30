
Create Procedure sp_acc_gjexistinvoice_adjustments(@InvoiceID Int)
As
-- Credit/Debit Note cancellation journal entries
Declare @ReferenceID Int,@Type Int
If exists(Select ReferenceID From AdjustmentReference Where InvoiceID = @InvoiceID)
Begin
	DECLARE scanadjustmentreference CURSOR KEYSET FOR
	Select ReferenceID, DocumentType from AdjustmentReference where InvoiceID = @InvoiceID
	OPEN scanadjustmentreference
	FETCH FROM scanadjustmentreference INTO @ReferenceID,@Type
	WHILE @@FETCH_STATUS=0
	Begin
		If @Type=5 -- Debit Note
		Begin
			Exec sp_acc_gj_debitnote @ReferenceID
		End
		Else If @Type=2 -- Credit Note
		Begin
			Exec sp_acc_gj_creditnote @ReferenceID
		End
		FETCH NEXT FROM scanadjustmentreference INTO @ReferenceID,@Type
	End
	CLOSE scanadjustmentreference
	DEALLOCATE scanadjustmentreference
End




