CREATE PROCEDURE spr_ser_top_customers(@FROMDATE datetime,      
       @TODATE datetime, @CusType nVarchar(50))      
AS      
    
IF @CusType = 'Trade'      
BEGIN      
SELECT  TOP 25 Customer.CustomerID, Customer.Company_Name,       
 "Total Sales" = ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail
   WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   InvoiceAbstract.CustomerID = Customer.CustomerID AND       
   InvoiceDate BETWEEN @FROMDATE AND @TODATE AND       
   InvoiceType in (1, 3) AND (Status & 128) = 0), 0) -       
   ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail  
   WHERE  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   InvoiceAbstract.CustomerID = Customer.CustomerID AND       
   InvoiceDate BETWEEN @FROMDATE AND @TODATE AND       
   (customer.customercategory <> (4)) and        
   (customer.customercategory <> (5)) and                                                                                  
   InvoiceType = 4 AND (Status & 128) = 0), 0),  

"Total Service" = 0,  

"Net Value" = ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail
   WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   InvoiceAbstract.CustomerID = Customer.CustomerID AND       
   InvoiceDate BETWEEN @FROMDATE AND @TODATE AND       
   InvoiceType in (1, 3) AND (Status & 128) = 0), 0) -       
   ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail  
   WHERE  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   InvoiceAbstract.CustomerID = Customer.CustomerID AND
   (customer.customercategory <> (4)) and                                                                                  
   (customer.customercategory <> (5)) and                                                                                  
   InvoiceDate BETWEEN @FROMDATE AND @TODATE AND       
   InvoiceType = 4 AND (Status & 128) = 0), 0)      
FROM Customer 
where (customer.customercategory <> (4)) and                                                                                  
   (customer.customercategory <> (5))                                                                                 
ORDER BY "Total Sales" DESC      
END      
ELSE      
BEGIN      
  
SELECT  TOP 25 "Customer ID" =Cast(Customer.CustomerID As nVarchar),   
"Company_Name" = IsNull(Customer.Company_Name, 'Other Customer'),       
 "Total Sales" = ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail      
   WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   InvoiceAbstract.CustomerID = '0' AND  
   InvoiceDate BETWEEN @FROMDATE AND @TODATE and      
   InvoiceType = 2 AND (Status & 128) = 0), 0)  -    
   ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail       
   WHERE  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   InvoiceAbstract.CustomerID = Customer.CustomerID AND       
   InvoiceDate BETWEEN @FROMDATE AND @TODATE and      
   InvoiceType in(5,6) AND (Status & 128) = 0), 0),
  
  
  "Total service" = NULL,  
  
 "Net Value " = ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail      
   WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   InvoiceAbstract.CustomerID = Customer.CustomerID AND       
   InvoiceDate BETWEEN @FROMDATE AND @TODATE and      
   InvoiceType = 2 AND (Status & 128) = 0), 0)  -    
   ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail       
   WHERE  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   InvoiceAbstract.CustomerID = Customer.CustomerID AND       
   InvoiceDate BETWEEN @FROMDATE AND @TODATE and      
   InvoiceType in(5,6) AND (Status & 128) = 0), 0)      
INTO #TopCustomers FROM Customer    
  
INSERT INTO #TopCustomers  SELECT  TOP 25 "Customer ID" =Cast(Customer.CustomerID As nVarchar),   
"Company_Name" = IsNull(Customer.Company_Name, 'Other Customer'),       

 "Total sales" = (select sum(isnull(serviceinvoicedetail.netvalue,0))  
 from serviceinvoiceabstract sa,serviceinvoicedetail,customer   
 where sa.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  and  
 sa.serviceinvoicedate Between @FROMDATE AND @TODATE  
 And Sa.CustomerID = Customer.CustomerID   
 AND (sa.serviceInvoiceType = 1)                         
 AND Isnull(sa.Status,0) & 192 = 0      
 And IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
 and sa.serviceInvoiceID = serviceInvoiceAbstract.serviceInvoiceID  
 group by  customer.CustomerID, sa.serviceinvoiceid), 

 "Total Service" = (select sum(isnull(serviceinvoicedetail.netvalue,0))  
 from serviceinvoiceabstract sa,serviceinvoicedetail,customer   
 where sa.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID  and  
 sa.serviceinvoicedate Between @FROMDATE AND @TODATE  
 And Sa.CustomerID = Customer.CustomerID   
 AND (sa.serviceInvoiceType = 1)                         
 AND Isnull(sa.Status,0) & 192 = 0      
 And IsNull(ServiceinvoiceDetail.SpareCode, '') = ''    
 and isnull(Serviceinvoicedetail.Taskid,'') <> ''    
 and sa.serviceInvoiceID = serviceInvoiceAbstract.serviceInvoiceID  
 group by  customer.CustomerID, sa.serviceinvoiceid),  
  

 "Net Value" = max(isnull(serviceinvoiceabstract.netvalue,0)) - max(isnull(Freight,0))  
 from serviceinvoiceabstract,serviceinvoicedetail,customer  
 where serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
 And ServiceInvoiceAbstract.CustomerID = Customer.CustomerID  
 And serviceInvoiceAbstract.serviceinvoicedate Between @FROMDATE AND @TODATE 
 AND (serviceInvoiceAbstract.serviceInvoiceType = 1)        
-- AND (customer.cutomertype <> 4)                                          
 AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0      
-- AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
 group by customer.CustomerID, Customer.Company_Name,  
 serviceinvoiceabstract.serviceinvoiceid  

SELECT  Top 25 "CustomerID" = ([Customer ID]),  
"Company_Name" = 
case when ([Company_Name]) = 'WalkIn Customer'

then 'Other Customer' 
ELSE ([Company_Name])  
End,
 "Total Sales" = Sum([Total sales]),      
 "Total Service" = Sum(isnull([Total Service],0)),      
 "Net Value"= Sum([Net Value])   
 From #TopCustomers  
 GROUP BY ([Customer ID]),[Company_Name]  
 ORDER BY [Net Value] DESC      
end  







