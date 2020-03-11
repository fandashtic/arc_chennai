--SELECT * FROM V_ARC_Collections WITH (NOLOCK)  ORDER BY [CollectionDate]
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Collections')
BEGIN
    DROP VIEW V_ARC_Collections
END
GO
Create View V_ARC_Collections
AS
Select DISTINCT
	C.DocumentID,
	C.DocumentDate [CollectionDate], 
	C.CustomerId, 
	C.SalesmanID, 
	C.BeatID, 
	C.DocumentReference [CollectionId], 
	C.Value [TotalCollection],
	C.Balance,
	CD.AdjustedAmount [CollectionAmount], 
	CD.OriginalID [InvoiceReference],
	C.Paymentmode, 
	C.ChequeDate, 
	C.ChequeNumber, 
	C.ChequeDetails,
	C.DepositDate, 
	C.BankCode, 
	C.BranchCode, 
	C.ClearingAmount, 
	C.UserName,
	CCD.ChqStatus Realised, 
	CCD.RealiseDate, 
	C.BankCharges,
	CD.ExtraCollection, 
	CD.Adjustment
From   
	Collections C WITH (NOLOCK)
	FULL OUTER JOIN CollectionDetail CD WITH (NOLOCK) ON C.DocumentID = CD.CollectionID   
	FULL OUTER JOIN ChequeCollDetails CCD WITH (NOLOCK) ON CCD.CollectionID = CD.CollectionID
	WHERE (ISNULL(CD.OriginalID, '') NOT LIKE 'SR/%' AND ISNULL(CD.OriginalID, '') NOT LIKE 'CR%' AND ISNULL(CD.OriginalID, '') NOT LIKE 'CL%')
	--And Isnull(C.paymentmode,0)=1               
	--And C.DocumentID = CD.CollectionID                   
	And 
	isnull(C.Status,0) & 192 = 0 
GO