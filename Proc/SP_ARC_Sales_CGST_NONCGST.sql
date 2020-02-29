--exec SP_ARC_Sales_CGST_NONCGST '2020-02-20 00:00:00','2020-02-20 23:59:59', '%'
--Exec ARC_Insert_ReportData 558, 'Sales CGST NON-CGST', 1, 'SP_ARC_Sales_CGST_NONCGST', 'Click to view Sales CGST NON-CGST', 53, 641, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_Sales_CGST_NONCGST')
BEGIN
    DROP PROC SP_ARC_Sales_CGST_NONCGST
END
GO
CREATE PROCEDURE [dbo].SP_ARC_Sales_CGST_NONCGST (@FromDate DateTime, @ToDate DateTime, @ItemFamily Nvarchar(255) = '%')      
AS
BEGIN
	SET DATEFORMAT DMY

	SELECT 1,
	S.CustomerID,
	(select Top 1 CustomerName from V_ARC_Customer_Mapping WITH (NOLOCK) Where CustomerID = S.CustomerID) [CustomerName],
	CASE (select Top 1 ISNULL(GSTIN , '') from V_ARC_Customer_Mapping WITH (NOLOCK) Where CustomerID = S.CustomerID) WHEN '' THEN 'Non-GST' ELSE 'GST' END [CustomerType],
	S.GSTFullDocID [InvoiceId],
	S.InvoiceDate,
	S.Product_Code, 
	I.ProductName, 
	I.ItemFamily,
	S.Batch_Code, S.Quantity, 
	I.PTR [Original SalePrice], 
	S.SalePrice [Invoice SalePrice],
	(S.Quantity * I.PTR) [Expected Sales] ,
	(S.Quantity * S.SalePrice) [Actual Sales], 
	(S.Quantity * I.PTR) - (S.Quantity * S.SalePrice) [Diffent Amount]
	from V_ARC_Sale_ItemDetails S WITH (NOLOCK)
	JOIN V_ARC_Items_BatchDetails I  WITH (NOLOCK) ON I.Product_Code = S.Product_Code AND I.Batch_Code = S.Batch_Code
	WHERE dbo.StripDateFromTime(S.InvoiceDate) BETWEEN @FromDate AND @ToDate
	AND I.ItemFamily = (Case When @ItemFamily = '%' THEN I.ItemFamily ELSE @ItemFamily END)
	Order By S.InvoiceID ASC
END
GO
