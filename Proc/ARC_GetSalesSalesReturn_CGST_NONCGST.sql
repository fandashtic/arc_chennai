--Exec ARC_GetSalesSalesReturn_CGST_NONCGST '2020-02-01 00:00:00.000', '2020-02-01 23:59:59.000'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_GetSalesSalesReturn_CGST_NONCGST')
BEGIN
    DROP PROC ARC_GetSalesSalesReturn_CGST_NONCGST
END
GO
CREATE Proc ARC_GetSalesSalesReturn_CGST_NONCGST(@FromDate DateTime, @Todate DateTime)  
AS   
BEGIN  
 SET DATEFORMAT DMY  
  
 SELECT *   
 INTO #Sales  
 FROM V_ARC_Sale_ItemDetails WITH (NOLOCK) WHERE dbo.StripDateFromTime(InvoiceDate) Between @FromDate AND @Todate  
  
 SELECT *   
 INTO #SalesReturn  
 FROM V_ARC_SaleReturn_ItemDetails WITH (NOLOCK) WHERE dbo.StripDateFromTime(InvoiceDate) Between @FromDate AND @Todate  
  
 select C.CustomerId, C.Company_Name, ISNULL(C.GSTIN, '') GSTIN INTO #Customer from Customer C WITH (NOLOCK)  
  
 SELECT 1 [x], X.InvoiceDate, X.CustomerID, C.Company_Name [Customer Name],   
 --X.SalesmanID,   
 S.Salesman_Name [SalesMan],   
 --X.BeatID,   
 B.Description [Beat],   
 X.GSTFullDocID,   
 X.[Type],  
 (SELECT Top 1 NetValue FROM #Sales S WITH (NOLOCK) WHERE S.GSTFullDocID = X.GSTFullDocID AND X.[Type] = 'Sales' AND ISNULL(C.GSTIN, '') <> '') [CGST Sales],   
 (SELECT Top 1 NetValue FROM #Sales S WITH (NOLOCK) WHERE S.GSTFullDocID = X.GSTFullDocID AND X.[Type] = 'Sales' AND ISNULL(C.GSTIN, '') = '') [Non CGST Sales],  
 (SELECT Top 1 NetValue FROM #SalesReturn S WITH (NOLOCK) WHERE S.GSTFullDocID = X.GSTFullDocID AND X.[Type] = 'Sales Return' AND ISNULL(C.GSTIN, '') <> '') [CGST Sales Return],   
 (SELECT Top 1 NetValue FROM #SalesReturn S WITH (NOLOCK) WHERE S.GSTFullDocID = X.GSTFullDocID AND X.[Type] = 'Sales Return' AND ISNULL(C.GSTIN, '') = '') [Non CGST Sales Return]  
 INTO #Temp  
 FROM   
 (SELECT DISTINCT CustomerId, InvoiceDate, SalesmanID, BeatID, GSTFullDocID, NetValue, 'Sales' [Type] From #Sales  WITH (NOLOCk) UNION  
 SELECT DISTINCT CustomerId, InvoiceDate, SalesmanID, BeatID, GSTFullDocID, NetValue,'Sales Return' [Type] From #SalesReturn WITH (NOLOCk)) X  
 FULL OUTER JOIN #Customer C WITH (NOLOCK) ON C.CustomerID = X.CustomerID  
 JOIN Salesman S WITH (NOLOCK) ON S.SalesmanID = X.SalesmanID  
 JOIN Beat B WITH (NOLOCK) ON B.BeatID = X.BeatID  
   
  
 SELECT * FROM #Temp WITH (NOLOCK) WHERE ISNULL(CustomerID, '') <> '' ORDER BY InvoiceDate ASC  
  
 DROP TABLE #Temp  
END  