--Exec SP_ARC_GetAllDebitnote
--Exec ARC_Insert_ReportData 551, 'All Debit Note', 1, 'SP_ARC_GetAllDebitnote', 'Click to view All Debit Note', 376, 0, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_GetAllDebitnote')
BEGIN
    DROP PROC SP_ARC_GetAllDebitnote
END
GO
Create Proc SP_ARC_GetAllDebitnote  
AS  
BEGIN 
	SELECT DISTINCT
		S.DebitID [ID] ,
		S.DocumentReference [DebitnoteId],
		S.DocumentDate DebitnoteDate,
		S.CustomerId,
		(SELECT TOP 1 Company_Name FROM Customer WITH (NOLOCK) WHERE CustomerID = S.CustomerId) [CustomerName], 
		S.SalesmanID,
		(SELECT TOP 1 Salesman_Name FROM Salesman WITH (NOLOCK) WHERE SalesmanID = S.SalesmanID) [SalesmanName],
		S.VendorId,
		(SELECT TOP 1 Vendor_Name FROM Vendors WITH (NOLOCK) WHERE VendorID = S.VendorID) [VendorName],
		S.NoteValue NetValue,
		S.Balance,
		S.Memo,
		S.DocRef [ReferenceId]
	FROM 
	V_ARC_DebitNote S WITH (NOLOCK) 
	ORDER BY S.DebitID
END
GO