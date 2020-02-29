--Exec SP_ARC_GetAllCollections
--Exec ARC_Insert_ReportData 514, 'All Collections', 1, 'SP_ARC_GetAllCollections', 'Click to view All Collections', 376, 0, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_GetAllCollections')
BEGIN
    DROP PROC SP_ARC_GetAllCollections
END
GO
Create Proc SP_ARC_GetAllCollections  
AS  
BEGIN 
	SELECT
		CO.DocumentID,
		CO.CollectionDate,
		CO.CustomerId,
		(SELECT TOP 1 Company_Name FROM Customer WITH (NOLOCK) WHERE CustomerID = CO.CustomerId) [CustomerName], 
		CO.SalesmanID,
		(SELECT TOP 1 Salesman_Name FROM Salesman WITH (NOLOCK) WHERE SalesmanID = CO.SalesmanID) [SalesmanName],
		CO.BeatID,
		(SELECT TOP 1 Description FROM Beat WITH (NOLOCK) WHERE BeatID = CO.BeatID) [BeatName],
		CO.CollectionId,
		CO.CollectionAmount,
		CO.InvoiceReference,
		CO.Paymentmode,
		CO.ChequeDate,
		CO.ChequeNumber,
		CO.ChequeDetails,
		CO.DepositDate,
		CO.BankCode,
		CO.BranchCode,
		CO.ClearingAmount,
		CO.Realised,
		CO.RealiseDate,
		CO.BankCharges,
		CO.ExtraCollection,
		CO.Adjustment
	INTO #CL
	FROM 
	V_ARC_Collections CO WITH (NOLOCK) 
	ORDER BY CO.DocumentID

	SELECT DISTINCT
		CustomerId,
		GSTFullDocID [SaleReturnId],   
		ReferenceNumber [InvoiceReference],
		[Type],
		MAX(ISNULL(NetValue, 0) + ISNULL(RoundOffAmount, 0)) NetValue  
	INTO #SR
	FROM V_ARC_SaleReturn_ItemDetails WITH (NOLOCK)
	GROUP BY  CustomerId, InvoiceDate, GSTFullDocID, ReferenceNumber, [Type]

	DELETE C FROM #CL C WITH (NOLOCK)
	JOIN #SR S WITH (NOLOCK) ON S.InvoiceReference = C.InvoiceReference AND ISNULL(C.CollectionAmount, 0) = ISNULL(S.NetValue, 0)

	SELECT 1, * FROM #CL WITH (NOLOCK)

	DROP TABLE #CL
	DROP TABLE #SR
END
GO
