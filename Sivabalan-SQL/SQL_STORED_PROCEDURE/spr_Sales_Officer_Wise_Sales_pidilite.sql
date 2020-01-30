CREATE Procedure spr_Sales_Officer_Wise_Sales_pidilite (@SALESOFFICERNAME nVARCHAR(2550),       
      @FROMDATE DATETIME ,       
      @TODATE DATETIME )      
AS      
    
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Create table #tmpSalesOfficer(SalesOfficerName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @SALESOFFICERNAME='%'       
   Insert into #tmpSalesOfficer select SalesmanName from Salesman2      
Else      
   Insert into #tmpSalesOfficer select * from dbo.sp_SplitIn2Rows(@SALESOFFICERNAME,@Delimeter)      
    
    
SELECT  (cast (InvoiceAbstract.CustomerID as nvarchar) ) + ',' + (cast (Salesman2.SalesmanName  as nvarchar)) ,     
 "Sales Officer" = Salesman2.SalesmanName  ,    
 "Company Name" = Customer.Company_Name,       
 "Net Value (%c)" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Amount,0) ELSE isnull(InvoiceDetail.Amount,0) END),      
 "Quantity" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END),    
 "Reporting UOM" = sum((case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END) / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),
 "Conversion Factor" = sum((case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END) * IsNull(ConversionFactor, 0))
 -- "No of Invoice" = count(InvoiceAbstract.invoiceid)      
FROM InvoiceAbstract, InvoiceDetail, Items, Customer, Salesman2      
WHERE  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
And InvoiceDetail.Product_Code = Items.Product_Code
And  InvoiceAbstract.Customerid = Customer.Customerid       
AND  InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid      
AND  InvoiceAbstract.InvoiceDate between @FROMDATE and @TODATE      
AND  InvoiceAbstract.Salesman2 = Salesman2.Salesmanid     
AND  Salesman2.SalesmanName In (select SalesOfficerName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesOfficer)      
AND  (InvoiceAbstract.Status & 128 ) = 0      
AND  InvoiceAbstract.InvoiceType in (1,3,4)      
GROUP BY  InvoiceAbstract.CustomerID, Customer.Company_Name  , Salesman2.SalesmanName    
order by Salesman2.SalesmanName     
    
Drop table #tmpSalesOfficer    
    
  
  
  



