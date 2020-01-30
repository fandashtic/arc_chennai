Create PROCEDURE spr_list_tradingmargins_Customer_fmcg (@CustomerID nvarchar(2550), @InvoiceType nvarchar(50), @FROMDATE DATETIME, @TODATE DATETIME)    
AS    

Declare @Delimeter as Char(1)  
Declare @OTHERS As NVarchar(50)

Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
Set @Delimeter=Char(15)  

Create table #tmpCus(CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  

if @CustomerID='%'   
   Insert into #tmpCus select CustomerID From Customer  
Else  
   Insert into #tmpCus select * from dbo.sp_SplitIn2Rows(@CustomerID, @Delimeter)  


Create table #temp(TempCustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SalesMargin Decimal(18,6), SalesReturnMargin Decimal(18,6))  
If (@InvoiceType = 'Trade Invoice')   
Begin  
Insert into #temp    
SELECT InvoiceAbstract.CustomerID + ':1' , InvoiceAbstract.CustomerID,   
Customer.Company_Name,  
"SalesMargin" = (ISNULL(Sum(a.Amount),0) - Sum(ISNULL(a.PurchasePrice, 0))    
- ABS(ISNULL(Sum(a.STPayable), 0))     
- ABS(ISNULL(Sum(a.CSTPayable), 0))    
- ISNULL(SUM(a.PurchasePrice * a.TaxSuffered / 100), 0)),     
  
"SalesReturn Margin" =   
ISNULL((SELECT Sum(InvoiceDetail.Amount)     
- Sum(InvoiceDetail.PurchasePrice)     
- ABS(ISNULL(sum(InvoiceDetail.STPayable), 0))     
- ABS(ISNULL(sum(InvoiceDetail.CSTPayable), 0))    
- ISNULL(SUM(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered / 100), 0)     
FROM InvoiceDetail, InvoiceAbstract     
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID    
AND InvoiceAbstract.InvoiceType = 4  
AND InvoiceAbstract.Status & 128 = 0    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceAbstract.CustomerID = Customer.CustomerID ), 0)  
    
FROM InvoiceDetail a, InvoiceAbstract, Items I1, Customer    
WHERE a.InvoiceID = InvoiceAbstract.InvoiceID    
AND InvoiceAbstract.InvoiceType in (1,3)   
AND a.Product_Code = I1.Product_Code    
AND a.Quantity > 0    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE    
AND InvoiceAbstract.Status & 128 = 0    
AND invoiceAbstract.CustomerID = Customer.CustomerID  
AND InvoiceAbstract.CustomerID In (Select CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCus)
--like @CustomerID    
GROUP BY InvoiceAbstract.CustomerID, Customer.Company_Name, Customer.CustomerID  
End  
Else If (@InvoiceType = 'Retail Sales')   
Begin  
Insert into #temp    
SELECT InvoiceAbstract.CustomerID + ':2', InvoiceAbstract.CustomerID,  
Isnull(Customer.Company_Name, @OTHERS),  
"SalesMargin" = (ISNULL(Sum(a.Amount),0) - Sum(ISNULL(a.PurchasePrice, 0))    
- ABS(ISNULL(Sum(a.STPayable), 0))     
- ABS(ISNULL(Sum(a.CSTPayable), 0))    
- ISNULL(SUM(a.PurchasePrice * a.TaxSuffered / 100), 0)),     
  
"SalesReturn Margin" =   
ISNULL((SELECT Sum(InvoiceDetail.Amount * -1)     
- Sum(InvoiceDetail.PurchasePrice * -1)     
- ABS(ISNULL(sum(InvoiceDetail.STPayable), 0))     
- ABS(ISNULL(sum(InvoiceDetail.CSTPayable), 0))    
- ISNULL(SUM((InvoiceDetail.PurchasePrice * -1) * InvoiceDetail.TaxSuffered / 100), 0)     
FROM InvoiceDetail, InvoiceAbstract     
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID    
AND InvoiceType = 2 And InvoiceDetail.Quantity < 0  
And InvoiceDetail.Quantity < 0    
AND InvoiceAbstract.Status & 128 = 0    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceAbstract.CustomerID = Customer.CustomerID ), 0)  
  
    
FROM InvoiceDetail a, InvoiceAbstract, Items I1, Customer    
WHERE a.InvoiceID = InvoiceAbstract.InvoiceID    
AND InvoiceAbstract.InvoiceType in (2)   
AND a.Product_Code = I1.Product_Code    
AND a.Quantity > 0    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE    
AND InvoiceAbstract.Status & 128 = 0    
AND invoiceAbstract.CustomerID = Customer.CustomerID  
AND InvoiceAbstract.CustomerID In (Select CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCus)
--like @CustomerID    
GROUP BY InvoiceAbstract.CustomerID, Customer.Company_Name, Customer.CustomerID  
End  
Else  
Begin  
Insert into #temp    
SELECT InvoiceAbstract.CustomerID + ':1' , InvoiceAbstract.CustomerID,   
Customer.Company_Name,  
"SalesMargin" = (ISNULL(Sum(a.Amount),0) - Sum(ISNULL(a.PurchasePrice, 0))    
- ABS(ISNULL(Sum(a.STPayable), 0))     
- ABS(ISNULL(Sum(a.CSTPayable), 0))    
- ISNULL(SUM(a.PurchasePrice * a.TaxSuffered / 100), 0)),     
  
"SalesReturn Margin" =   
ISNULL((SELECT Sum(InvoiceDetail.Amount)     
- Sum(InvoiceDetail.PurchasePrice)     
- ABS(ISNULL(sum(InvoiceDetail.STPayable), 0))     
- ABS(ISNULL(sum(InvoiceDetail.CSTPayable), 0))    
- ISNULL(SUM(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered / 100), 0)     
FROM InvoiceDetail, InvoiceAbstract     
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID    
AND InvoiceAbstract.InvoiceType = 4  
AND InvoiceAbstract.Status & 128 = 0    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceAbstract.CustomerID = Customer.CustomerID ), 0)  
    
FROM InvoiceDetail a, InvoiceAbstract, Items I1, Customer    
WHERE a.InvoiceID = InvoiceAbstract.InvoiceID    
AND InvoiceAbstract.InvoiceType in (1,3)   
AND a.Product_Code = I1.Product_Code    
AND a.Quantity > 0    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE    
AND InvoiceAbstract.Status & 128 = 0    
AND invoiceAbstract.CustomerID = Customer.CustomerID  
AND InvoiceAbstract.CustomerID In (Select CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCus)
--like @CustomerID    
GROUP BY InvoiceAbstract.CustomerID, Customer.Company_Name, Customer.CustomerID  
Union  
SELECT InvoiceAbstract.CustomerID + ':2', InvoiceAbstract.CustomerID,  
Isnull(Customer.Company_Name, @OTHERS),  
"SalesMargin" = (ISNULL(Sum(a.Amount),0) - Sum(ISNULL(a.PurchasePrice, 0))    
- ABS(ISNULL(Sum(a.STPayable), 0))     
- ABS(ISNULL(Sum(a.CSTPayable), 0))    
- ISNULL(SUM(a.PurchasePrice * a.TaxSuffered / 100), 0)),     
  
"SalesReturn Margin" =   
ISNULL((SELECT Sum(InvoiceDetail.Amount * -1)     
- Sum(InvoiceDetail.PurchasePrice * -1)     
- ABS(ISNULL(sum(InvoiceDetail.STPayable), 0))     
- ABS(ISNULL(sum(InvoiceDetail.CSTPayable), 0))    
- ISNULL(SUM((InvoiceDetail.PurchasePrice * -1) * InvoiceDetail.TaxSuffered / 100), 0)   
FROM InvoiceDetail, InvoiceAbstract     
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID    
AND InvoiceType = 2 And InvoiceDetail.Quantity < 0  
And InvoiceDetail.Quantity < 0    
AND InvoiceAbstract.Status & 128 = 0    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceAbstract.CustomerID = Customer.CustomerID ), 0)  
  
    
FROM InvoiceDetail a, InvoiceAbstract, Items I1, Customer    
WHERE a.InvoiceID = InvoiceAbstract.InvoiceID    
AND InvoiceAbstract.InvoiceType in (2)   
AND a.Product_Code = I1.Product_Code    
AND a.Quantity > 0    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE    
AND InvoiceAbstract.Status & 128 = 0    
AND invoiceAbstract.CustomerID = Customer.CustomerID  
And InvoiceAbstract.CustomerID In (Select CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCus)
--Like @CustomerID
  
  
GROUP BY InvoiceAbstract.CustomerID, Customer.Company_Name, Customer.CustomerID  
End  
  
select TempCustomerID, "Customer ID" = CustomerID, "Customer Name" = CustomerName, "Sales Margin" = SalesMargin, "Sales Return Margin" = SalesReturnMargin, "Net Trading Margin" = (Isnull(SalesMargin, 0) - Isnull(SalesReturnMargin, 0)) From #temp    
drop table #temp    
  
  





