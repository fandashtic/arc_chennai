--Exec SP_ARC_GetAllCreditnote
--Exec ARC_Insert_ReportData 541, 'All Credit Note', 1, 'SP_ARC_GetAllCreditnote', 'Click to view All Credit Note', 376, 0, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_GetAllCreditnote')
BEGIN
    DROP PROC SP_ARC_GetAllCreditnote
END
GO
Create Proc SP_ARC_GetAllCreditnote  
AS  
BEGIN 
	SELECT DISTINCT
		S.CreditID [ID] ,
		S.DocumentReference [CreditnoteId],
		S.DocumentDate CreditnoteDate,
		S.CustomerId,
		(SELECT TOP 1 Company_Name FROM Customer WITH (NOLOCK) WHERE CustomerID = S.CustomerId) [CustomerName], 
		S.SalesmanID,
		(SELECT TOP 1 Salesman_Name FROM Salesman WITH (NOLOCK) WHERE SalesmanID = S.SalesmanID) [SalesmanName],
		S.NoteValue NetValue,
		S.Balance,
		S.Memo,
		S.DocRef [ReferenceId]
	FROM 
	V_ARC_Creditnote S WITH (NOLOCK) 
	ORDER BY S.CreditID
END
GO
