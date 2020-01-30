CREATE PROCEDURE [dbo].[spr_Retail_CustomerWise_Sales](@FROMDATE DateTime, @TODATE DateTime)    
AS    
  
DECLARE @InvoiceID INT  
DECLARE @CustomerName nVARCHAR(200)  
DECLARE @CustomerID nVarchar(50)
DECLARE @Sales Decimal(18,6)  
DECLARE @SalesReturn Decimal(18,6)  
DECLARE @NetSales Decimal(18,6)  
DECLARE @OTHERS nVarchar(50)
set @OTHERS = dbo.LookupDictionaryItem(N'Others',default)
CREATE TABLE #temp(CustomerID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, Customer nVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS, SalesAmount Decimal(18,6), SalesReturnAmt Decimal(18,6), NetSalesAmt Decimal(18,6))  
  
DECLARE RetailCustomer CURSOR FOR SELECT InvoiceID FROM InvoiceAbstract 
WHERE InvoiceType In (2,5,6) AND (Status & 128) = 0 AND invoiceabstract.invoicedate between @FROMDATE and @TODATE  
    
OPEN RetailCustomer  
FETCH NEXT FROM RetailCustomer  INTO @InvoiceID  
WHILE @@FETCH_STATUS = 0   
BEGIN    
	SET @Sales = NULL  
	SET @SalesReturn = NULL  
	
	SELECT @CustomerID = InvoiceAbstract.CustomerID, @CustomerName = Company_Name, 
	@Sales = Sum(InvoiceDetail.Amount)
	FROM InvoiceAbstract
	Left Outer Join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID
	Inner Join InvoiceDetail on InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
	
	WHERE InvoiceDetail.Quantity > 0  
    AND InvoiceAbstract.InvoiceType In (2)
	--AND InvoiceAbstract.CustomerID *= Customer.CustomerID 
	--AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
	AND InvoiceAbstract.InvoiceID = @InvoiceID  	
	Group By InvoiceDetail.InvoiceID, InvoiceAbstract.CustomerID,
	Company_Name
	
	SELECT @CustomerID = InvoiceAbstract.CustomerID, 
	@CustomerName = Customer.Company_Name, 
	@SalesReturn = Sum(InvoiceDetail.Amount)
	--FROM InvoiceDetail, InvoiceAbstract, Customer 
	FROM InvoiceAbstract
	Inner Join InvoiceDetail on InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
	Left Outer Join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID
	WHERE 
	--InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
	--AND InvoiceAbstract.CustomerID *= Customer.CustomerID  
	--AND 
	(InvoiceAbstract.InvoiceType In (5,6) Or InvoiceDetail.Quantity < 0 )
	AND InvoiceAbstract.InvoiceID = @InvoiceID  
	Group By InvoiceDetail.InvoiceID, InvoiceAbstract.CustomerID,
	Customer.Company_Name
	
	SET @NetSales = ISNULL(@Sales,0) - Abs(ISNULL(@SalesReturn,0))
	
	INSERT INTO #temp Values(@CustomerID, @CustomerName, @Sales, @SalesReturn, @NetSales)  
	FETCH NEXT FROM RetailCustomer INTO @InvoiceID  
END  
CLOSE RetailCustomer  
DEALLOCATE RetailCustomer  
SELECT "Customer Id" = IsNull(CustomerID, N''), "Customer Name" = IsNull(Customer, @OTHERS), 
"Sales" = Sum(SalesAmount), "Sales Return" = Sum(SalesReturnAmt),   
"Net Sales" = Sum(NetSalesAmt) FROM #temp GROUP BY Customer, customerID  
DROP TABLE #temp 


