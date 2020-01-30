CREATE PROCEDURE spr_top_customers(@FROMDATE datetime,    
       @TODATE datetime, @CusType nVarchar(50))    
AS    
Declare @MLOtherCustomer NVarchar(50)
Set @MLOtherCustomer = dbo.LookupDictionaryItem(N'Other Customer', Default)
Set @CusType = dbo.LookupDictionaryItem2(@CusType, Default)


IF @CusType = 'Trade'    
BEGIN    
SELECT  TOP 25 Customer.CustomerID, Customer.Company_Name,     
 "Total Sales" = Sum(Case When InvoiceType In (4) Then -1 * IsNull(Amount, 0)
                          When InvoiceType In (1, 3) Then IsNull(Amount, 0) End)
 From Customer, InvoiceAbstract, InvoiceDetail 
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and    
   InvoiceAbstract.CustomerID = Customer.CustomerID AND     
   InvoiceDate BETWEEN @FROMDATE AND @TODATE  AND     
   InvoiceType In (1,3, 4) AND (Status & 128) = 0
   Group By Customer.CustomerID, Customer.Company_Name
ORDER BY "Total Sales" DESC      

END    
ELSE    
BEGIN    
  
SELECT  TOP 25 "Customer ID" =Cast(Customer.CustomerID As nVarchar), 
 "Customer Name" = IsNull(Customer.Company_Name, @MLOtherCustomer),     
 "Total Sales" = Sum(Case When InvoiceType In (5, 6) Then -1 * IsNull(Amount, 0)
                          When InvoiceType In (2) Then IsNull(Amount, 0) End)
INTO #TopCustomers 
 From Customer, InvoiceAbstract, InvoiceDetail 
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and    
   InvoiceAbstract.CustomerID = Customer.CustomerID AND     
   InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
   InvoiceType In (2, 5, 6) AND (Status & 128) = 0
   Group By Customer.CustomerID, Customer.Company_Name
   ORDER BY "Total Sales" DESC      
    
INSERT INTO #TopCustomers SELECT @MLOtherCustomer, @MLOtherCustomer,     
 "Total Sales" = ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail    
   WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and    
   InvoiceAbstract.CustomerID = '0' AND     
   InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
   InvoiceType = 2 AND (Status & 128) = 0), 0)  -  
   ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail
   WHERE  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and    
   InvoiceAbstract.CustomerID = '0' AND     
   InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
   InvoiceType in(5,6) AND (Status & 128) = 0), 0) 
   
SELECT Top 25 * FROM #TopCustomers ORDER BY [Total Sales] DESC    
END  

