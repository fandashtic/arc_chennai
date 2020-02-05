--Exec ARC_Get_OrderVsSalesByVan '20-Jan-2020', '20-Jan-2020', '%'
--Exec ARC_Insert_ReportData 396, 'Order vs Sales By Van', 1, 'ARC_Get_OrderVsSalesByVan', 'Click to view Order vs Sales by Van', 417, 34, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_OrderVsSalesByVan')
BEGIN
    DROP PROC ARC_Get_OrderVsSalesByVan
END
GO
CREATE Proc ARC_Get_OrderVsSalesByVan(	
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

	--select * from #InvoiceAbstract

	 Select    	  
	  --S.Salesman_Name [Salesman],  	  
	  --B.Description [Beat],  
	  --SA.CustomerID,  
	  C.Company_Name [Customer Name],  
	  SA.SONumber [Order Number],  
	  SA.SODate [Order Date],  
	  SA.Value [Order Value],    
	  IA.GSTFullDocID [InvoiceId],
	  --IA.DocReference [Document id],	  
	  IA.InvoiceDate,  
	  IA.DocSerialType [Van Number],
	  (select top 1 S.SalesmanCategoryName From V_ARC_Customer_Mapping S WITH (NOLOCK) WHERE S.SalesmanID = IA.SalesmanID) [Category],
	  IA.NetValue [Before Delivery Value]
	  INTO #Temp
	  FROM #InvoiceAbstract IA WITH (NOLOCK)	  	  
	  JOIN SOAbstract SA WITH (NOLOCK) ON IA.CustomerID = SA.CustomerID AND IA.SONumber = SA.SONumber    
	  JOIN Salesman S WITH (NOLOCK) ON S.SalesmanID = SA.SalesmanID  
	  JOIN Beat B WITH (NOLOCK) ON B.BeatID = SA.BeatId  
	  JOIN Customer C WITH (NOLOCK) ON C.CustomerID = SA.CustomerID  	  
  
  --select * from #Temp

	select IA.InvoiceID, IA.InvoiceDate, IA.NetValue, IA.GSTFullDocID,
	(SELECT MAX(InvoiceId) FROM #InvoiceAbstract WITH (NOLOCK) WHERE CustomerID = CustomerID AND GSTFullDocID = IA.GSTFullDocID AND InvoiceType = 3) [Delivered_InvoiceId],
	(SELECT InvoiceDate FROM #InvoiceAbstract WHERE  InvoiceId = (SELECT MAX(InvoiceId) FROM #InvoiceAbstract WITH (NOLOCK) WHERE CustomerID = CustomerID AND GSTFullDocID = IA.GSTFullDocID AND InvoiceType = 3)) [Delivered_Date],
	(SELECT NetValue FROM #InvoiceAbstract WHERE  InvoiceId = (SELECT MAX(InvoiceId) FROM #InvoiceAbstract WITH (NOLOCK) WHERE CustomerID = CustomerID AND GSTFullDocID = IA.GSTFullDocID AND InvoiceType = 3)) [Delivered_Value]
	Into #Delivery
	from #InvoiceAbstract IA WITH (NOLOCK) 
	JOIN #Temp T WITH (NOLOCK) On IA.GSTFullDocID = T.InvoiceId AND InvoiceType = 1

	SELECt 1, T.*,
	--D.Delivered_InvoiceId,
	ISNULL(D.Delivered_Date, T.InvoiceDate) [Delivered_Date],
	ISNULL(D.Delivered_Value, T.[Before Delivery Value]) Delivered_Value
	--,(CASE WHEN ISNULL(T.InvoiceId, '') <> '' THEN
	-- (CASE WHEN ISNULL(T.[Order Value], 0) - ISNULL(ISNULL(D.Delivered_Value, T.[Before Delivery value]), 0) > 0 THEN ISNULL(T.[Order Value], 0) - ISNULL(ISNULL(D.Delivered_Value, T.[Before Delivery value]), 0) ELSE null END)
	-- Else null END)
	-- [Order Diffrence Value],
	--(CASE WHEN ISNULL(T.[Before Delivery value], 0) - ISNULL(ISNULL(D.Delivered_Value, T.[Before Delivery value]), 0) > 0 THEN ISNULL(T.[Before Delivery value], 0) - ISNULL(ISNULL(D.Delivered_Value, T.[Before Delivery value]), 0) ELSE null END) [Invoice Diffrence Value]
	from #Temp T WITH (NOLOCK)
	FULL OUTER JOIN #Delivery D WITH (NOLOCK) ON T.InvoiceId = D.GSTFullDocID
	ORDER BY [Order Date] ASC

	Drop Table #Temp
	Drop Table #Delivery
	Drop Table #InvoiceAbstract
END   
GO
