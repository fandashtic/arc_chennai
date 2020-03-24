--exec SP_ARC_Sales_CGST_NONCGST '2020-02-04 00:00:00.000', '2020-02-04 23:59:59.000', '%'
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

	SELECT
	S.CustomerID,
	(select Top 1 CustomerName from V_ARC_Customer_Mapping WITH (NOLOCK) Where CustomerID = S.CustomerID) [CustomerName],
	CASE (select Top 1 ISNULL(GSTIN , '') from V_ARC_Customer_Mapping WITH (NOLOCK) Where CustomerID = S.CustomerID) WHEN '' THEN 'Non-GST' ELSE 'GST' END [CustomerType],
	S.GSTFullDocID [InvoiceId],
	S.InvoiceDate,
	S.Product_Code, 
	I.ProductName, 
	I.ItemFamily,
	S.Batch_Code, 
	S.Quantity, 	
	I.PTR [Retail Price],
	ISNULL((select TOP 1 isnull(C.ChannelPTR, 0) from BatchWiseChannelPTR C WITH (NOLOCK) where C.Batch_Code = I.Batch_Code and RegisterStatus = 1), 0) [WholeSale Price],
	--Case When 
	--	ISNULL((select TOP 1 isnull(C.ChannelPTR, 0) from BatchWiseChannelPTR C WITH (NOLOCK) where C.Batch_Code = I.Batch_Code and RegisterStatus = 1), 0) = 0 Then I.PTR Else 
	--	ISNULL((select TOP 1 isnull(C.ChannelPTR, 0) from BatchWiseChannelPTR C WITH (NOLOCK) where C.Batch_Code = I.Batch_Code and RegisterStatus = 1), 0)
	--End	  [Original SalePrice], 
	S.SalePrice [Invoice SalePrice]--,
	--(S.Quantity * 
	--	ISNULL((select TOP 1 isnull(C.ChannelPTR, 0) from BatchWiseChannelPTR C WITH (NOLOCK) where C.Batch_Code = I.Batch_Code and RegisterStatus = 1), 0)
	--) [Expected Sales] ,
	--(S.Quantity * S.SalePrice) [Actual Sales], 
	--(S.Quantity * I.PTR) - (S.Quantity * S.SalePrice) [Diffent Amount]
	INTO #Temp
	from V_ARC_Sale_ItemDetails S WITH (NOLOCK)
	JOIN V_ARC_Items_BatchDetails I  WITH (NOLOCK) ON I.Product_Code = S.Product_Code AND I.Batch_Code = S.Batch_Code
	WHERE dbo.StripDateFromTime(S.InvoiceDate) BETWEEN @FromDate AND @ToDate
	AND I.ItemFamily = (Case When @ItemFamily = '%' THEN I.ItemFamily ELSE @ItemFamily END)
	--AND I.Product_Code = '997'

	SELECT 1, 
	CustomerID,	
	CustomerName,	
	CustomerType,	
	InvoiceId,	
	InvoiceDate,	
	Product_Code,	
	ProductName,	
	ItemFamily,	
	Batch_Code,	
	Quantity,	
	[Retail Price],	
	CASE WHEN ISNULL([WholeSale Price], 0) = 0 THEN [Retail Price] ELSE [WholeSale Price] END [WholeSale Price],		
	[Invoice SalePrice],	
	(Quantity * [Retail Price]) [Expected Sales By Retail] ,
	(Quantity * (CASE WHEN ISNULL([WholeSale Price], 0) = 0 THEN [Retail Price] ELSE [WholeSale Price] END)) [Expected Sales By WholeSale] ,
	(Quantity * [Invoice SalePrice]) [Actual Sales], 
	(Quantity * [Retail Price]) - (Quantity * [Invoice SalePrice]) [Diffent By Retail],
	(Quantity * (CASE WHEN ISNULL([WholeSale Price], 0) = 0 THEN [Retail Price] ELSE [WholeSale Price] END)) - (Quantity * [Invoice SalePrice]) [Different By WholeSale]
	FROM #Temp WITH (NOLOCK)

	Order By InvoiceID ASC
END
GO
