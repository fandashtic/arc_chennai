--exec SP_ARC_CustomerOutstandingBreakup 'AKASH.S.K-7010195569','%'
--exec SP_ARC_CustomerOutstandingBreakup 'AKASH.S.K-7010195569','301- PVM &PL - SAT'
--exec SP_ARC_CustomerOutstandingBreakup '%','301- PVM &PL - SAT'
--exec SP_ARC_CustomerOutstandingBreakup '%','%'
Exec ARC_Insert_ReportData 554, 'Customer Outstanding Breakup', 1, 'SP_ARC_CustomerOutstandingBreakup', 'Click to view Customer Outstanding Breakup', 53, 98, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_CustomerOutstandingBreakup')
BEGIN
    DROP PROC SP_ARC_CustomerOutstandingBreakup
END
GO
Create Proc SP_ARC_CustomerOutstandingBreakup(@Salesman Nvarchar(255) = '%', @Beat Nvarchar(255) = '%')  
AS  
BEGIN 
 DECLARE @I INT
 Declare @SQL AS NVARCHAR(MAX)
 DECLARE @SRSCOUNT AS INT
 DECLARE @SRDCOUNT AS INT
 DECLARE @CRCOUNT AS INT
 DECLARE @DRCOUNT AS INT
 DECLARE @CLCOUNT AS INT
 Declare @SRSSQL AS NVARCHAR(MAX)
 Declare @SRDSQL AS NVARCHAR(MAX)
 Declare @CRSQL AS NVARCHAR(MAX) 
 Declare @DRSQL AS NVARCHAR(MAX)
 Declare @CLSQL AS NVARCHAR(MAX)
 Declare @CustomerIdsFinal AS Table (CustomerID Nvarchar(255), SalesManID Int, BeatId Int)

 CREATE TABLE #SalesmanIDs ( SalesmanID int)
 CREATE TABLE #BeatIDs(BeatID int)

 SELECT CustomerId, Company_Name INTO #Customer FROM Customer WITH (NOLOCK)
 SELECT SalesmanID, Salesman_Name INTO #Salesman FROM Salesman WITH (NOLOCK)
 SELECT BeatId, Description INTO #Beat FROM Beat WITH (NOLOCK)

 IF(ISNULL(@Salesman, '') <> '%')
 BEGIN
	Insert into #SalesmanIDs
	SELECT SalesmanID FROM #Salesman Where Salesman_Name in (SELECT * from dbo.sp_SplitIn2Rows(@Salesman, ','))
 END

 IF(ISNULL(@Beat, '') <> '%')
 BEGIN
	Insert into #BeatIDs
	SELECT BeatId FROM #Beat Where Description in (SELECT * from dbo.sp_SplitIn2Rows(@Beat, ','))
 END
 
 SET @SQL = ''
 SET @SRSSQL = 'UPDATE #Sales SET [SRS-TOTAL] = (0 '
 SET @SRDSQL = 'UPDATE #Sales SET [SRD-TOTAL] = (0 '
 SET @CRSQL = 'UPDATE #Sales SET [CR-TOTAL] = (0 '
 SET @DRSQL = 'UPDATE #Sales SET [DR-TOTAL] = (0 '
 SET @CLSQL = 'UPDATE #Sales SET [CL-TOTAL] = (0 '

 SELECT DISTINCT 
  SA.CustomerId,
  (select TOP 1 Company_Name FROM #Customer WITH (NOLOCK) WHERE CustomerId = SA.CustomerId) CustomerName,
  SA.SalesmanID,
  (select TOP 1 Salesman_Name FROM #Salesman WITH (NOLOCK) WHERE SalesmanID = SA.SalesmanID) SalesmanName,
  SA.BeatID, 
  (select TOP 1 Description FROM #Beat WITH (NOLOCK) WHERE BeatId = SA.BeatId) Beat,
  SA.InvoiceDate, 
  SA.DeliveryDate,
  SA.GSTFullDocID [InvoiceId], 
  SA.NetValue  [InvoiceAmount],
  SA.RoundOffAmount
--  DeliveryStatus   
 Into #Sales
 FROM V_ARC_Sale_ItemDetails  SA WITH (NOLOCK)
 where ISNULL(SA.Balance, 0) > 0

 IF EXISTS(SELECT TOP 1 1 FROM #SalesmanIDs)
 BEGIn
	Delete From #Sales WHERE SalesmanID NOT IN (SELECT * FROM #SalesmanIDs)
 END

 IF EXISTS(SELECT TOP 1 1 FROM #BeatIDs)
 BEGIn
	Delete From #Sales WHERE BeatID NOT IN (SELECT * FROM #BeatIDs)
 END


 SET @SQL ='ALTER TABLE #Sales ADD [SRS-TOTAL] DECIMAL(18, 6) DEFAULT 0 ' EXEC (@SQL)
 SET @SQL ='ALTER TABLE #Sales ADD [SRD-TOTAL] DECIMAL(18, 6) DEFAULT 0 ' EXEC (@SQL)
 SET @SQL ='ALTER TABLE #Sales ADD [CR-TOTAL] DECIMAL(18, 6) DEFAULT 0 ' EXEC (@SQL)  
 SET @SQL ='ALTER TABLE #Sales ADD [DR-TOTAL] DECIMAL(18, 6) DEFAULT 0 ' EXEC (@SQL)  
 SET @SQL ='ALTER TABLE #Sales ADD [CL-TOTAL] DECIMAL(18, 6) DEFAULT 0 ' EXEC (@SQL)  
 SET @SQL ='ALTER TABLE #Sales ADD [OutStanding] DECIMAL(18, 6) DEFAULT 0 ' EXEC (@SQL)
 SET @SQL ='ALTER TABLE #Sales ADD [DueDaysBySales] INT DEFAULT 0 ' EXEC (@SQL)
 SET @SQL ='ALTER TABLE #Sales ADD [DueDaysByDelivery] INT DEFAULT 0 ' EXEC (@SQL)
 
 SELECT DISTINCT
  CustomerId,
  GSTFullDocID [SaleReturnId],   
  ReferenceNumber [InvoiceReference],
  [Type],
  SUM(NetValue) NetValue
  INTO #SR
 FROM V_ARC_SaleReturn_ItemDetails WITH (NOLOCK)
 GROUP BY  CustomerId, InvoiceDate, GSTFullDocID, ReferenceNumber, [Type]

 SELECT DISTINCT
  CustomerId,
  CollectionId,
  InvoiceReference,
  SUM(CollectionAmount) CollectionAmount
 INTO #CL
 FROM V_ARC_Collections WITH (NOLOCK) 
 GROUP BY CustomerId,CollectionDate,CollectionId,InvoiceReference

 SELECT DISTINCT
  CustomerId,
  DocumentReference [DebitNoteId],
  DocRef [ReferenceId], 
  SUM(NoteValue) NetValue
 INTO #DR
 FROM V_ARC_DebitNote WITH (NOLOCK)
 WHERE DocRef LIKE 'I/%'
 GROUP BY CustomerId,DocumentReference,DocRef

 SELECT DISTINCT
  CustomerId,
  DocumentReference [CreditNoteId],
  DocRef [ReferenceId], 
  SUM(NoteValue) NetValue
 INTO #CR
 FROM V_ARC_Creditnote WITH (NOLOCK)
 WHERE DocRef LIKE 'I/%'
 GROUP BY CustomerId,DocumentReference,DocRef

 CREATE TABLE #SRSCOUNTS(ID INT, [InvoiceReference] NVARCHAR(255), NetValue DECIMAL(18,6))
 CREATE TABLE #SRDCOUNTS(ID INT, [InvoiceReference] NVARCHAR(255), NetValue DECIMAL(18,6))
 CREATE TABLE #CRCOUNTS(ID INT, [InvoiceReference] NVARCHAR(255), NetValue DECIMAL(18,6))
 CREATE TABLE #DRCOUNTS(ID INT, [InvoiceReference] NVARCHAR(255), NetValue DECIMAL(18,6))
 CREATE TABLE #CLCOUNTS(ID INT, [InvoiceReference] NVARCHAR(255), NetValue DECIMAL(18,6))

 INSERT INTO #SRSCOUNTS SELECT ROW_NUMBER() OVER (PARTITION BY [InvoiceReference] ORDER BY [SaleReturnId]), [InvoiceReference],  SUM(NetValue) NetValue FROM #SR WITH (NOLOCK) WHERE [Type] = 'Salable' GROUP BY [InvoiceReference],[SaleReturnId]
 INSERT INTO #SRDCOUNTS SELECT ROW_NUMBER() OVER (PARTITION BY [InvoiceReference] ORDER BY [SaleReturnId]), [InvoiceReference],  SUM(NetValue) NetValue FROM #SR WITH (NOLOCK) WHERE [Type] = 'Damages' GROUP BY [InvoiceReference],[SaleReturnId]
 INSERT INTO #CRCOUNTS SELECT ROW_NUMBER() OVER (PARTITION BY [CreditNoteId] ORDER BY [ReferenceId]), [ReferenceId],  SUM(NetValue) NetValue FROM #CR WITH (NOLOCK) GROUP BY [ReferenceId],[CreditNoteId]
 INSERT INTO #DRCOUNTS SELECT ROW_NUMBER() OVER (PARTITION BY [ReferenceId] ORDER BY [DebitNoteId]), [ReferenceId],  SUM(NetValue) NetValue FROM #DR WITH (NOLOCK) GROUP BY [ReferenceId],[DebitNoteId]
 INSERT INTO #CLCOUNTS SELECT ROW_NUMBER() OVER (PARTITION BY [InvoiceReference] ORDER BY CollectionId), InvoiceReference,  SUM(CollectionAmount) NetValue FROM #CL WITH (NOLOCK) GROUP BY InvoiceReference,CollectionId

 SET @SRSCOUNT = (SELECT MAX(ID) FROM (SELECT [InvoiceReference], COUNT(DISTINCT [SaleReturnId]) ID FROM #SR WITH (NOLOCK) WHERE [Type] = 'Salable' GROUP BY [InvoiceReference]) X) 
 SET @SRDCOUNT = (SELECT MAX(ID) FROM (SELECT [InvoiceReference], COUNT(DISTINCT [SaleReturnId]) ID FROM #SR WITH (NOLOCK) WHERE [Type] = 'Damages' GROUP BY [InvoiceReference]) X) 
 SET @CRCOUNT = (SELECT MAX(ID) FROM (SELECT [ReferenceId], COUNT(DISTINCT [CreditNoteId]) ID FROM #CR WITH (NOLOCK) GROUP BY [ReferenceId]) X) 
 SET @DRCOUNT = (SELECT MAX(ID) FROM (SELECT [ReferenceId], COUNT(DISTINCT [DebitNoteId]) ID FROM #DR WITH (NOLOCK) GROUP BY [ReferenceId]) X) 
 SET @CLCOUNT = (SELECT MAX(ID) FROM (SELECT InvoiceReference, COUNT(DISTINCT CollectionId) ID FROM #CL WITH (NOLOCK) GROUP BY InvoiceReference) X)

 SET @SQL = ''
 SET @I = 1
 While(@I <= @SRSCOUNT)
 BEGIN
  SET @SQL = @SQL + 'ALTER TABLE #Sales ADD [SRS- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'] DECIMAL(18, 6) DEFAULT 0 '  
  SET @SRSSQL = @SRSSQL + '+ ISNULL([SRS- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'], 0)'  
  SET @I = @I + 1
 END
 EXEC (@SQL)

 SET @I = 1
 SET @SQL = ''
 While(@I <= @SRSCOUNT)
 BEGIN  
  SET @SQL = @SQL + 'UPDATE S SET S.[SRS- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'] = ISNULL(SR.NetValue, 0) FROM #Sales S WITH (NOLOCK) JOIN #SRSCOUNTS SR WITH (NOLOCK) ON SR.[InvoiceReference] = S.[InvoiceId] AND SR.ID = ' + LTRIM(RTRIM(cast(@I as char(5))))
  SET @I = @I + 1
 END
 EXEC (@SQL)

 SET @I = 1
 While(@I <= @SRDCOUNT)
 BEGIN
  SET @SQL = @SQL + 'ALTER TABLE #Sales ADD [SRD- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'] DECIMAL(18, 6) DEFAULT 0 '  
  SET @SRDSQL = @SRDSQL + '+ ISNULL([SRD- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'], 0)' 
  SET @I = @I + 1
 END
 EXEC (@SQL)

 SET @I = 1
 SET @SQL = ''
 While(@I <= @SRDCOUNT)
 BEGIN  
  SET @SQL = @SQL + 'UPDATE S SET S.[SRD- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'] = ISNULL(SR.NetValue, 0) FROM #Sales S WITH (NOLOCK) JOIN #SRDCOUNTS SR WITH (NOLOCK) ON SR.[InvoiceReference] = S.[InvoiceId] AND SR.ID = ' + LTRIM(RTRIM(cast(@I as char(5))))
  SET @I = @I + 1
 END
 EXEC (@SQL)

 SET @SQL = ''
 SET @I = 1
 While(@I <= @CRCOUNT)
 BEGIN
  SET @SQL = @SQL + 'ALTER TABLE #Sales ADD [CR- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'] DECIMAL(18, 6) DEFAULT 0 ' 
  SET @CRSQL = @CRSQL + '+ ISNULL([CR- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'], 0)' 
  SET @I = @I + 1
 END
 EXEC (@SQL)

 SET @SQL = ''
 SET @I = 1
 While(@I <= @CRCOUNT)
 BEGIN
  SET @SQL = @SQL + 'UPDATE S SET S.[CR- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'] = ISNULL(SR.NetValue, 0) FROM #Sales S WITH (NOLOCK) JOIN #CRCOUNTS SR WITH (NOLOCK) ON SR.[InvoiceReference] = S.[InvoiceId] AND SR.ID = ' + LTRIM(RTRIM(cast(@I as char(5))))
  SET @I = @I + 1
 END
 EXEC (@SQL)

 SET @SQL = ''
 SET @I = 1
 While(@I <= ISNULL(@DRCOUNT, 0))
 BEGIN
  SET @SQL = @SQL + 'ALTER TABLE #Sales ADD [DR- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'] DECIMAL(18, 6) DEFAULT 0 '  
  SET @DRSQL = @DRSQL + '+ ISNULL([DR- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'], 0)' 
  SET @I = @I + 1
 END
 EXEC (@SQL)

 SET @SQL = ''
 SET @I = 1
 While(@I <= ISNULL(@DRCOUNT, 0))
 BEGIN
  SET @SQL = @SQL + 'UPDATE S SET S.[DR- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'] = ISNULL(SR.NetValue, 0) FROM #Sales S WITH (NOLOCK) JOIN #DRCOUNTS SR WITH (NOLOCK) ON SR.[InvoiceReference] = S.[InvoiceId] AND SR.ID = ' + LTRIM(RTRIM(cast(@I as char(5))))
  SET @I = @I + 1
 END
 EXEC (@SQL)

 SET @SQL = ''
 SET @I = 1
 While(@I <= ISNULL(@CLCOUNT, 0))
 BEGIN
  SET @SQL = @SQL + 'ALTER TABLE #Sales ADD [CL- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'] DECIMAL(18, 6) DEFAULT 0 ' 
  SET @CLSQL = @CLSQL + '+ ISNULL([CL- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'], 0)' 
  SET @I = @I + 1
 END
 EXEC (@SQL)

 SET @SQL = ''
 SET @I = 1
 While(@I <= ISNULL(@CLCOUNT, 0))
 BEGIN
  SET @SQL = @SQL + 'UPDATE S SET S.[CL- '+ LTRIM(RTRIM(cast(@I as char(5))))  +'] = ISNULL(SR.NetValue, 0) FROM #Sales S WITH (NOLOCK) JOIN #CLCOUNTS SR WITH (NOLOCK) ON SR.[InvoiceReference] = S.[InvoiceId] AND SR.ID = ' + LTRIM(RTRIM(cast(@I as char(5))))
  SET @I = @I + 1
 END
 EXEC (@SQL)

 SET @SRSSQL = @SRSSQL + ' )'
 SET @SRDSQL = @SRDSQL + ' )'
 SET @CRSQL = @CRSQL + ' )'
 SET @DRSQL = @DRSQL + ' )'
 SET @CLSQL = @CLSQL + ' )'

 EXEC (@SRSSQL)
 EXEC (@SRDSQL)
 EXEC (@CRSQL)
 EXEC (@DRSQL)
 EXEC (@CLSQL)

 SET @SQL ='UPDATE #Sales SET [OutStanding] = (ISNULL([InvoiceAmount],0) + ISNULL(RoundOffAmount, 0)) - (ISNULL([SRS-TOTAL],0) + ISNULL([SRD-TOTAL],0) + ISNULL([CR-TOTAL],0) + ISNULL([CL-TOTAL],0)) + ISNULL([DR-TOTAL],0)' EXEC (@SQL)
 
 SET @SQL ='UPDATE #Sales SET [DueDaysBySales] = DATEDIFF(d, InvoiceDate, GETDATE()) WHERE ISNULL([OutStanding], 0) > 0' EXEC (@SQL)
 SET @SQL ='UPDATE #Sales SET [DueDaysByDelivery]= DATEDIFF(d, DeliveryDate, GETDATE()) WHERE ISNULL([OutStanding], 0) > 0' EXEC (@SQL)
   
 SET @SQL = ''
 SELECT 1 [Key], * FROM #Sales

 DROP TABLE #Sales
 DROP TABLE #SR
 DROP TABLE #CR
 DROP TABLE #DR
 DROP TABLE #CL
 DROP TABLE #SRSCOUNTS
 DROP TABLE #SRDCOUNTS
 DROP TABLE #CRCOUNTS
 DROP TABLE #DRCOUNTS
 DROP TABLE #CLCOUNTS
END
GO
