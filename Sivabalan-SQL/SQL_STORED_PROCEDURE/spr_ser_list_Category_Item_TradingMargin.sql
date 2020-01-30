CREATE PROCEDURE spr_ser_list_Category_Item_TradingMargin(@CATEGORYID INT,
		  			         @FROMDATE DATETIME, 
						 @TODATE DATETIME)
AS

Declare @TotalMargin Decimal(18,6)

Create Table #Margin (ProdCode nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ProdName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Sales Decimal(18,6), 
Purchase Decimal(18,6), TradingMargin Decimal(18,6))

Insert into #Margin 
SELECT Items.Product_Code, "Item Name" = Items.ProductName,
"Total Sales" = ISNULL(sum(Isnull(Amount, 0)), 0) - ISNULL((SELECT ISNULL(Sum(InvoiceDetail.Amount),0) 
FROM InvoiceDetail, InvoiceAbstract
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND (InvoiceAbstract.InvoiceType = 4 Or (InvoiceType = 2 And InvoiceDetail.Quantity < 0))
AND InvoiceAbstract.Status & 128 = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceDetail.Product_Code = Items.Product_Code), 0),  

"Total Purchase" = Sum(Isnull(a.PurchasePrice, 0)) - ISNULL((SELECT ISNULL(Sum(InvoiceDetail.PurchasePrice), 0) 
FROM InvoiceDetail, InvoiceAbstract
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND (InvoiceAbstract.InvoiceType = 4 Or (InvoiceType = 2 And InvoiceDetail.Quantity < 0))
AND InvoiceAbstract.Status & 128 = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceDetail.Product_Code = Items.Product_Code), 0),

"Trading Margin (%c.)" = (ISNULL(Sum(a.Amount),0) 
- Sum(ISNULL(a.PurchasePrice, 0))
- ABS(ISNULL(SUM(a.STPayable), 0)) 
- ABS(ISNULL(SUM(a.CSTPayable), 0))
- ISNULL(SUM(a.PurchasePrice * a.TaxSuffered / 100), 0) 
- ISNULL((SELECT ISNULL(Sum(InvoiceDetail.Amount),0) 
- ISNULL(Sum(InvoiceDetail.PurchasePrice), 0) 
- ABS(ISNULL(Sum(InvoiceDetail.STPayable), 0)) 
- ABS(ISNULL(Sum(InvoiceDetail.CSTPayable), 0))
- ISNULL(SUM(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered / 100), 0) 
FROM InvoiceDetail, InvoiceAbstract
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND (InvoiceAbstract.InvoiceType = 4 Or (InvoiceType = 2 And InvoiceDetail.Quantity < 0))
AND InvoiceAbstract.Status & 128 = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceDetail.Product_Code = Items.Product_Code), 0))

FROM InvoiceDetail a, InvoiceAbstract, Items
WHERE a.InvoiceID = InvoiceAbstract.InvoiceID
AND InvoiceAbstract.InvoiceType <> 4
AND a.Product_Code = Items.Product_Code
AND a.Quantity > 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.Status & 128 = 0
AND Items.CategoryID = @CATEGORYID
GROUP BY Items.Product_Code, Items.ProductName


Insert into #Margin 

SELECT Items.Product_Code, 
"Item Name" = Items.ProductName,
"Total Sales" = sum(Isnull(a.NetValue, 0)),

"Total Purchase" = Sum(Isnull(IssueDetail.PurchasePrice, 0)),

"Trading Margin (%c.)" = (ISNULL(Sum(a.NetValue),0) - Sum(ISNULL(Issuedetail.PurchasePrice, 0))  
- ABS(ISNULL(Sum(a.LSTPayable), 0))   
- ABS(ISNULL(Sum(a.CSTPayable), 0))  
- ISNULL(SUM(Issuedetail.PurchasePrice * a.Tax_SufferedPercentage / 100), 0))   

FROM ServiceInvoiceDetail a, ServiceInvoiceAbstract, Items,IssueDetail
WHERE a.ServiceInvoiceID = ServiceInvoiceAbstract.ServiceInvoiceID
And a.IssueID = IssueDetail.IssueID
And a.Issue_Serial = IssueDetail.SerialNo
AND ServiceInvoiceAbstract.ServiceInvoiceType = 1
AND a.SpareCode = Items.Product_Code
AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN @FROMDATE AND @TODATE
AND Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0
And Isnull(a.Sparecode,'') <> ''
AND Items.CategoryID = @CATEGORYID
GROUP BY Items.Product_Code, Items.ProductName


Set @TotalMargin = (Select Sum(TradingMargin) from #Margin)

Select ProdCode, "Item Code" = ProdCode, "Item Name" = ProdName, 
"Sale Value (%c.)" = sum(Sales), 
"Purchase Value (%c.)" = sum(Purchase), 
"Trading Margin (%c.)" = sum(TradingMargin), 
"% Contribution" = Case sum(TradingMargin) 
When 0 Then 0 Else Cast((sum(TradingMargin) * 100 / @TotalMargin) as Decimal(18,6)) End  
From #Margin Where Sales > 0 group by ProdCode, ProdName

Drop table #Margin






