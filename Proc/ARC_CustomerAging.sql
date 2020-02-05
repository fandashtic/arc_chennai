--Exec ARC_CustomerAging
--Exec ARC_GetUnusedReportId
--Exec ARC_Insert_ReportData 419, 'Customer Aging', 1, 'ARC_CustomerAging', 'Click to view Customer Aging', 399, 0, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_CustomerAging')
BEGIN
  DROP PROC [ARC_CustomerAging]
END
GO
CREATE procedure [dbo].[ARC_CustomerAging]
AS       
BEGIN
	select C.CustomerId, C.Company_Name [Customer Name], C.BillingAddress, C.ShippingAddress, C.Phone, ISNULL(C.GSTIN, '') [GST Number],  C.CreationDate [Date of Join]
	,(Select Top 1 InvoiceDate From InvoiceAbstract WITH (NOLOCK) WHERe CustomerID = C.CustomerID AND InvoiceType in (1,3) AND (Status & 128) = 0 ORDER BY InvoiceID Desc) [Last Sales]
	, (Select Top 1 InvoiceDate From InvoiceAbstract WITH (NOLOCK) WHERe CustomerID = C.CustomerID AND InvoiceType in (4) ORDER BY InvoiceID Desc) [Last SalesReturn]
	Into #Customer
	from Customer C WITH (NOLOCK)
	Where C.CustomerId NOT IN('0', 'CNTRW0001', 'CNTTW0001', 'ITC001Outlet')

	Select 1,
	S.Salesman_Name, S.Description [Beat],
	C.*
	, DATEDIFF(d, ISNULL((CASE WHEN C.[Last Sales] > C.[Last SalesReturn] THEN C.[Last SalesReturn] ELSE C.[Last Sales] END), C.[Date of Join]), Getdate()) [Un Used Days]
	From #Customer C WITH (NOLOCK)
	JOIN (SELECT DISTINCT S.SalesmanID, S.Salesman_Name, B.BeatID, B.Description, BS.CustomerID 
	FROM Salesman S WITH (NOLOCK) 
	JOIN Beat_Salesman BS WITH (NOLOCK) ON BS.SalesmanID = S.SalesmanID
	JOIN Beat B WITH (NOLOCK) On B.BeatID = BS.BeatID) S ON S.CustomerID = C.CustomerID

	Order By [Un Used Days] Desc

	DROP TABLE #Customer
END
GO
