CREATE PROCEDURE spr_top_customers_by_manufacturers(@ManufacturerID int,    
         @FROMDATE datetime,    
         @TODATE datetime, @CusType nVarchar(50))    
AS    
Declare @MLOtherCustomer NVarchar(50)
Set @MLOtherCustomer = dbo.LookupDictionaryItem(N'Other Customer', Default)
Set @CusType = dbo.LookupDictionaryItem2(@CusType, Default)

IF @CusType = N'Trade'    
BEGIN    
SELECT  TOP 25 CustomerID, "Customer" = Customer.Company_Name,     
 "Total Sales" = ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND     
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND     
 CustomerID = Customer.CustomerID AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType in (1, 3) AND (Status & 128) = 0), 0) -     
 ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND    
 CustomerID = Customer.CustomerID AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType = 4 AND (Status & 128) = 0), 0)    
FROM Customer    
WHERE ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND     
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND     
 CustomerID = Customer.CustomerID AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType in (1, 3) AND (Status & 128) = 0), 0) -     
 ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND    
 CustomerID = Customer.CustomerID AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType = 4 AND (Status & 128) = 0), 0) <> 0
ORDER BY "Total Sales" DESC    
END    
ELSE    
BEGIN    
    
Create Table #TopCustomers (CustomerID nVarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, TotalSales Decimal(18,6))    
    
INSERT INTO #TopCustomers SELECT     
--SELECT  TOP 25 "Customer ID" =     
  Cast(CustomerID As nVarchar),     
--"Customer" =     
  Customer.Company_Name,     
--"Total Sales" =     
 ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND     
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND     
 CustomerID = Customer.CustomerID AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType = 2 AND (Status & 128) = 0), 0)-    
ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND    
 CustomerID = Customer.CustomerID AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType in(5,6) AND (Status & 128) = 0), 0)    
--INTO #TopCustomers     
FROM Customer    
WHERE ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND     
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND     
 CustomerID = Customer.CustomerID AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType = 2 AND IsNull(CustomerID,N'') <> N'' And (Status & 128) = 0), 0) -  
ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND    
 CustomerID = Customer.CustomerID AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType in(5,6)  AND (Status & 128) = 0), 0) <> 0    
Group By CustomerID, Customer.Company_Name    
    
INSERT INTO #TopCustomers SELECT  Distinct @MLOtherCustomer, @MLOtherCustomer,     
 "Total Sales" = ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND     
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND     
 IsNull(CustomerID,N'') = N'' AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType = 2 AND (Status & 128) = 0), 0)  -  
ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND    
 CustomerID = Customer.CustomerID AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType in(5,6) AND (Status & 128) = 0), 0)    
FROM Customer    
WHERE ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND     
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND     
 IsNull(CustomerID,N'') = N'' AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType = 2 AND (Status & 128) = 0), 0)  -  
ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.ManufacturerID = @ManufacturerID AND    
 CustomerID = Customer.CustomerID AND     
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType in(5,6)  AND (Status & 128) = 0), 0) <> 0    
  
--Group By 'Other Customer'    
ORDER BY "Total Sales" DESC    
    
SELECT Top 25 * FROM #TopCustomers ORDER BY TotalSales DESC    
Drop Table #TopCustomers    
END    
    


