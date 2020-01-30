--Exec ARC_Get_OrderVsInvoice '%', '13-Aug-2019', '13-Aug-2019'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_OrderVsInvoice')
BEGIN
    DROP PROC [ARC_Get_OrderVsInvoice]
END
GO
CREATE Proc ARC_Get_OrderVsInvoice(@CustomerName Nvarchar(255) = '%', @FromDate DateTime = '', @ToDate DateTime = '')
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


	Select
		1,
		--SA.SalesmanID,
		S.Salesman_Name,
		--SA.BeatId,
		B.Description,
		SA.CustomerID,
		C.Company_Name [Customer Name],
		SA.SONumber [Order Number],
		SA.SODate [Order Date],
		SA.Value [Order Value],		
		IA.GSTFullDocID [InvoiceId],			
		IA.InvoiceDate,
		IA.NetValue [Invoice value]
	from 
		SOAbstract SA WITH (NOLOCK)
		FULL OUTER JOIN Salesman S WITH (NOLOCK) ON S.SalesmanID = SA.SalesmanID
		FULL OUTER JOIN Beat B WITH (NOLOCK) ON B.BeatID = SA.BeatId
		FULL OUTER JOIN Customer C WITH (NOLOCK) ON C.CustomerID = SA.CustomerID
		FULL OUTER JOIN InvoiceAbstract IA WITH (NOLOCK) ON IA.CustomerID = SA.CustomerID AND IA.SONumber = SA.SONumber
		FULL OUTER JOIN InvoiceAbstract SR WITH (NOLOCK) ON SR.CustomerID = SA.CustomerID AND SR.SRInvoiceID = IA.InvoiceID
		FULL OUTER JOIN DeliveryDetails D  WITH (NOLOCK) ON D.CustomerID = IA.CustomerID AND D.InvoiceID = IA.InvoiceID
	WHERE SA.CustomerID = (CASE WHEN ISNUll(@CustomerId, '') <> '%' THEN @CustomerId ELSE SA.CustomerID END)
	AND dbo.StripTimeFromDate(SODate) Between @FromDate AND @ToDate
	Order By SA.SODate ASC
END 
GO
--Exec ARC_Insert_ReportData 287, 'Order Vs Invoice', 1, 'ARC_Get_OrderVsInvoice', 'View Order Vs Invoice By Customer', 151, 3, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
GO
Update ReportData Set Parameters = 3 Where ID = 287
GO
