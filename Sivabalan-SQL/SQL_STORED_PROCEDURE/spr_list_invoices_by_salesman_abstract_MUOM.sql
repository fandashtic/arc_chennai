CREATE PROCEDURE [dbo].[spr_list_invoices_by_salesman_abstract_MUOM] (@Salesman nvarchar(2550),  
 @FromInvNo nvarchar(50),    
 @ToInvNo nvarchar(50), @UOMDesc nvarchar(30))    
AS    
  
Declare @Delimeter as Char(1)
Declare @OTHERS As NVarchar(50)

Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
Set @Delimeter=Char(15)    
Create table #tmpSalesMan(SalesmanName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @Salesman='%'     
   Insert into #tmpSalesMan select Salesman_Name from Salesman    
Else    
   Insert into #tmpSalesMan select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter)    
  
IF @Salesman = '%'  
BEGIN  
SELECT  isnull(Salesman.SalesmanID, 0 ), "Salesman" = case isnull(Salesman.SalesmanID, 0 ) when 0 then @OTHERS else Salesman.Salesman_Name end,     
 "Net Value (%c)" = Sum(NetValue) - Sum(Freight),    
 "Balance (%c)" = Sum(Balance)    
FROM InvoiceAbstract
left Outer Join Salesman on InvoiceAbstract.SalesmanID = Salesman.SalesmanID
WHERE   InvoiceType in (1, 3) AND    
(InvoiceAbstract.Status & 128) = 0 AND    
--InvoiceAbstract.SalesmanID *= Salesman.SalesmanID AND    
InvoiceAbstract.DocumentID BETWEEN dbo.GetTrueVal(@FromInvNo) AND dbo.GetTrueVal(@ToInvNo) And  
Salesman.Salesman_Name In (select SalesmanName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)  
GROUP BY isnull(Salesman.SalesmanID, 0 ) ,  Salesman.Salesman_Name   
END  
ELSE  
BEGIN  
SELECT  isnull(Salesman.SalesmanID, 0 ), "Salesman" = case isnull(Salesman.SalesmanID, 0 ) when 0 then @OTHERS else Salesman.Salesman_Name end,     
 "Net Value (%c)" = Sum(NetValue) - Sum(Freight),    
 "Balance (%c)" = Sum(Balance)    
FROM InvoiceAbstract, Salesman    
WHERE   InvoiceType in (1, 3) AND    
(InvoiceAbstract.Status & 128) = 0 AND    
InvoiceAbstract.SalesmanID = Salesman.SalesmanID AND    
InvoiceAbstract.DocumentID BETWEEN dbo.GetTrueVal(@FromInvNo) AND dbo.GetTrueVal(@ToInvNo) And  
Salesman.Salesman_Name In (select SalesmanName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)  
GROUP BY isnull(Salesman.SalesmanID, 0 ) ,  Salesman.Salesman_Name   
END  
  
Drop table #tmpSalesMan  
