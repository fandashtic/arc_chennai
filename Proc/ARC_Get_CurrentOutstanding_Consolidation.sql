--exec ARC_Get_CurrentOutstanding_Consolidation 'AKASH.S.K-7010195569','%'
--exec ARC_Get_CurrentOutstanding_Consolidation 'AKASH.S.K-7010195569','301 -HPM -TUE'
--exec ARC_Get_CurrentOutstanding_Consolidation '%','301 -HPM -TUE'
--exec ARC_Get_CurrentOutstanding_Consolidation '%','%'
--PreRequest SalesmanCategory, V_ARC_Customer_Mapping, fn_ARC_CustomerOutstandingDetails
--Exec ARC_GetUnusedReportId
--Exec ARC_Insert_ReportData 475, 'Current Outstanding Consolidation', 1, 'ARC_Get_CurrentOutstanding_Consolidation', 'Click to view Current Outstanding Consolidation', 53, 98, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--IF NOT EXISTS(SELECT * FROM ParameterInfo WHERE ParameterID = 98)
--BEGIN
--    INSERT INTO ParameterInfo(ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,OrderBy,DynamicParamID)
--	SELECT 98,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,OrderBy,DynamicParamID
--	FROM ParameterInfo D WITH (NOLOCK) WHERE ParameterID = 20 AND ParameterName in('Salesman', 'Beat') Order By ParameterName DESC
--END
--GO
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_CurrentOutstanding_Consolidation')
BEGIN
    DROP PROC [ARC_Get_CurrentOutstanding_Consolidation]
END
GO
CREATE Proc ARC_Get_CurrentOutstanding_Consolidation(@Salesman Nvarchar(255) = '%', @Beat Nvarchar(255) = '%')
AS 
BEGIN
	Declare @CustomerIDs AS Table (Id int Identity(1,1), CustomerID Nvarchar(255), SalesManID Int, BeatId Int)
	Declare @CustomerIdsFinal AS Table (Id int Identity(1,1), CustomerID Nvarchar(255), SalesManID Int, BeatId Int)
	Declare @Salesmans AS Table (SalesmanId INT)
	Declare @Beats AS Table (BeatID INT)


	IF(ISNULL(@Salesman, '') = '%' AND ISNULL(@Beat, '') = '%')
	BEGIN
		Insert into @CustomerIdsFinal(CustomerID, SalesManID, BeatId)
		select DISTINCT CustomerID, SalesManID, BeatId
		FROM InvoiceAbstract B WITH (NOLOCK)
	END
	ELSE
	BEGIN
		IF(ISNULL(@Salesman, '') <> '%')
		BEGIN
			INSERT INTO @Salesmans SELECT DISTINCT SalesmanID FROM Salesman WITH (NOLOCK) WHERE Salesman_Name IN (SELECT * FROM dbo.sp_SplitIn2Rows(@Salesman, ','))
		END
		ELSE
		BEGIN
			INSERT INTO @Salesmans SELECT DISTINCT SalesmanID FROM Salesman WITH (NOLOCK)
		END	

		Insert into @CustomerIDs(CustomerID, SalesManID, BeatId)
		select DISTINCT CustomerId,SalesManID, BeatId 
		FROM InvoiceAbstract B WITH (NOLOCK)
		WHERE SalesmanId IN (SELECT DISTINCT SalesmanId FROM @Salesmans)
	
		IF(ISNULL(@Beat, '') <> '%')
		BEGIN
			INSERT INTO @Beats SELECT DISTINCT BeatID FROM Beat WITH (NOLOCK) WHERE Description IN (SELECT * FROM dbo.sp_SplitIn2Rows(@Beat, ','))
		END

		Insert into @CustomerIDs(CustomerID, SalesManID, BeatId)
		select DISTINCT CustomerId,SalesManID, BeatId 
		FROM InvoiceAbstract V WITH (NOLOCK)	
		WHERE BeatID IN (SELECT DISTINCT BeatID FROM @Beats)	
		AND CustomerID NOT IN (SELECT DISTINCT CustomerID FROM @CustomerIDs)

		IF EXISTS(SELECT TOP 1 1 FROM @Beats)
		BEGIN
			INSERT INTO @CustomerIdsFinal(CustomerID, SalesManID, BeatId)
			SELECT DISTINCT CustomerID, SalesManID, BeatId FROM @CustomerIDs WHERE BeatID IN (SELECT DISTINCT BeatID FROM @Beats)
		END
		ELSE 
		BEGIN
			INSERT INTO @CustomerIdsFinal(CustomerID, SalesManID, BeatId) SELECT DISTINCT CustomerID, SalesManID, BeatId FROM @CustomerIDs
		END
	END

	CREATE TABLE #TempTable(
			SalesManID int,
			SalesMan nvarchar(500) NULL,
			SalesmanCategory Nvarchar(100),
			BeatID INT,
			Beat nvarchar(500) NULL,			
			CustomerName nvarchar(255) NULL,		
			CustomerId nvarchar(255) NULL,		
			DocumentID nvarchar(255) NULL,
			DocumentDate datetime NULL,
			Netvalue decimal(18, 6) NULL,
			Balance decimal(18, 6) NULL,
			InvoiceID int NULL,
			Type int NULL,
			Remarks nvarchar(500) NULL,
			AdditionalDiscount decimal(18, 6) NULL,
			DocSerialType nvarchar(500) NULL,
			DisableEdit int NULL,
			ChequeNumber NVARCHAR(255) NULL, 
			ChequeDate DATETIME NULL,
			ChequeOnHand decimal(18, 6) NULL
		)

	Declare @I as Int
	SET @I = 1
	Declare @CustomerID AS NVARCHAR(255)
	Declare @SalesManID INT
	Declare @BeatId INT

	WHILE(@I < (SELECT Max(ID) From @CustomerIdsFinal))
	BEGIN

		SELECT @CustomerID = CustomerID, @SalesManID = SalesManID, @BeatId = BeatId FROM @CustomerIdsFinal WHERE Id = @I
		Insert into #TempTable
		select
		O.SalesmanID,
		(select top 1 S.Salesman_Name From V_ARC_Customer_Mapping S WITH (NOLOCK) WHERE S.SalesmanID = O.SalesmanID),
		(select top 1 S.SalesmanCategoryName From V_ARC_Customer_Mapping S WITH (NOLOCK) WHERE S.SalesmanID = O.SalesmanID),
		O.BeatID,
		(select top 1 B.Beat From V_ARC_Customer_Mapping B WITH (NOLOCK) WHERE B.BeatID = O.BeatID),
		(select top 1 C.CustomerName From V_ARC_Customer_Mapping C WITH (NOLOCK) WHERE C.CustomerId = O.CustomerId),
		O.CustomerId,
		[Document ID],
		DocumentDate,
		Netvalue,
		Balance,
		InvoiceID,
		Type,
		[Desc],
		AdditionalDiscount,
		DocSerialType,
		DisableEdit,
		ChequeNumber,
		ChequeDate,
		ChequeOnHand
		from dbo.fn_ARC_CustomerOutstandingDetails(@CustomerId, @SalesManID ,@BeatId) O 
		Where (Isnull(Balance, 0) > 0 OR ISNULL(ChequeOnHand, 0) > 0)

		SET @I = @I + 1
	END

	select SalesManID,
	SalesMan,
	SalesmanCategory,
	BeatID,
	Beat,
	CustomerId,
	CustomerName,	
	DocumentID,
	DocumentDate,
	Netvalue,
	Balance,
	InvoiceID,
	DocSerialType,	
	ChequeNumber,
	ChequeDate,
	ChequeOnHand,	
	Case [Type] WHEN 4 THEN DATEDIFF(d, DocumentDate, Getdate()) ELSE NULL END [Due Days]
	INTO #Temp
	from #TempTable WITH (NOLOCK)

	select 1, SalesMan [Sales Made By SalesMan], Beat [Sales Made By Beat], CustomerName, SalesmanCategory [Bill Category], SUM(Balance) [Net Outstanding], Count(InvoiceID) [No of Bills], Max([Due Days]) [Max Due Days]
	FROM #Temp
	Where [Due Days] > 0
	GROUP BY SalesMan, Beat, CustomerName, SalesmanCategory
	Order By CustomerName ASC

	Drop Table #TempTable
END
GO
