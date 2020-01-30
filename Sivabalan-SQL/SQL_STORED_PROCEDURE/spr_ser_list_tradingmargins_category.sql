CREATE PROCEDURE spr_ser_list_tradingmargins_category (@ProductHierarchy Varchar(256), @Category Varchar(256),  @FROMDATE DATETIME, @TODATE DATETIME)  
AS  
Create Table #tempCategory (CategoryID int, Status int)                
Exec sp_ser_GetLeafCategories @ProductHierarchy, @Category              
  
Create table #temp(CategoryID int, CategoryName varchar(225) COLLATE SQL_Latin1_General_CP1_CI_AS, SalesValue Decimal(18,6), PurchaseValue Decimal(18,6), Margin Decimal(18,6))  

Insert into #temp  

SELECT ItemCategories.CategoryID,   
"Category Name" = ItemCategories.Category_Name,   

"Total Sales" = ISNULL(sum(Isnull(Amount, 0)), 0) - ISNULL((SELECT Sum(InvoiceDetail.Amount)   
FROM InvoiceDetail, InvoiceAbstract, Items  
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
AND (InvoiceAbstract.InvoiceType = 4 Or (InvoiceType = 2 And InvoiceDetail.Quantity < 0))  
AND InvoiceAbstract.Status & 128 = 0  
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceDetail.Product_Code = Items.Product_Code  
AND Items.CategoryID = ItemCategories.CategoryID And Items.Product_Code = I1.Product_Code), 0),  

"Total Purchase" = Sum(Isnull(a.PurchasePrice, 0)) - ISNULL((SELECT Sum(InvoiceDetail.PurchasePrice)   
FROM InvoiceDetail, InvoiceAbstract, Items  
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
AND (InvoiceAbstract.InvoiceType = 4 Or (InvoiceType = 2 And InvoiceDetail.Quantity < 0))  
AND InvoiceAbstract.Status & 128 = 0  
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceDetail.Product_Code = Items.Product_Code  
AND Items.CategoryID = ItemCategories.CategoryID And Items.Product_Code = I1.Product_Code), 0),

"Trading Margin (%c.)" = (ISNULL(Sum(a.Amount),0) - Sum(ISNULL(a.PurchasePrice, 0))  
- ABS(ISNULL(Sum(a.STPayable), 0))   
- ABS(ISNULL(Sum(a.CSTPayable), 0))  
- ISNULL(SUM(a.PurchasePrice * a.TaxSuffered / 100), 0)   
- ISNULL((SELECT Sum(InvoiceDetail.Amount)   
- Sum(InvoiceDetail.PurchasePrice)   
- ABS(ISNULL(sum(InvoiceDetail.STPayable), 0))   
- ABS(ISNULL(sum(InvoiceDetail.CSTPayable), 0))  
- ISNULL(SUM(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered / 100), 0)   
FROM InvoiceDetail, InvoiceAbstract, Items  
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
AND (InvoiceAbstract.InvoiceType = 4 Or (InvoiceType = 2 And InvoiceDetail.Quantity < 0))  
AND InvoiceAbstract.Status & 128 = 0  
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceDetail.Product_Code = Items.Product_Code  
AND Items.CategoryID = ItemCategories.CategoryID And Items.Product_Code = I1.Product_Code), 0))
  
FROM InvoiceDetail a, InvoiceAbstract, Items I1, ItemCategories  
WHERE a.InvoiceID = InvoiceAbstract.InvoiceID  
AND InvoiceAbstract.InvoiceType <> 4  
AND a.Product_Code = I1.Product_Code  
AND a.Quantity > 0  
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND InvoiceAbstract.Status & 128 = 0  
AND I1.CategoryID = ItemCategories.CategoryID  
AND ItemCategories.CategoryID in (Select CategoryID from #tempCategory)       
AND I1.CategoryID = ItemCategories.CategoryID   
  
GROUP BY ItemCategories.CategoryID, ItemCategories.Category_Name, I1.Product_Code  


Insert into #temp  

SELECT ItemCategories.CategoryID,   
"Category Name" = ItemCategories.Category_Name,   

"Total Sales" = ISNULL(Sum(a.NetValue),0),   

"Total Purchase" = Sum(Isnull(Issuedetail.PurchasePrice, 0)),

"Trading Margin (%c.)" = (ISNULL(Sum(a.NetValue),0) - Sum(ISNULL(Issuedetail.PurchasePrice, 0))  
- ABS(ISNULL(Sum(a.LSTPayable), 0))   
- ABS(ISNULL(Sum(a.CSTPayable), 0))  
- ISNULL(SUM(Issuedetail.PurchasePrice * a.Tax_SufferedPercentage / 100), 0))   
FROM ServiceInvoiceDetail a, ServiceInvoiceAbstract, Items I1, ItemCategories,Issuedetail 
WHERE a.ServiceInvoiceID = ServiceInvoiceAbstract.ServiceInvoiceID 
And a.IssueID = IssueDetail.IssueID
And a.Issue_Serial = IssueDetail.SerialNo
AND ServiceInvoiceAbstract.ServiceInvoiceType = 1  
And ISnull(a.Sparecode,'') <> ''
AND a.SpareCode = I1.Product_Code  
AND a.Quantity > 0  
AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN @FROMDATE AND @TODATE  
AND Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0  
AND I1.CategoryID = ItemCategories.CategoryID  
AND ItemCategories.CategoryID in (Select CategoryID from #tempCategory)       
AND I1.CategoryID = ItemCategories.CategoryID   
  
GROUP BY ItemCategories.CategoryID, ItemCategories.Category_Name, I1.Product_Code  

select CategoryID, "Category Name" = CategoryName, "Sales Value (%c.)" = Sum(SalesValue), 
"Purchase Value (%c.)" = Sum(PurchaseValue), 
"Trading Margin (%c.)" = Sum(Margin)  
From #temp  
Group By CategoryID, CategoryName  Having Sum(SalesValue) > 0
drop table #temp  



