--Exec ARC_Get_OutstandingTrackingReport 'S.M.K.KRISHNA STORE(PML) -B'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_OutstandingTrackingReport')
BEGIN
    DROP PROC [ARC_Get_OutstandingTrackingReport]
END
GO
CREATE Proc ARC_Get_OutstandingTrackingReport(@CustomerName Nvarchar(255))
AS BEGIN
	DECLARE @CustomerId Nvarchar(255)
	SELECT TOP 1 @CustomerId = CustomerId FROM Customer WITH (NOLOCK) WHERE Company_Name = @CustomerName

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
		dbo.fn_Arc_GetPaymentType(IA.PaymentMode) PaymentMode,
		IA.InvoiceDate,
		IA.NetValue [Invoice value],
		D.Date [Delivery Date],
		D.Person,		
		SR.GSTFullDocID [SRInvoiceId],	
		SR.InvoiceDate [SR Date],
		SR.NetValue [SR Value],
		CN.NoteValue [Credit Note Value],
		CN.DocumentDate [Credit Note Date],
		CN.Memo [Reason],
		CD.PaymentDate [Collection Date],
		CD.AdjustedAmount [Collection Value]
	from 
		SOAbstract SA WITH (NOLOCK)
		FULL OUTER JOIN Salesman S WITH (NOLOCK) ON S.SalesmanID = SA.SalesmanID
		FULL OUTER JOIN Beat B WITH (NOLOCK) ON B.BeatID = SA.BeatId
		FULL OUTER JOIN Customer C WITH (NOLOCK) ON C.CustomerID = SA.CustomerID
		FULL OUTER JOIN InvoiceAbstract IA WITH (NOLOCK) ON IA.CustomerID = SA.CustomerID AND IA.SONumber = SA.SONumber
		FULL OUTER JOIN InvoiceAbstract SR WITH (NOLOCK) ON SR.CustomerID = SA.CustomerID AND SR.SRInvoiceID = IA.InvoiceID
		FULL OUTER JOIN DeliveryDetails D  WITH (NOLOCK) ON D.CustomerID = IA.CustomerID AND D.InvoiceID = IA.InvoiceID
		FULL OUTER JOIN CreditNote CN WITH (NOLOCK) ON CN.CustomerID = SA.CustomerID AND CN.Invocieid = IA.InvoiceID
		FULL OUTER JOIN 
			(select CD.OriginalID, CD.AdjustedAmount, CD.PaymentDate from CollectionDetail CD 
				JOIN Collections CA ON CD.CollectionID = CA.DocumentID AND CA.CustomerID = @CustomerId)
		CD ON  CD.OriginalID = IA.GSTFullDocID
	WHERE SA.CustomerID = @CustomerId
	Order By SA.SODate ASC
END 
GO
