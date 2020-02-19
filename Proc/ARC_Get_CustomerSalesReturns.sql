--Exec ARC_Get_CustomerSalesReturns '2020-02-01 00:00:00','2020-02-19 23:59:59'
--Exec ARC_GetUnusedReportId
--Exec ARC_Insert_ReportData 476, 'Customer Sales Returns', 1, 'ARC_Get_CustomerSalesReturns', 'Click to view Customer Sales Returns', 53, 1, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_CustomerSalesReturns')
BEGIN
    DROP PROC [ARC_Get_CustomerSalesReturns]
END
GO
CREATE Proc ARC_Get_CustomerSalesReturns(@FromDate DateTime, @Todate DateTime)
AS 
BEGIN
	SET DATEFORMAT DMY
	SELECT Distinct 1, InvoiceDate, CustomerID
	,(select Top 1 Company_Name FROM Customer C WITH (NOLOCK) WHERE C.CustomerID = V.CustomerID) [CustomerName]
	,(select Top 1 Salesman_Name FROM Salesman S WITH (NOLOCK) WHERE S.SalesmanID = V.SalesmanID) Salesman
	,(select Top 1 Description FROM Beat B WITH (NOLOCK) WHERE B.BeatID = V.BeatID) Beat
	, V.GSTFullDocID [Sales Return Id]
	,Type [Return Type]
	, V.NetValue 
	from V_ARC_SaleReturn_ItemDetails V WITH (NOLOCK)
	Where dbo.StripDateFromTime(InvoiceDate) Between @FromDate And @Todate
	Order By InvoiceDate ASC
END
GO
