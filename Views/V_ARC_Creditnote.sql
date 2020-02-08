IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Creditnote')
BEGIN
    DROP VIEW V_ARC_Creditnote
END
GO
Create View V_ARC_Creditnote
AS
SELECT DocumentDate, CustomerID, SalesmanID, DocRef, NoteValue, Balance, CreditID, Memo, DocumentReference 
FROM Creditnote WITH (NOLOCk)
Go
