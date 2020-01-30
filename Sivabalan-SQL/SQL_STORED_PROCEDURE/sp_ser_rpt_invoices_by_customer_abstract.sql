CREATE PROCEDURE sp_ser_rpt_invoices_by_customer_abstract(@CUSTOMER nvarchar(255),    
              @FROMDATE datetime,    
              @TODATE datetime)    
AS    
SELECT  ServiceInvoiceAbstract.CustomerID, "Customer Name" = Customer.Company_Name,    
"Net Value" = Sum(NetValue),  
"Balance" =  Sum(Balance)
FROM ServiceInvoiceAbstract, Customer    
WHERE  serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE     
AND serviceInvoiceAbstract.CustomerID = Customer.CustomerID     
AND Customer.Company_Name LIKE @CUSTOMER     
AND(IsNull(Serviceinvoiceabstract.Status, 0) & 192) = 0     
GROUP BY serviceInvoiceAbstract.CustomerID, Customer.Company_Name    


