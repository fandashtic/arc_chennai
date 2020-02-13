--Exec ARC_BillsCut_LinesCut '07-Feb-2020' , '07-Feb-2020'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_BillsCut_LinesCut')
BEGIN
    DROP PROC [ARC_BillsCut_LinesCut]
END
GO
Create Proc ARC_BillsCut_LinesCut
(@FromDate DATETIME, @ToDate DAteTime)
AS
BEGIN
	Select DISTINCT
		InvoiceID,
		InvoiceDate,
		SalesmanID,
		Salesman_Name,
		dbo.fn_Arc_GetSalesmanCategory(SalesmanID) SalesmanCategory,
		Product_Code
	Into #V_Invoice
	from V_Invoice WITH (NOLOCK) 
	Where dbo.StripTimeFromDate(InvoiceDate) Between @FromDate And @ToDate


	DECLARE @SQL as NVARCHAR(MAX)
	DECLARE @Id as Int
	DECLARE @TempInvoiceDate as NVARCHAR(10)
	DECLARE @DATES AS TABLE(Id int Identity(1,1), InvoiceDate NVARCHAR(10))
	Insert Into @DATES(InvoiceDate)
	SELECT Distinct CONVERT(NVARCHAR(10), InvoiceDate, 105) From #V_Invoice WITH (NOLOCK) 
	Where dbo.StripTimeFromDate(InvoiceDate) Between @FromDate And @ToDate

	SEt @Id = 1
	SET @SQL = 'CREATE TABLE #Temp (SALESMAN NVARCHAR(255), SalesmanCategory NVARCHAR(255),';

	WHILE(@Id <= (Select Max(Id) From @DATES))
	BEGIN
		Select @TempInvoiceDate = InvoiceDate FROM @DATES Where ID = @Id
		SET @SQL = @SQL + '['+ @TempInvoiceDate + ' Bills Cut] INT, '	
		SET @SQL = @SQL + '['+ @TempInvoiceDate + ' Lines Cut] INT, '	
		SET @Id = @Id + 1;	
	END
	SET @SQL = @SQL + '[Total Bills Cut] INT, [Total Lines Cut] INT)';

	SET @SQL = @SQL + ' INSERT INTO #Temp(SALESMAN, SalesmanCategory) SELECT Distinct SALESMAN_NAME, SalesmanCategory FROM #V_Invoice';

	SEt @Id = 1
	WHILE(@Id <= (Select Max(Id) From @DATES))
	BEGIN
		Select @TempInvoiceDate = InvoiceDate FROM @DATES Where ID = @Id
		SET @SQL = @SQL + ' UPDATE T SET T.['+ @TempInvoiceDate + ' Bills Cut] = V.CNT FROM #Temp T, (SELECT Salesman_Name, SalesmanCategory, COUNT(Distinct InvoiceID) CNT FROM #V_Invoice WHERE CONVERT(NVARCHAR(10), InvoiceDate, 105) = ''' + @TempInvoiceDate + ''' GROUP BY Salesman_Name, SalesmanCategory) V WHERE V.Salesman_Name = T.SALESMAN';
		SET @SQL = @SQL + ' UPDATE T SET T.['+ @TempInvoiceDate + ' Lines Cut] = V.CNT FROM #Temp T, (SELECT Salesman_Name, SalesmanCategory, COUNT(Product_Code) CNT FROM #V_Invoice WHERE CONVERT(NVARCHAR(10), InvoiceDate, 105) = ''' + @TempInvoiceDate + ''' GROUP BY Salesman_Name, SalesmanCategory) V WHERE V.Salesman_Name = T.SALESMAN';
		SET @Id = @Id + 1;	
	END

	SET @SQL = @SQL + ' UPDATE T SET T.[Total Bills Cut] = V.CNT FROM #Temp T, (SELECT Salesman_Name, SalesmanCategory, COUNT(Distinct InvoiceID) CNT FROM #V_Invoice GROUP BY Salesman_Name, SalesmanCategory) V WHERE V.Salesman_Name = T.SALESMAN';
	SET @SQL = @SQL + ' UPDATE T SET T.[Total Lines Cut] = V.CNT FROM #Temp T, (SELECT Salesman_Name, SalesmanCategory, COUNT(Product_Code) CNT FROM #V_Invoice GROUP BY Salesman_Name, SalesmanCategory) V WHERE V.Salesman_Name = T.SALESMAN';

	SET @SQL = @SQL + ' SELECT 1, * FROm #Temp'
	PRINT @SQL
	EXEC (@SQL)

	DROP TABLE #V_Invoice
END
GO