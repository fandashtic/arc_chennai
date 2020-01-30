--Exec ARC_Get_OrderVsInvoiceVSDelivery 'SAI MAGESHWARI AGENCIES'
--Exec ARC_Get_OrderVsInvoiceVSDelivery '%'
--select NetValue, * from InvoiceAbstract Where GSTFullDocID = 'I/19-20/10501'
--select GSTFullDocID, Count(InvoiceID) from InvoiceAbstract Group by GSTFullDocID having Count(InvoiceID) > 2
--Exec ARC_Insert_ReportData 311, 'Order vs Invoice vs Delivery', 1, 'ARC_Get_OrderVsInvoiceVSDelivery', 'Click to view Order vs Invoice vs Delivery', 151, 40, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_OrderVsInvoiceVSDelivery')
BEGIN
    DROP PROC ARC_Get_OrderVsInvoiceVSDelivery
END
GO
CREATE Proc ARC_Get_OrderVsInvoiceVSDelivery(@CustomerName Nvarchar(255) = '%')  
AS BEGIN  
 DECLARE @CustomerId Nvarchar(255)  
 IF(ISNULL(@CustomerName, '') <> '%')  
 BEGIN  
  SELECT TOP 1 @CustomerId = CustomerId FROM Customer WITH (NOLOCK) WHERE Company_Name = @CustomerName  
 END  
 ELSE  
 BEGIN  
  SET @CustomerId =  '%'  
 END  
 
 PRINT @CustomerId
  
 Select    
  --SA.SalesmanID,  
  S.Salesman_Name [Salesman],  
  --SA.BeatId,  
  B.Description [Beat],  
  SA.CustomerID,  
  C.Company_Name [Customer Name],  
  SA.SONumber [Order Number],  
  SA.SODate [Order Date],  
  SA.Value [Order Value],    
  IA.GSTFullDocID [InvoiceId],
  IA.DocReference [Document id],
  IA.DocSerialType [Van Number],
  IA.InvoiceDate,  
  IA.NetValue [Before Delivery value]
  INTO #Temp
  FROM SOAbstract SA WITH (NOLOCK)  
  FULL OUTER JOIN Salesman S WITH (NOLOCK) ON S.SalesmanID = SA.SalesmanID  
  FULL OUTER JOIN Beat B WITH (NOLOCK) ON B.BeatID = SA.BeatId  
  FULL OUTER JOIN Customer C WITH (NOLOCK) ON C.CustomerID = SA.CustomerID  
  FULL OUTER JOIN InvoiceAbstract IA WITH (NOLOCK) ON IA.CustomerID = SA.CustomerID AND IA.SONumber = SA.SONumber    
  WHERE SA.CustomerID = (CASE WHEN ISNUll(@CustomerId, '') <> '%' THEN @CustomerId ELSE SA.CustomerID END)
  
	select IA.InvoiceID, IA.InvoiceDate, IA.NetValue, IA.GSTFullDocID,
	(SELECT MAX(InvoiceId) FROM InvoiceAbstract WITH (NOLOCK) WHERE CustomerID = CustomerID AND GSTFullDocID = IA.GSTFullDocID AND InvoiceType = 3) [Delivered_InvoiceId],
	(SELECT InvoiceDate FROM InvoiceAbstract WHERE  InvoiceId = (SELECT MAX(InvoiceId) FROM InvoiceAbstract WITH (NOLOCK) WHERE CustomerID = CustomerID AND GSTFullDocID = IA.GSTFullDocID AND InvoiceType = 3)) [Delivered_Date],
	(SELECT NetValue FROM InvoiceAbstract WHERE  InvoiceId = (SELECT MAX(InvoiceId) FROM InvoiceAbstract WITH (NOLOCK) WHERE CustomerID = CustomerID AND GSTFullDocID = IA.GSTFullDocID AND InvoiceType = 3)) [Delivered_Value]
	Into #Delivery
	from InvoiceAbstract IA WITH (NOLOCK) 
	JOIN #Temp T WITH (NOLOCK) On IA.GSTFullDocID = T.InvoiceId AND InvoiceType = 1

	SELECt 1, T.*,
	--D.Delivered_InvoiceId,
	ISNULL(D.Delivered_Date, T.InvoiceDate) [Delivered_Date],
	ISNULL(D.Delivered_Value, T.[Before Delivery value]) Delivered_Value,
	(CASE WHEN ISNULL(T.InvoiceId, '') <> '' THEN
	 (CASE WHEN ISNULL(T.[Order Value], 0) - ISNULL(ISNULL(D.Delivered_Value, T.[Before Delivery value]), 0) > 0 THEN ISNULL(T.[Order Value], 0) - ISNULL(ISNULL(D.Delivered_Value, T.[Before Delivery value]), 0) ELSE null END)
	 Else null END)
	 [Order Diffrence Value],
	(CASE WHEN ISNULL(T.[Before Delivery value], 0) - ISNULL(ISNULL(D.Delivered_Value, T.[Before Delivery value]), 0) > 0 THEN ISNULL(T.[Before Delivery value], 0) - ISNULL(ISNULL(D.Delivered_Value, T.[Before Delivery value]), 0) ELSE null END) [Invoice Diffrence Value]
	from #Temp T WITH (NOLOCK)
	FULL OUTER JOIN #Delivery D WITH (NOLOCK) ON T.InvoiceId = D.GSTFullDocID
	ORDER BY [Order Date], Salesman ASC

	Drop Table #Temp
	Drop Table #Delivery
END   
GO
