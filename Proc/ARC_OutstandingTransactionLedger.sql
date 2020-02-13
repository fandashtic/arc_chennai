--ARC_OutstandingTransactionLedger
Declare @SQL AS NVARCHAR(MAX)
SET @SQL = ''
--'Create Table #Transactions
--(
--	CustomerId Nvarchar(255),
--	InvoiceDate DateTime,
--	TransactionId Nvarchar(255),
--	SalesmanID INT,
--	BeatID INT,
--	[InvoiceValue] DECIMAL(18,6)'

SELECT * INTO #Ledger FROM CustomerLedger WITH (NOLOCK)

--ALTER TABLE CustomerLedger ADD [DueDays] INT
--ALTER TABLE CustomerLedger ADD [DueDate] DATETIME
--Alter table CustomerLedger ADD [TotalSalesReturn] DEcimal(18,6)
--Alter table CustomerLedger ADD [TotalCreditNote] DEcimal(18,6)
--Alter table CustomerLedger ADD [TotalDebitNote] DEcimal(18,6)
--Alter table CustomerLedger ADD [TotalCollection] DEcimal(18,6)
--Alter table CustomerLedger ADD [CurrentOutstanding] DEcimal(18,6)

--SELECT top 10 * FROM CustomerLedger WITH (NOLOCK)

SELECT InvoiceReference, TransactionDate, SUM(Debit) Debit  INTO #SR FROM #Ledger WITH (NOLOCK) WHERE TransactionType = 'SaleReturn' GROUP BY InvoiceReference, TransactionDate
SELECT InvoiceReference, TransactionDate, SUM(Debit) Debit INTO #CR FROM #Ledger WITH (NOLOCK) WHERE TransactionType = 'Creditnote' GROUP BY InvoiceReference, TransactionDate
SELECT InvoiceReference, TransactionDate, SUM(Credit) Credit INTO #DR FROM #Ledger WITH (NOLOCK) WHERE TransactionType = 'DebitNote' GROUP BY InvoiceReference, TransactionDate
SELECT InvoiceReference, TransactionDate, SUM(Debit) Debit INTO #CL FROM #Ledger WITH (NOLOCK) WHERE TransactionType = 'Collections' GROUP BY InvoiceReference, TransactionDate

--select * from #SR

--GOTO FINAL

Declare @FROMDATE DATETIME
Declare @TODATE DATETIME
Declare @TransactionDate DATETIME
Declare @TempDate NVARCHAR(15)
DECLARE @Days INT
DECLARE @Day INT
DECLARE @Year INT
DECLARE @Month INT
DECLARE @Date INT

SELECT @FROMDATE = MIN(TransactionDate), @TODATE = MAX(TransactionDate) FROM #Ledger
SET @Days = DATEDIFF(day, @FROMDATE, @TODATE)
SET @Day = 1
SET @TransactionDate = @FROMDATE

--While(@Day <= @Days)
--BEGIN
--	SET @TempDate = CONVERT(NVARCHAR(10), @TransactionDate, 105)

--	If EXISTS(SELECT TOP 1 1 FROM #SR WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
--	BEGIN
--		SET @SQL = @SQL + 'ALTER TABLE CustomerLedger ADD [SR ' + @TempDate  +'] DECIMAL(18, 6) '
--	END

--	If EXISTS(SELECT TOP 1 1 FROM #CR WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
--	BEGIN
--		SET @SQL = @SQL + 'ALTER TABLE CustomerLedger ADD [CR '+ @TempDate  +'] DECIMAL(18, 6) '
--	END

--	If EXISTS(SELECT TOP 1 1 FROM #DR WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
--	BEGIN
--		SET @SQL = @SQL + 'ALTER TABLE CustomerLedger ADD [DR '+ @TempDate  +'] DECIMAL(18, 6) '
--	END

--	If EXISTS(SELECT TOP 1 1 FROM #CL WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
--	BEGIN
--		SET @SQL = @SQL + 'ALTER TABLE CustomerLedger ADD [CL '+ @TempDate  +'] DECIMAL(18, 6) '
--	END

--	--PRINT @SQL

--	SET @Day = @Day + 1
--	Set @TransactionDate = DATEADD(D, 1, @TransactionDate)
--END

--SET @Day = 1
--SET @TransactionDate = @FROMDATE
--While(@Day <= @Days)
--BEGIN
--	SET @TempDate = CONVERT(NVARCHAR(10), @TransactionDate, 105)

--	SET @Year = YEAR(@TransactionDate)
--	SET @Month  = MONTH(@TransactionDate)
--	SET @Date  = DAY(@TransactionDate)


--	If EXISTS(SELECT TOP 1 1 FROM #SR WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
--	BEGIN
--		SET @SQL = @SQL + ' UPDATE T SET T.[SR '+ @TempDate  +'] = X.Debit FROM CustomerLedger T JOIN (SELECT InvoiceReference, Debit FROM #SR WITH (NOLOCK) WHERE Year(TransactionDate) = ' + CAST(@Year AS CHAR(5)) +' AND MONTH(TransactionDate) =' +  CAST(@Month AS CHAR(5)) + ' AND DAY(TransactionDate) = ' + CAST(@Date AS CHAR(5)) + ') X ON X.InvoiceReference = T.TransactionId'
--	END

--	If EXISTS(SELECT TOP 1 1 FROM #CR WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
--	BEGIN
--		SET @SQL = @SQL + ' UPDATE T SET T.[CR '+ @TempDate  +'] = X.Debit FROM CustomerLedger T JOIN (SELECT InvoiceReference, Debit FROM #CR WITH (NOLOCK) WHERE Year(TransactionDate) = ' + CAST(@Year AS CHAR(5)) + ' AND MONTH(TransactionDate) = ' +  CAST(@Month AS CHAR(5)) + ' AND DAY(TransactionDate) = ' + CAST(@Date AS CHAR(5)) + ') X ON X.InvoiceReference = T.TransactionId'		
--	END

--	If EXISTS(SELECT TOP 1 1 FROM #DR WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
--	BEGIN
--		SET @SQL = @SQL + ' UPDATE T SET T.[DR '+ @TempDate  +'] = X.Credit FROM CustomerLedger T JOIN (SELECT InvoiceReference, Credit FROM #DR WITH (NOLOCK) WHERE Year(TransactionDate) = ' + CAST(@Year AS CHAR(5)) +' AND MONTH(TransactionDate) = ' +  CAST(@Month AS CHAR(5)) + ' AND DAY(TransactionDate) = ' + CAST(@Date AS CHAR(5)) + ') X ON X.InvoiceReference = T.TransactionId'				
--	END

--	If EXISTS(SELECT TOP 1 1 FROM #CL WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
--	BEGIN
--		SET @SQL = @SQL + ' UPDATE T SET T.[CL '+ @TempDate  +'] = X.Debit FROM CustomerLedger T JOIN (SELECT InvoiceReference, Debit FROM #CL WITH (NOLOCK) WHERE Year(TransactionDate) = ' + CAST(@Year AS CHAR(5)) +' AND MONTH(TransactionDate) = ' +  CAST(@Month AS CHAR(5)) + ' AND DAY(TransactionDate) = ' + CAST(@Date AS CHAR(5)) + ') X ON X.InvoiceReference = T.TransactionId'						
--	END

--	SET @Day = @Day + 1
--	Set @TransactionDate = DATEADD(D, 1, @TransactionDate)
--END

Declare @TOTALSR AS NVARCHAR(MAX)
Declare @TOTALCR AS NVARCHAR(MAX)
Declare @TOTALCL AS NVARCHAR(MAX)
Declare @TOTALDR AS NVARCHAR(MAX)
Declare @TOTALOUT AS NVARCHAR(MAX)
SET @TOTALOUT = '('
SET @TOTALSR = '(0'
SET @TOTALCR = '(0'
SET @TOTALCL = '(0'
SET @TOTALDR = '(0'

SET @Day = 1
SET @TransactionDate = @FROMDATE
While(@Day <= @Days)
BEGIN
	SET @TempDate = CONVERT(NVARCHAR(10), @TransactionDate, 105)

	SET @Year = YEAR(@TransactionDate)
	SET @Month  = MONTH(@TransactionDate)
	SET @Date  = DAY(@TransactionDate)


	If EXISTS(SELECT TOP 1 1 FROM #SR WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
	BEGIN
		SET @TOTALSR = @TOTALSR + ' + ISNULL(T.[SR '+ @TempDate  +'], 0)'
	END

	If EXISTS(SELECT TOP 1 1 FROM #CR WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
	BEGIN
		SET @TOTALCR = @TOTALCR + ' + ISNULL(T.[CR '+ @TempDate  +'], 0)'
	END

	If EXISTS(SELECT TOP 1 1 FROM #DR WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
	BEGIN
		SET @TOTALDR = @TOTALDR + ' + ISNULL(T.[DR '+ @TempDate  +'], 0)'
	END

	If EXISTS(SELECT TOP 1 1 FROM #CL WITH (NOLOCK) WHERE Year(TransactionDate) = YEAR(@TransactionDate) AND MONTH(TransactionDate) = MONTH(@TransactionDate) AND DAY(TransactionDate) = DAY(@TransactionDate))
	BEGIN
		SET @TOTALCL = @TOTALCL + ' + ISNULL(T.[CL '+ @TempDate  +'], 0)'
	END

	SET @Day = @Day + 1
	Set @TransactionDate = DATEADD(D, 1, @TransactionDate)
END

SET @TOTALSR = @TOTALSR + ')'
SET @TOTALCR = @TOTALCR + ')'
SET @TOTALDR = @TOTALDR + ')'
SET @TOTALCL = @TOTALCL + ')'

--Alter table CustomerLedger ADD [TotalSalesReturn] DEcimal(18,6)
--Alter table CustomerLedger ADD [TotalCreditNote] DEcimal(18,6)
--Alter table CustomerLedger ADD [TotalDebitNote] DEcimal(18,6)
--Alter table CustomerLedger ADD [TotalCollection] DEcimal(18,6)

SET @TOTALSR = 'UPDATE CustomerLedger SET TotalSalesReturn = ' + @TOTALSR 
SET @TOTALCR ='UPDATE CustomerLedger SET TotalCreditNote = ' + @TOTALCR 
SET @TOTALDR = 'UPDATE CustomerLedger SET TotalDebitNote = ' + @TOTALDR 
SET @TOTALCL = 'UPDATE CustomerLedger SET TotalCollection = ' + @TOTALCL 

--SET @TOTALOUT = @TOTALOUT + 'UPDATE CustomerLedger SET CurrentOutstanding = ISNULL(Credit, 0) - (' + @TOTALSR + @TOTALCR + @TOTALCL + ') + ' + @TOTALDR + '))))'

PRINT @TOTALSR

EXEC (@TOTALSR)

PRINT @SQL

/*
SET @SQL = @SQL + ')INSERT INTO #Transactions(		
	CustomerId,
	InvoiceDate,
	TransactionId,
	SalesmanID,
	BeatID,
	InvoiceValue)
select Distinct 
	CustomerId,		
	InvoiceDate,
	GSTFullDocID,		
	SalesmanID,
	BeatID,
	NetValue
from V_ARC_Sale_ItemDetails WITH (NOLOCK)'



SET @SQL = @SQL + 'SELECT * FROM #Transactions DROP TABLE #Transactions'




*/

EXEC (@SQL)



FINAL:

DROP TABLE #SR
DROP TABLE #CR
DROP TABLE #DR
DROP TABLE #CL
DROP TABLE #Ledger


