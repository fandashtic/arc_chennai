CREATE PROCEDURE spr_ser_list_cash_credit_sales(@FROMDATE datetime,  
         @TODATE datetime)  

AS  

Create Table #Credittemp   
(CreditTerm  int, 
CreditTerm1 varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalesNetValue Decimal(18,6),ServiceNetValue Decimal(18,6),TotalNetValue Decimal(18,6))

Insert into #Credittemp
SELECT  InvoiceAbstract.CreditTerm, "Credit Term1" = Isnull(CreditTerm.Description,'Cash Sales'),
"SalesNetValue" =  SUM(NetValue),
"ServiceNetValue" = 0,
"TotalNetValue" = SUM(NetValue)  
FROM    InvoiceAbstract left outer join creditTerm on   
        InvoiceAbstract.CreditTerm = CreditTerm.CreditID  
WHERE   InvoiceAbstract.InvoiceType in (1,3) and   
 (InvoiceAbstract.Status & 128) = 0 and  
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
GROUP BY Invoiceabstract.CreditTerm, CreditTerm.[Description]
 
Insert into #Credittemp
 SELECT  ServiceInvoiceAbstract.CreditTerm, "Credit Term1" = Isnull(CreditTerm.Description,'Cash Sales'),
/*"ServiceNetValue" = Sum(Isnull(ServiceInvoiceAbstract.Netvalue,0)),
"TotalNetValue" = Sum(Isnull(ServiceInvoiceAbstract.Netvalue,0))*/

"SalesNetValue" = ISNULL((SELECT SUM(Isnull(serviceinvoiceDetail.Netvalue,0))                       
FROM ServiceInvoiceDetail, serviceInvoiceAbstract,items                       
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0               
AND serviceInvoiceDetail.sparecode = items.product_code  
AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  
AND serviceInvoiceAbstract.CreationTime BETWEEN @FROMDATE AND @TODATE),0),


"Service Net Value " = ISNULL((SELECT SUM(Isnull(serviceinvoiceDetail.Netvalue,0))                       
FROM ServiceInvoiceDetail, serviceInvoiceAbstract,items                       
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0               
AND serviceInvoiceDetail.product_code = items.product_code  
and isnull(Serviceinvoicedetail.Taskid,'') <> ''  and IsNull(ServiceinvoiceDetail.SpareCode, '') = '' 
AND serviceInvoiceAbstract.CreationTime BETWEEN @FROMDATE AND @TODATE),0),


"TotalNetValue " = ISNULL((SELECT SUM(Isnull(serviceinvoiceDetail.Netvalue,0))                       
FROM ServiceInvoiceDetail, serviceInvoiceAbstract,items                       
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0               
AND serviceInvoiceDetail.sparecode = items.product_code  
AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  
AND serviceInvoiceAbstract.CreationTime BETWEEN @FROMDATE AND @TODATE),0)

+ ISNULL((SELECT SUM(Isnull(serviceinvoiceDetail.Netvalue,0))                       
FROM ServiceInvoiceDetail, serviceInvoiceAbstract,items                       
WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                       
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0               
AND serviceInvoiceDetail.product_code = items.product_code  
and isnull(Serviceinvoicedetail.Taskid,'') <> ''  and IsNull(ServiceinvoiceDetail.SpareCode, '') = '' 
AND serviceInvoiceAbstract.CreationTime BETWEEN @FROMDATE AND @TODATE),0)


From Serviceinvoiceabstract left outer join creditTerm on   
	ServiceInvoiceAbstract.CreditTerm = CreditTerm.CreditID  
WHERE ServiceInvoiceAbstract.ServiceInvoiceType in (1) and   
	Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 and    
	serviceInvoiceAbstract.ServiceInvoiceDate BETWEEN  @FROMDATE AND @TODATE
GROUP BY ServiceInvoiceAbstract.CreditTerm,CreditTerm.[Description] 

Select "CreditTerm" = CreditTerm,
 "Credit Term" = Isnull(CreditTerm1,'Cash Sales'),
"Gross Value_Sales" = Sum(SalesNetValue),    
"Gross Value_Service" = Sum(ServiceNetValue),
"Total Gross Value" = sum(salesNetValue) + Sum(ServiceNetValue)   
From #Credittemp  GROUP BY CreditTerm,CreditTerm1
Drop Table #credittemp


