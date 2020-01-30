CREATE PROCEDURE spr_ser_list_trading_margins_brandwise_detail(@BRANDID INT,
		  			         @FROMDATE DATETIME, 
						 @TODATE DATETIME)
AS

Create Table #BrandTemp(ProductCode nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Item Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Trading Margin] Decimal(18,6))

Insert into #BrandTemp

SELECT Items.Product_Code, "Item Name" = Items.ProductName,
"Trading Margin (%c.)" = (ISNULL(Sum(a.Amount),0) 
- Sum(ISNULL(a.PurchasePrice, 0))
- ABS(ISNULL(SUM(a.STPayable), 0)) 
- ABS(ISNULL(SUM(a.CSTPayable), 0))
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)     
When 1 Then    
(a.MRP * a.Quantity) * dbo.sp_ser_get_TaxOnMRP(a.TaxSuffered) / 100
Else    
(a.PurchasePrice * a.TaxSuffered) / 100
End),0)  
- ISNULL((SELECT ISNULL(Sum(InvoiceDetail.Amount),0) 
- sum(abs(InvoiceDetail.STPayable)) 
- sum(InvoiceDetail.PurchasePrice) 
- sum(abs(InvoiceDetail.CSTPayable)) 
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)     
When 1 Then    
(InvoiceDetail.MRP * InvoiceDetail.Quantity) * dbo.sp_ser_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100
Else    
(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered) / 100
End),0)  
FROM InvoiceDetail, InvoiceAbstract
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND (InvoiceAbstract.InvoiceType = 4 Or (InvoiceType = 2 And InvoiceDetail.Quantity < 0))
AND InvoiceAbstract.Status & 128 = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceDetail.Product_Code = Items.Product_Code
GROUP BY InvoiceAbstract.TaxOnMRP), 0))
FROM InvoiceDetail a, InvoiceAbstract, Items
WHERE a.InvoiceID = InvoiceAbstract.InvoiceID
AND InvoiceAbstract.InvoiceType <> 4
AND a.Product_Code = Items.Product_Code
AND a.Quantity > 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.Status & 128 = 0
AND Items.BrandID = @BRANDID
GROUP BY Items.Product_Code, Items.ProductName

Insert into #BrandTemp

SELECT Items.Product_Code, "Item Name" = Items.ProductName,
"Trading Margin (Rs.)" = ISNULL(Sum(a.NetValue),0) 
- Sum(ISNULL(Iss.PurchasePrice, 0))
- SUM(ABS(ISNULL(a.LSTPayable, 0))) - SUM(ABS(ISNULL(a.CSTPayable, 0)))
 - Sum(ABS(ISNULL((isnull(Iss.PurchasePrice,0) * isnull(a.Tax_SufferedPercentage,0))/100,0)))
FROM ServiceInvoiceDetail a, ServiceInvoiceAbstract, Items,IssueDetail Iss
WHERE a.ServiceInvoiceID = serviceInvoiceAbstract.serviceInvoiceID
AND serviceInvoiceAbstract.serviceInvoiceType =1 
AND a.SpareCode = Items.Product_Code
And a.IssueID = Iss.IssueID
And a.Issue_serial = Iss.SerialNo
AND ISnull(ServiceInvoiceAbstract.Status,0) & 192 = 0
And Isnull(a.Sparecode,'')<> ''
AND Items.BrandID = @BRANDID
AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN  @FROMDATE AND @TODATE
GROUP BY Items.Product_Code, Items.ProductName

Select ProductCode,[Item Name],"Trading Margin (%c)" = sum([Trading Margin]) from #BrandTemp 
Group by #BrandTemp.ProductCode,#BrandTemp.[Item Name] 

Drop table #BrandTemp 

