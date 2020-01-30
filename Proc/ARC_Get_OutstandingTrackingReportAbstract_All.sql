--Exec ARC_Get_OutstandingTrackingReportAbstract 'S.M.K.KRISHNA STORE(PML) -B'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_OutstandingTrackingReportAbstract')
BEGIN
    DROP PROC [ARC_Get_OutstandingTrackingReportAbstract]
END
GO
CREATE Proc ARC_Get_OutstandingTrackingReportAbstract(@CustomerName Nvarchar(255))
AS BEGIN
	DECLARE @CustomerId Nvarchar(255)
	SELECT TOP 1 @CustomerId = CustomerId FROM Customer WITH (NOLOCK) WHERE Company_Name = @CustomerName

	Declare @SQL AS NVARCHAR(MAX);
	SET @SQL = 'CREATE TABLE #TEMP([Salesman Name] NVARCHAR(255)'
	SET @SQL = @SQL + ',[Beat] NVARCHAR(255)'
	SET @SQL = @SQL + ',[CustomerID] NVARCHAR(255)'
	SET @SQL = @SQL + ',[Customer Name] NVARCHAR(255)'

	DECLARE @Orders AS TABLE (ID INT IDENTITY(1,1), SONumber INT, SODate DATETIME, CustomerID NVARCHAR(255), [Value] DECIMAL(18,6), GroupID NVARCHAR(255))
	INSERT INTO @Orders (SONumber, SODate, CustomerID, [Value], GroupID)
	SELECT SONumber, SODate, CustomerID, [Value], GroupID  FROM SOAbstract with (NOLOCK) WHERE CustomerID = @CustomerId
	ORDER BY SODate ASC

	DECLARE @SID INT 
	SET @SID = 1
	DECLARE @SONumber NVARCHAR(255)
	DECLARE @SODATE NVARCHAR(12)

	WHILE(@SID <= (SELECT MAX(ID) FROM @Orders))
	BEGIN
		SELECT @SONumber = CAST(SONumber AS VARCHAR), @SODATE = REPLACE(CONVERT(NVARCHAR(25),SODate, 106), ' ', '-') FROM @Orders WHERE ID = @SID AND CustomerID = @CustomerId
		SET @SQL = @SQL + ',[O_'+ @SONumber + '_' + @SODATE +'] DECIMAL(18,6)'
		SET @SID = @SID + 1
	END

	DECLARE @SALES AS TABLE (ID INT IDENTITY(1,1), InvoiceId NVARCHAR(255), InvoiceDate DATETIME, CustomerID NVARCHAR(255), [Value] DECIMAL(18,6))
	INSERT INTO @SALES (InvoiceId, InvoiceDate, CustomerID, [Value])
	SELECT DISTINCT InvoiceId, InvoiceDate, CustomerID, NetValue  
	FROM InvoiceAbstract with (NOLOCK) 
	WHERE CustomerID = @CustomerId
	AND InvoiceType IN (1, 3)
	ORDER BY InvoiceDate ASC
	
	SET @SID = 1
	DECLARE @InvoiceId NVARCHAR(255)
	DECLARE @InvoiceDate NVARCHAR(12)
	DECLARE @Value NVARCHAR(12)

	WHILE(@SID <= (SELECT MAX(ID) FROM @SALES))
	BEGIN
		SELECT @InvoiceId = CAST(InvoiceId AS VARCHAR), @InvoiceDate = REPLACE(CONVERT(NVARCHAR(25),InvoiceDate, 106), ' ', '-') FROM @SALES WHERE ID = @SID AND CustomerID = @CustomerId
		SET @SQL = @SQL + ',[S_'+ @InvoiceId + '_' + @InvoiceDate +'] DECIMAL(18,6)'
		SET @SID = @SID + 1
	END

	DECLARE @SALESRETURN AS TABLE (ID INT IDENTITY(1,1), InvoiceId NVARCHAR(255), InvoiceDate DATETIME, CustomerID NVARCHAR(255), [Value] DECIMAL(18,6))
	INSERT INTO @SALESRETURN (InvoiceId, InvoiceDate, CustomerID, [Value])
	SELECT DISTINCT InvoiceId, InvoiceDate, CustomerID, NetValue  
	FROM InvoiceAbstract with (NOLOCK) 
	WHERE CustomerID = @CustomerId
	AND InvoiceType IN (4)
	ORDER BY InvoiceDate ASC

	SET @SID = 1

	WHILE(@SID <= (SELECT MAX(ID) FROM @SALESRETURN))
	BEGIN
		SELECT @InvoiceId = CAST(InvoiceId AS VARCHAR), @InvoiceDate = REPLACE(CONVERT(NVARCHAR(25),InvoiceDate, 106), ' ', '-') FROM @SALESRETURN WHERE ID = @SID AND CustomerID = @CustomerId
		SET @SQL = @SQL + ',[SR_'+ @InvoiceId + '_' + @InvoiceDate +'] DECIMAL(18,6)'
		SET @SID = @SID + 1
	END

	DECLARE @COLLECTIONS AS TABLE (ID INT IDENTITY(1,1), GSTFullDocID NVARCHAR(255), InvoiceId NVARCHAR(255), PaymentDate DATETIME, CustomerID NVARCHAR(255), [Value] DECIMAL(18,6))
	INSERT INTO @COLLECTIONS (InvoiceId, PaymentDate, CustomerID, [Value])
	SELECT DISTINCT CA.DocumentID, CD.PaymentDate, CA.CustomerID, CD.AdjustedAmount
	from CollectionDetail CD WITH (NOLOCK)
	JOIN Collections CA WITH (NOLOCK) ON CD.CollectionID = CA.DocumentID AND CA.CustomerID = @CustomerId
	ORDER BY CD.PaymentDate ASC

	--SELECT * FROM Collections WHERE CustomerId = @CustomerId ORDER BY DocumentID

	SET @SID = 1

	WHILE(@SID <= (SELECT MAX(ID) FROM @COLLECTIONS))
	BEGIN
		SELECT @InvoiceId = CAST(InvoiceId AS VARCHAR), @InvoiceDate = REPLACE(CONVERT(NVARCHAR(25),PaymentDate, 106), ' ', '-') FROM @COLLECTIONS WHERE ID = @SID AND CustomerID = @CustomerId
		SET @SQL = @SQL + ',[CL_'+ @InvoiceId + '_' + @InvoiceDate +'] DECIMAL(18,6)'
		SET @SID = @SID + 1
	END

	SET @SQL = @SQL + ',[Total_Order] DECIMAL(18,6)'
	SET @SQL = @SQL + ',[Total_Sales] DECIMAL(18,6)'
	SET @SQL = @SQL + ',[Total_SalesReturn] DECIMAL(18,6)'
	SET @SQL = @SQL + ',[Total_Colection] DECIMAL(18,6)'
	SET @SQL = @SQL + ',[Total_OutStanding] DECIMAL(18,6)'

	SET @SQL = @SQL + ') '

	SET @SQL = @SQL + ' INSERT INTO #TEMP([Salesman Name], Beat, CustomerId, [Customer Name])'
	SET @SQL = @SQL + ' select Salesman_Name, Description, CustomerId, Company_Name'
	SET @SQL = @SQL + ' FROM V_CUSTOMERS WITH (NOLOCK)'
	SET @SQL = @SQL + ' WHERE CustomerID = ''' + @CustomerId + ''''

	DECLARE @TOTALORDCOL AS NVARCHAR(MAX)
	DECLARE @TOTALSALCOL AS NVARCHAR(MAX)
	DECLARE @TOTALSRSCOL AS NVARCHAR(MAX)
	DECLARE @TOTALCOLCOL AS NVARCHAR(MAX)
	DECLARE @TOTALOUTCOL AS NVARCHAR(MAX)
	SET @TOTALORDCOL = ''
	SET @TOTALSALCOL = ''
	SET @TOTALSRSCOL = ''
	SET @TOTALCOLCOL = ''
	SET @TOTALOUTCOL = ''

	SET @SID = 1
	WHILE(@SID <= (SELECT MAX(ID) FROM @Orders))
	BEGIN
		SELECT @SONumber = CAST(SONumber AS VARCHAR), @Value= [Value], @SODATE = REPLACE(CONVERT(NVARCHAR(25),SODate, 106), ' ', '-') FROM @Orders WHERE ID = @SID AND CustomerID = @CustomerId
		SET @SQL = @SQL + ' UPDATE #TEMP SET [O_'+ @SONumber + '_' + @SODATE +'] = ' + @Value + ' WHERE CustomerID = ''' + @CustomerId + ''''
		SET @TOTALORDCOL = @TOTALORDCOL + (CASE WHEN ISNULL(@TOTALORDCOL, '') <> '' THEN ' + ' ELSE '' END) + 'ISNULL([O_'+ @SONumber + '_' + @SODATE +'], 0)'
		SET @SID = @SID + 1
	END
	SET @TOTALORDCOL = '(' + @TOTALORDCOL + ')'
	SET @SQL = @SQL + ' UPDATE #TEMP SET [Total_Order] = ' + @TOTALORDCOL + ' WHERE CustomerID = ''' + @CustomerId + ''''

	SET @SID = 1
	WHILE(@SID <= (SELECT MAX(ID) FROM @SALES))
	BEGIN
		SELECT @Value = [Value], @InvoiceId = CAST(InvoiceId AS VARCHAR), @InvoiceDate = REPLACE(CONVERT(NVARCHAR(25),InvoiceDate, 106), ' ', '-') FROM @SALES WHERE ID = @SID AND CustomerID = @CustomerId
		SET @SQL = @SQL + ' UPDATE #TEMP SET [S_'+ @InvoiceId + '_' + @InvoiceDate +'] = ' + @Value + ' WHERE CustomerID = ''' + @CustomerId + ''''
		SET @TOTALSALCOL = @TOTALSALCOL + (CASE WHEN ISNULL(@TOTALSALCOL, '') <> '' THEN ' + ' ELSE '' END) + 'ISNULL([S_'+ @InvoiceId + '_' + @InvoiceDate +'], 0)'
		SET @SID = @SID + 1
	END
	SET @TOTALSALCOL = '(' + @TOTALSALCOL + ')'
	SET @SQL = @SQL + ' UPDATE #TEMP SET [Total_Sales] = ' + @TOTALSALCOL + ' WHERE CustomerID = ''' + @CustomerId + ''''
	
	SET @SID = 1
	WHILE(@SID <= (SELECT MAX(ID) FROM @SALESRETURN))
	BEGIN
		SELECT @Value = [Value], @InvoiceId = CAST(InvoiceId AS VARCHAR), @InvoiceDate = REPLACE(CONVERT(NVARCHAR(25),InvoiceDate, 106), ' ', '-') FROM @SALESRETURN WHERE ID = @SID AND CustomerID = @CustomerId
		SET @SQL = @SQL + ' UPDATE #TEMP SET [SR_'+ @InvoiceId + '_' + @InvoiceDate +'] = ' + @Value + ' WHERE CustomerID = ''' + @CustomerId + ''''
		SET @TOTALSRSCOL = @TOTALSRSCOL + (CASE WHEN ISNULL(@TOTALSRSCOL, '') <> '' THEN ' + ' ELSE '' END) + 'ISNULL([SR_'+ @InvoiceId + '_' + @InvoiceDate +'], 0)'
		SET @SID = @SID + 1
	END
	SET @TOTALSRSCOL = '(' + @TOTALSRSCOL + ')'
	SET @SQL = @SQL + ' UPDATE #TEMP SET [Total_SalesReturn] = ' + @TOTALSRSCOL + ' WHERE CustomerID = ''' + @CustomerId + ''''

	SET @SID = 1
	WHILE(@SID <= (SELECT MAX(ID) FROM @COLLECTIONS))
	BEGIN
		SELECT @Value = [Value], @InvoiceId = CAST(InvoiceId AS VARCHAR), @InvoiceDate = REPLACE(CONVERT(NVARCHAR(25),PaymentDate, 106), ' ', '-') FROM @COLLECTIONS WHERE ID = @SID AND CustomerID = @CustomerId
		SET @SQL = @SQL + ' UPDATE #TEMP SET [CL_'+ @InvoiceId + '_' + @InvoiceDate +'] = ' + @Value + ' WHERE CustomerID = ''' + @CustomerId + ''''
		SET @TOTALCOLCOL = @TOTALCOLCOL + (CASE WHEN ISNULL(@TOTALCOLCOL, '') <> '' THEN ' + ' ELSE '' END) + 'ISNULL([CL_'+ @InvoiceId + '_' + @InvoiceDate +'], 0)'
		SET @SID = @SID + 1
	END
	SET @TOTALCOLCOL = '(' + @TOTALCOLCOL + ')'
	SET @SQL = @SQL + ' UPDATE #TEMP SET [Total_Colection] = ' + @TOTALCOLCOL + ' WHERE CustomerID = ''' + @CustomerId + ''''

	SET @SQL = @SQL + ' UPDATE #TEMP SET [Total_OutStanding] = ISNULL(Total_Sales, 0) - (ISNULL(Total_Colection, 0) + ISNULL(Total_SalesReturn, 0)) WHERE CustomerID = ''' + @CustomerId + ''''
	
	SET @SQL = @SQL + ' SELECT 1, * FROM #TEMP DROP TABLE #TEMP'

	PRINT @SQL

	exec (@SQL);
END 
GO
