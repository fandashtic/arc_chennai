CREATE PROCEDURE spr_ser_top_customers_by_manufacturers(@ManufacturerID int,    
         @FROMDATE datetime,    
         @TODATE datetime, @CusType nVarchar(50))    
AS    
IF @CusType = 'Trade'    
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
    
Create Table #TopCustomers (CustomerID nVarChar(100) 
COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerName nVarChar(255) 
COLLATE SQL_Latin1_General_CP1_CI_AS, TotalSales Decimal(18,6)
)    
    
INSERT INTO #TopCustomers SELECT     
Cast(CustomerID As nVarchar),     
Customer.Company_Name,     
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
FROM Customer    

WHERE ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND     
	InvoiceDetail.Product_Code = Items.Product_Code AND    
	Items.ManufacturerID = @ManufacturerID AND     
	CustomerID = Customer.CustomerID AND     
	InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
	InvoiceType = 2 AND IsNull(CustomerID,'') <> '' And (Status & 128) = 0), 0) -  
	ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
InvoiceDetail.Product_Code = Items.Product_Code AND    
Items.ManufacturerID = @ManufacturerID AND    
CustomerID = Customer.CustomerID AND     
InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
InvoiceType in(5,6)  AND (Status & 128) = 0), 0) <> 0    
Group By CustomerID, Customer.Company_Name    

INSERT INTO #TopCustomers  SELECT  Cast(Customer.CustomerID As nVarchar),   
	"Company_Name" = Customer.Company_Name,
	"Total Sales" =  sum(isnull(serviceinvoicedetail.netvalue,0))  
	From serviceinvoiceabstract,serviceinvoicedetail,customer,items  
	where serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
	And ServiceInvoiceAbstract.CustomerID = Customer.CustomerID  
	And ServiceInvoiceDetail.Sparecode = Items.product_code
	And Items.ManufacturerID = @ManufacturerID 
	And serviceInvoiceAbstract.serviceinvoicedate Between @FROMDATE AND @TODATE 
	AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
	AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0   
	AND IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
	group by customer.CustomerID, Customer.Company_Name,  
	serviceinvoiceabstract.serviceinvoiceid  

    
INSERT INTO #TopCustomers SELECT  Distinct 'Other Customer', 'Other Customer',     
	"Total Sales" = ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND     
	InvoiceDetail.Product_Code = Items.Product_Code AND    
	Items.ManufacturerID = @ManufacturerID AND     
	IsNull(CustomerID,'') = '' AND     
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
	IsNull(CustomerID,'') = '' AND     
	InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
	InvoiceType = 2 AND (Status & 128) = 0), 0)  -  
	ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items    
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
	InvoiceDetail.Product_Code = Items.Product_Code AND    
	Items.ManufacturerID = @ManufacturerID AND    
	CustomerID = Customer.CustomerID AND     
	InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
	InvoiceType in(5,6)  AND (Status & 128) = 0), 0) <> 0    
ORDER BY "Total Sales" DESC    


SELECT  Top 25 "CustomerID" = ([CustomerID]),  
"CustomerName" = ([Customername]),  
 "TotalSales" = Sum([TotalSales])      
 From #TopCustomers  
 GROUP BY ([CustomerID]),[CustomerName]  
 ORDER BY TotalSales DESC      
   

Drop Table #TopCustomers    
END    
   










