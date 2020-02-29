--Exec SP_ARC_GetAllSales
--Exec ARC_Insert_ReportData 539, 'All Sales', 1, 'SP_ARC_GetAllSales', 'Click to view All Sales', 376, 0, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_GetAllSales')
BEGIN
    DROP PROC SP_ARC_GetAllSales
END
GO
Create Proc SP_ARC_GetAllSales  
AS  
BEGIN 
	SELECT DISTINCT
		S.InvoiceID [ID] ,
		S.GSTFullDocID [InvoiceId],
		S.InvoiceDate,
		S.CustomerId,
		(SELECT TOP 1 Company_Name FROM Customer WITH (NOLOCK) WHERE CustomerID = S.CustomerId) [CustomerName], 
		S.SalesmanID,
		(SELECT TOP 1 Salesman_Name FROM Salesman WITH (NOLOCK) WHERE SalesmanID = S.SalesmanID) [SalesmanName],
		S.BeatID,
		(SELECT TOP 1 Description FROM Beat WITH (NOLOCK) WHERE BeatID = S.BeatID) [BeatName],
		ISNULL(S.NetValue, 0) + ISNULL(S.RoundOffAmount, 0) NetValue
		--,SUM(S.TaxableValue) TaxableValue
	FROM 
	V_ARC_Sale_ItemDetails S WITH (NOLOCK) 
	--GROUP BY 
	--	S.InvoiceID,
	--	S.GSTFullDocID,
	--	S.InvoiceDate,
	--	S.CustomerId,
	--	S.SalesmanID,
	--	S.BeatID,
	--	S.NetValue
	ORDER BY S.InvoiceID
END
GO
