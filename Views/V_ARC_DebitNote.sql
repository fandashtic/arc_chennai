IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_DebitNote')
BEGIN
    DROP VIEW V_ARC_DebitNote
END
GO
Create View V_ARC_DebitNote
AS
	SELECT 
		DocumentID,
		DocumentDate, 
		CustomerID, 
		VendorId,
		SalesmanID, 
		DocRef, 
		NoteValue, 
		Balance,
		DebitID, 
		OriginalDebitID, 
		Memo, 
		Flag,
		ISNULL(DocumentReference, 'DR' + cast(DocumentID as Varchar)) DocumentReference
	FROM DebitNote WITH (NOLOCk) 
	--WHERE isnull(DebitNote.Flag,0) <> 2
Go