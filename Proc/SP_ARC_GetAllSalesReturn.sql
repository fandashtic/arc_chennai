--Exec SP_ARC_GetAllSalesReturn
--Exec ARC_Insert_ReportData 540, 'All Sales Return', 1, 'SP_ARC_GetAllSalesReturn', 'Click to view All Sales Return', 376, 0, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_GetAllSalesReturn')
BEGIN
    DROP PROC SP_ARC_GetAllSalesReturn
END
GO
Create Proc SP_ARC_GetAllSalesReturn  
AS  
BEGIN 
	SELECT DISTINCT
		S.InvoiceID [ID] ,
		S.GSTFullDocID [SaleReturnId],
		S.InvoiceDate SaleReturnDate,
		S.CustomerId,
		(SELECT TOP 1 Company_Name FROM Customer WITH (NOLOCK) WHERE CustomerID = S.CustomerId) [CustomerName], 
		S.SalesmanID,
		(SELECT TOP 1 Salesman_Name FROM Salesman WITH (NOLOCK) WHERE SalesmanID = S.SalesmanID) [SalesmanName],
		S.BeatID,
		(SELECT TOP 1 Description FROM Beat WITH (NOLOCK) WHERE BeatID = S.BeatID) [BeatName],
		S.[Type],
		ISNULL(S.NetValue, 0) + ISNULL(S.RoundOffAmount, 0) NetValue,
		S.ReferenceNumber [InvoiceReference]
	FROM 
	V_ARC_SaleReturn_ItemDetails S WITH (NOLOCK) 
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
