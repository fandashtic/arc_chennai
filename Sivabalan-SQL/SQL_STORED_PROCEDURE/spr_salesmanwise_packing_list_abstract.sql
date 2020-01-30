CREATE procedure [dbo].[spr_salesmanwise_packing_list_abstract](@SALESMAN nvarchar(2550),  
       @FROMNO nvarchar(50),  
       @TONO nvarchar(50),  
       @FROMDATE datetime,  
       @TODATE datetime
)  
--       @UOM nVarchar(250))  
AS  
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
Declare @MLOthers NVarchar(50)  
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)  
  
Create table #tmpSalesMan(SalesManName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @SALESMAN='%'     
   Insert into #tmpSalesMan select Salesman_Name from Salesman    
Else    
   Insert into #tmpSalesMan select * from dbo.sp_SplitIn2Rows(@SALESMAN,@Delimeter)    
  
IF @FROMNO = '%' SET @FROMNO = '0'  
IF @TONO = '%' SET @TONO = '2147483647'  
  
IF @SALESMAN = '%'  
    BEGIN  
 Select  Cast(InvoiceAbstract.SalesmanID as nvarchar) + ';' + Cast(@FROMNO as nvarchar) + ';'   
  + Cast(@TONO as nvarchar), "Salesman Name" = IsNull(Salesman.Salesman_Name, @MLOthers),  
  "Sales Value (%c)" = Sum(NetValue - IsNull(Freight, 0)),   
  "Total Invoices" = Count(InvoiceID),   
  "Invoices" = dbo.GetInvoicesForSalesman(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO)  
 From InvoiceAbstract, Salesman  
 Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And  
  (InvoiceAbstract.Status & 128) = 0 And   
  InvoiceAbstract.InvoiceType in (1, 3) And  
  InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And  
  Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And  
  InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)  
 Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name  
    End  
ELSE  
    BEGIN  
 Select  Cast(InvoiceAbstract.SalesmanID as nvarchar) + ';' + Cast(@FROMNO as nvarchar) + ';'   
  + Cast(@TONO as nvarchar), "Salesman Name" = IsNull(Salesman.Salesman_Name, @MLOthers),  
  "Sales Value (%c)" = Sum(NetValue - IsNull(Freight, 0)),   
  "Total Invoices" = Count(InvoiceID),   
  "Invoices" = dbo.GetInvoicesForSalesman(InvoiceAbstract.SalesmanID, @FROMDATE, @TODATE, @FROMNO, @TONO)  
 From InvoiceAbstract, Salesman  
 Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And  
  (InvoiceAbstract.Status & 128) = 0 And   
  InvoiceAbstract.InvoiceType in (1, 3) And  
  InvoiceAbstract.SalesmanID = Salesman.SalesmanID And  
  Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And  
  InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)  
 Group By InvoiceAbstract.SalesmanID, Salesman.Salesman_Name  
    END  
Drop table #tmpSalesMan
