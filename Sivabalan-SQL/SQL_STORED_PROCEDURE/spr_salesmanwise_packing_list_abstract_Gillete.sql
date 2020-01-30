CREATE procedure [dbo].[spr_salesmanwise_packing_list_abstract_Gillete](@SALESMAN nvarchar(2550), @UOM nvarchar(100),      
       @FROMNO nvarchar(50),      
       @TONO nvarchar(50),      
       @FROMDATE datetime,      
       @TODATE datetime)      
AS      
      
DECLARE @ValueTableName nvarchar(100)      
    
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Declare @MLOthers NVarchar(50)
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)
    
Create table #tmpSAL(Salesman nvarchar(255))      
if @SALESMAN = '%'       
   Insert into #tmpSAL select Salesman_Name from Salesman    
Else      
   Insert into #tmpSAL select * from dbo.sp_SplitIn2Rows(@SALESMAN, @Delimeter)      
      
IF @SALESMAN = '%'      
BEGIN      
 IF @FROMNO = '%' OR @TONO = '%'      
 BEGIN      
  SET @ValueTableName = 'SalesValue'      
  Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),      
  "Sales Value" = Case InvoiceType WHEN 4 THEN 0 - Sum(NetValue - IsNull(Freight, 0)) ELSE Sum(NetValue - IsNull(Freight, 0)) END       
  INTO #SalesValue      
  From InvoiceAbstract, Salesman, InvoiceDetail      
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
   (InvoiceAbstract.Status & 128) = 0 And       
   InvoiceAbstract.InvoiceType in (1, 3, 4) And      
   InvoiceDetail.PurchasePrice <> 0 And      
   InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID And      
   InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And      
   Salesman.Salesman_Name Like @SALESMAN      
   Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name, InvoiceType, NetValue, Freight       
 END      
 ELSE      
 BEGIN      
  SET @ValueTableName = 'SalesValue1'      
  Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),      
  "Sales Value" = Case InvoiceType WHEN 4 THEN 0 - Sum(NetValue - IsNull(Freight, 0)) ELSE Sum(NetValue - IsNull(Freight, 0)) END       
  INTO #SalesValue1      
  From InvoiceAbstract, Salesman, InvoiceDetail      
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
   (InvoiceAbstract.Status & 128) = 0 And       
   InvoiceAbstract.InvoiceType in (1, 3, 4) And      
   InvoiceDetail.PurchasePrice <> 0 And      
   InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID And      
   InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And      
   Salesman.Salesman_Name Like @SALESMAN And      
   InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)      
   Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name, InvoiceType, NetValue, Freight       
 END      
END      
ELSE      
BEGIN      
 IF @FROMNO = '%' OR @TONO = '%'      
 BEGIN      
  SET @ValueTableName = 'SalesValue2'      
  Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),      
  "Sales Value" = Case InvoiceType WHEN 4 THEN 0 - Sum(NetValue - IsNull(Freight, 0)) ELSE Sum(NetValue - IsNull(Freight, 0)) END       
  INTO #SalesValue2      
  From InvoiceAbstract, Salesman, InvoiceDetail      
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
   (InvoiceAbstract.Status & 128) = 0 And       
   InvoiceAbstract.InvoiceType in (1, 3, 4) And      
   InvoiceDetail.PurchasePrice <> 0 And      
   InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID And      
   InvoiceAbstract.SalesmanID <> 0 And      
   InvoiceAbstract.SalesmanID = Salesman.SalesmanID And      
   Salesman.Salesman_Name In (Select Salesman From #tmpSAL)    
   Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name, InvoiceType, NetValue, Freight       
 END      
 ELSE      
 BEGIN      
  SET @ValueTableName = 'SalesValue3'      
  Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),      
  "Sales Value" = Case InvoiceType WHEN 4 THEN 0 - Sum(NetValue - IsNull(Freight, 0)) ELSE Sum(NetValue - IsNull(Freight, 0)) END       
  INTO #SalesValue3      
  From InvoiceAbstract, Salesman, InvoiceDetail      
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
   (InvoiceAbstract.Status & 128) = 0 And       
   InvoiceAbstract.InvoiceType in (1, 3, 4) And      
   InvoiceDetail.PurchasePrice <> 0 And    
   InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID And      
   InvoiceAbstract.SalesmanID <> 0 And      
   InvoiceAbstract.SalesmanID = Salesman.SalesmanID And      
 Salesman.Salesman_Name In (Select Salesman From #tmpSAL) And      
   InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)      
   Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name, InvoiceType, NetValue, Freight       
 END      
END      
      
      
IF @SALESMAN = '%'      
BEGIN      
 IF @FROMNO = '%' OR @TONO = '%'      
 BEGIN      
  Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),      
   "Salesman Name" = IsNull(Salesman.Salesman_Name, @MLOthers),      
   "Sales Value (%c)" = (SELECT IsNull(Sum([Sales Value]),0) FROM #SalesValue WHERE [Salesman] = IsNull(Salesman.Salesman_Name,@MLOthers) GROUP BY [Salesman]),      
   "Total Invoices" = Count(InvoiceID),       
   "Invoices" = dbo.GetInvoicesForSalesman(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO)      
  From InvoiceAbstract, Salesman      
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
   (InvoiceAbstract.Status & 128) = 0 And       
   InvoiceAbstract.InvoiceType in (1, 3, 4) And      
   InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And      
   Salesman.Salesman_Name Like @SALESMAN      
  Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name       
      
 END      
 ELSE      
 BEGIN      
  Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),      
   "Salesman Name" = IsNull(Salesman.Salesman_Name, @MLOthers),      
   "Sales Value (%c)" = (SELECT IsNull(Sum([Sales Value]),0) FROM #SalesValue1 WHERE [Salesman] = IsNull(Salesman.Salesman_Name,@MLOthers) GROUP BY [Salesman]),      
   "Total Invoices" = Count(InvoiceID),       
   "Invoices" = dbo.GetInvoicesForSalesman(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO)      
  From InvoiceAbstract, Salesman      
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
   (InvoiceAbstract.Status & 128) = 0 And       
   InvoiceAbstract.InvoiceType in (1, 3, 4) And      
   InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And      
   Salesman.Salesman_Name Like @SALESMAN And      
   InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)      
  Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name       
      
 END      
END      
 --@UOM is unused parameter      
ELSE      
BEGIN      
 IF @FROMNO = '%' OR @TONO = '%'      
 BEGIN      
  Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),      
   "Salesman Name" = IsNull(Salesman.Salesman_Name, @MLOthers),      
   "Sales Value (%c)" = (SELECT IsNull(Sum([Sales Value]),0) FROM #SalesValue2 WHERE [Salesman] = IsNull(Salesman.Salesman_Name,@MLOthers) GROUP BY [Salesman]),      
   "Total Invoices" = Count(InvoiceID),       
   "Invoices" = dbo.GetInvoicesForSalesman(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO)      
  From InvoiceAbstract, Salesman      
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
   (InvoiceAbstract.Status & 128) = 0 And       
   InvoiceAbstract.InvoiceType in (1, 3, 4) And      
   InvoiceAbstract.SalesmanID = Salesman.SalesmanID And      
   Salesman.Salesman_Name In (Select Salesman From #tmpSAL)    
  Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name      
      
 END      
 ELSE      
 BEGIN       
 Select  "Salesman" = IsNull(Salesman.Salesman_Name, @MLOthers),      
   "Salesman Name" = IsNull(Salesman.Salesman_Name, @MLOthers),      
   "Sales Value (%c)" = (SELECT IsNull(Sum([Sales Value]),0) FROM #SalesValue3 WHERE [Salesman] = IsNull(Salesman.Salesman_Name,@MLOthers) GROUP BY [Salesman]),      
   "Total Invoices" = Count(InvoiceID),       
   "Invoices" = dbo.GetInvoicesForSalesman(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO)      
  From InvoiceAbstract, Salesman      
  Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
   (InvoiceAbstract.Status & 128) = 0 And       
   InvoiceAbstract.InvoiceType in (1, 3, 4) And      
   InvoiceAbstract.SalesmanID = Salesman.SalesmanID And      
   Salesman.Salesman_Name In (Select Salesman From #tmpSAL) And      
   InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)      
  Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name      
      
 END      
END      
      
EXEC('DROP TABLE ' + @ValueTableName)      
  
Drop Table #tmpSAL
