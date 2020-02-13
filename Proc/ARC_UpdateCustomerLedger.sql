--Exec ARC_UpdateCustomerLedger '01-Feb-2019'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_UpdateCustomerLedger')
BEGIN
    DROP PROC ARC_UpdateCustomerLedger
END
GO
Create Proc ARC_UpdateCustomerLedger(@TransactionDate DATETIME)
AS
BEGIN
	SET DATEFORMAT DMY

	Create Table #Ledger
	(
		ID int Identity(1,1),
		CustomerId Nvarchar(255),
		TransactionDate DateTime,
		TransactionType Nvarchar(255),
		TransactionId Nvarchar(255),
		SalesmanID INT,
		BeatID INT,
		Debit Decimal(18,6) Default 0,
		Credit Decimal(18,6) Default 0,
		InvoiceReference Nvarchar(255),
		Remarks Nvarchar(4000)
	)

	Insert into #Ledger(CustomerId, TransactionDate, TransactionType, TransactionId, SalesmanID, BeatID,  Debit, Credit, Remarks)
	SELECT DISTINCT	
		CustomerId,		
		InvoiceDate,
		'Sales',
		GSTFullDocID [InvoiceId],		
		SalesmanID,
		BeatID,
		0,
		NetValue,
		''
	FROM 
	V_ARC_Sale_ItemDetails WITH (NOLOCK) 
	WHERE dbo.StripDateFromTime(InvoiceDate) >= dbo.StripDateFromTime(@TransactionDate)


	Insert into #Ledger(CustomerId, TransactionDate, TransactionType, TransactionId, SalesmanID, BeatID,  Debit, Credit, InvoiceReference, Remarks)
	SELECT DISTINCT
		CustomerId,
		InvoiceDate SaleReturnDate,
		'SaleReturn',
		GSTFullDocID [SaleReturnId], 
		SalesmanID,
		BeatID,
		NetValue,
		0,
		ReferenceNumber [InvoiceReference],
		''
	FROM 
	V_ARC_SaleReturn_ItemDetails WITH (NOLOCK)
	WHERE dbo.StripDateFromTime(InvoiceDate) >= dbo.StripDateFromTime(@TransactionDate)


	Insert into #Ledger(CustomerId, TransactionDate, TransactionType, TransactionId, SalesmanID, BeatID,  Debit, Credit, InvoiceReference, Remarks)
	SELECT DISTINCT
		CustomerId,
		DocumentDate CreditnoteDate,
		'Creditnote',
		DocumentReference [CreditnoteId],		
		SalesmanID,
		0,
		NoteValue NetValue,
		0,
		DocRef [ReferenceId],		
		Memo		
	FROM 
	V_ARC_Creditnote WITH (NOLOCK) 
	WHERE dbo.StripDateFromTime(DocumentDate) >= dbo.StripDateFromTime(@TransactionDate)

	Insert into #Ledger(CustomerId, TransactionDate, TransactionType, TransactionId, SalesmanID, BeatID,  Debit, Credit, InvoiceReference, Remarks)
	SELECT DISTINCT
		CustomerId,
		DocumentDate DebitNoteDate,
		'DebitNote',
		DocumentReference [DebitNoteId],		
		SalesmanID,
		0,
		0,
		NoteValue NetValue,				
		DocRef [ReferenceId],
		Memo
	FROM 
	V_ARC_DebitNote WITH (NOLOCK)
	WHERE ISNULL(CustomerId, '') <> ''
	AND dbo.StripDateFromTime(DocumentDate) >= dbo.StripDateFromTime(@TransactionDate)

	Insert into #Ledger(CustomerId, TransactionDate, TransactionType, TransactionId, SalesmanID, BeatID,  Debit, Credit, InvoiceReference, Remarks)
	SELECT DISTINCT
		CustomerId,
		CollectionDate,
		'Collections',
		CollectionId, 
		SalesmanID,
		BeatID,		
		CollectionAmount,
		0,
		InvoiceReference,
		''
		FROM V_ARC_Collections WITH (NOLOCK) 
		WHERE dbo.StripDateFromTime(CollectionDate) >= dbo.StripDateFromTime(@TransactionDate)

	DELETE X FROM #Ledger X WITH (NOLOCK) Where X.TransactionType = 'Creditnote' 
	and ID in (select Distinct ID FROM #Ledger WITH (NOLOCK) WHERE InvoiceReference 
	in (select distinct InvoiceReference from #Ledger WITH (NOLOCK) WHERE TransactionType = 'Creditnote'))	
	
	DELETE X FROM CustomerLedger X WITH (NOLOCK) WHERE dbo.StripDateFromTime(X.TransactionDate) >= dbo.StripDateFromTime(@TransactionDate)

	INSERT INTO CustomerLedger(
			CustomerId,
			TransactionDate,
			TransactionType,
			TransactionId,
			SalesmanID,
			BeatID,
			Debit,
			Credit,
			InvoiceReference,
			Remarks)
	SELECT 
		CustomerId,
		TransactionDate,
		TransactionType,
		TransactionId,
		SalesmanID,
		BeatID,
		Debit,
		Credit,
		InvoiceReference,
		Remarks
	FROM #Ledger
	--Where CustomerId = 'ARCSWD60'
	ORDER BY TransactionDate, TransactionType ASC

	DROP TABLE #Ledger	
END
GO


