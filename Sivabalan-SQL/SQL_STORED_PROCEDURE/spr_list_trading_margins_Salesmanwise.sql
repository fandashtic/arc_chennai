CREATE PROCEDURE [dbo].[spr_list_trading_margins_Salesmanwise](@FROMDATE DATETIME, @TODATE DATETIME)  
AS  
create table #temp(Salesmanid int, invid integer,Salesmanname nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS,TotSale Decimal(18,6),totCost Decimal(18,6))  
insert into #temp  
SELECT Invoiceabstract.SalesManid,Invoiceabstract.Invoiceid,  
"Salesman Name" = Case Invoiceabstract.SalesManid when 0 then 'Others' else Salesman.Salesman_name end,   
  
"Total Sale"=Case InvoiceAbstract.InvoiceType   
  When 4 then 0-ISNULL((SELECT Sum(InvoiceDetail.Amount)   
    FROM InvoiceDetail  
    WHERE InvoiceDetail.InvoiceID =Invoiceabstract.Invoiceid), 0)  
  Else ISNULL((SELECT Sum(InvoiceDetail.Amount)   
    FROM InvoiceDetail  
    WHERE InvoiceDetail.InvoiceID =Invoiceabstract.Invoiceid), 0)   End,  
  
"Total Cost of Goods"= Case InvoiceAbstract.InvoiceType   
When 4 then 0-(ISNULL((SELECT sum(ABS(InvoiceDetail.STPayable))   
   + sum(InvoiceDetail.PurchasePrice)   
   + sum(ABS(InvoiceDetail.CSTPayable))  
   + IsNull(Sum(Case Isnull(InvA.TaxOnMRP,0)   
   When 1 Then  
   (InvoiceDetail.MRP * InvoiceDetail.Quantity) * dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) /100
   Else  
   (InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered) /100
   End),0)  
   FROM InvoiceDetail, InvoiceAbstract InvA  
   WHERE InvA.InvoiceID = InvoiceDetail.InvoiceID And InvoiceDetail.InvoiceID = Invoiceabstract.Invoiceid), 0))  
Else (ISNULL((SELECT  sum(ABS(InvoiceDetail.STPayable))   
   + sum(InvoiceDetail.PurchasePrice)   
   + sum(ABS(InvoiceDetail.CSTPayable))  
   + IsNull(Sum(Case Isnull(InvA.TaxOnMRP,0)   
   When 1 Then  
   (InvoiceDetail.MRP * InvoiceDetail.Quantity) * dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) /100
   Else  
   (InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered) /100
   End),0)  
   FROM InvoiceDetail, InvoiceAbstract InvA
   WHERE InvA.InvoiceID = InvoiceDetail.InvoiceID And InvoiceDetail.InvoiceID =Invoiceabstract.Invoiceid), 0)) End   
  
FROM InvoiceAbstract
left Outer Join SalesMan  on InvoiceAbstract.SalesManid =SalesMan.SalesManid
WHERE InvoiceAbstract.InvoiceType not in (2)  
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceAbstract.Status & 128 = 0  
--AND InvoiceAbstract.SalesManid *=SalesMan.SalesManid  
  
Select   
Salesmanid,  
"SalesMan Name"=Salesmanname,  
"Total Sales Value (%c)"=Sum(TotSale),  
"Total Cost of Goods Sold (%c)"=Sum(totCost),  
"Total Sales Margin (%c)"=Sum(TotSale)-Sum(totCost)  
from #temp  
group by Salesmanid,Salesmanname  
order by salesmanid asc  
  
drop table #temp  
