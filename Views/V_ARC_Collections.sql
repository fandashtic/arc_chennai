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
	--CD.AdjustedAmount [Direct Collection Amount], 
	(Case When (ISNULL(CD.OriginalID, '') NOT LIKE 'SR%' AND ISNULL(CD.OriginalID, '') NOT LIKE 'CL%' AND ISNULL(CD.OriginalID, '') NOT LIKE 'CR%') THEN CD.AdjustedAmount ELSE 0 END)
	- ((Case When ISNULL(CD.OriginalID, '') LIKE 'CL%' THEN CD.AdjustedAmount ELSE 0 END) + 
	   (Case When ISNULL(CD.OriginalID, '') LIKE 'SR%' THEN CD.AdjustedAmount ELSE 0 END) + 
	   (Case When ISNULL(CD.OriginalID, '') LIKE 'CR%' THEN CD.AdjustedAmount ELSE 0 END))	CollectionAmount,

	Case When ISNULL(CD.OriginalID, '') LIKE 'CL%' THEN CD.AdjustedAmount ELSE 0 END [Adjusted From Past Colllection],
	Case When ISNULL(CD.OriginalID, '') LIKE 'SR%' THEN CD.AdjustedAmount ELSE 0 END [Adjusted From SaleReturn],
	Case When ISNULL(CD.OriginalID, '') LIKE 'CR%' THEN CD.AdjustedAmount ELSE 0 END [Adjusted From CreditNote],
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
	WHERE (IsNull(C.Status,0) & 128) = 0 
	AND (IsNull(C.Status,0) & 64) = 0
	AND C.CustomerID is Not Null      
	--And C.Value > 0 
GO