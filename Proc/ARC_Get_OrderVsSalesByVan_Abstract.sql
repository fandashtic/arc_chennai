--Exec ARC_Get_OrderVsSalesByVan_Abstract '20-Jan-2020', '20-Jan-2020', '%'
--Exec ARC_Insert_ReportData 486, 'Order vs Sales By Van Consolidation', 1, 'ARC_Get_OrderVsSalesByVan_Abstract', 'Click to view Order vs Sales by Van Consolidation', 417, 34, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--select * from ReportData Where Node = 'Order vs Sales By Van'
--Exec ARC_GetUnusedReportId
Update ReportData Set GroupBy= '3', SubTotals = '4,5,6,7', SubTotalLabel='SubTotal:,GrandTotal:', NoSubTotals = null Where Node = 'Order vs Sales By Van Consolidation'
GO
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_OrderVsSalesByVan_Abstract')
BEGIN
    DROP PROC ARC_Get_OrderVsSalesByVan_Abstract
END
GO
CREATE Proc ARC_Get_OrderVsSalesByVan_Abstract(	
	@FromDate DateTime = null, 
	@ToDate DateTime = null, 
	@Van Nvarchar(255) = '%')  
AS BEGIN  

	Declare @VanList as Table (Van Nvarchar(255))

	If @Van = '%'
	Begin
		Insert Into @VanList Select Distinct Isnull(DocSerialType,'') From InvoiceAbstract WITH (NOLOCK) Where Isnull(DocSerialType,'') <> ''
	End
	Else
	Begin
		Insert Into @VanList Select Distinct Isnull(DocSerialType,'') From InvoiceAbstract WITH (NOLOCK) Where Isnull(DocSerialType,'') <> '' And Isnull(DocSerialType,'') Like @Van
	End

	Set @FromDate = Case When Isnull(@FromDate, '') = '' THEN (select TOP 1 OpeningDate from Setup WITH (NOLOCK)) ELSE @FromDate END
	Set @ToDate = Case When Isnull(@ToDate, '') = '' THEN GETDATE() ELSE @ToDate END

	PRINT @FromDate
	PRINT @Todate

	SELECT * INTO #InvoiceAbstract
	FROM InvoiceAbstract WITH (NOLOCK)		
	Where dbo.StripTimeFromDate(InvoiceDate) Between @FromDate And @ToDate
	AND DocSerialType in (Select Distinct Van From @VanList)

	 Select    	 
	  SA.SONumber,
	  SA.SODate [OrderDate],  
	  SA.Value [OrderValue],    	  
	  IA.DocSerialType [VanNumber],
	  IA.InvoiceID,
	  IA.InvoiceDate,  
	  IA.NetValue,
	  (select top 1 S.SalesmanCategoryName From V_ARC_Customer_Mapping S WITH (NOLOCK) WHERE S.SalesmanID = IA.SalesmanID) [Category]
	  INTO #Temp
	  FROM #InvoiceAbstract IA WITH (NOLOCK)	  	  
	  JOIN SOAbstract SA WITH (NOLOCK) ON IA.CustomerID = SA.CustomerID AND IA.SONumber = SA.SONumber	  	  
  
	 select Distinct 1, OrderDate, dbo.StripTimeFromDate(InvoiceDate) InvoiceDate, [VanNumber], [Category],
	 COUNT(SONumber) [No of Orders],
	 SUM([OrderValue]) [Order Value],
	 COUNT(InvoiceID) [No of Sales],
	 Sum(NetValue) [Sales Value] 
	 FROM #Temp  WITH (NOLOCK) GROUP BY OrderDate, dbo.StripTimeFromDate(InvoiceDate), [VanNumber], [Category]
	 Order By [VanNumber] , OrderDate,dbo.StripTimeFromDate(InvoiceDate) ASC 

	Drop Table #Temp	
	Drop Table #InvoiceAbstract
END   
GO
