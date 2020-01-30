CREATE PROCEDURE spr_list_trading_margins_brandwise_detail(@BRANDID INT,
		  			         @FROMDATE DATETIME, 
						 @TODATE DATETIME)
AS
SELECT Items.Product_Code, "Item Name" = Items.ProductName,
"Trading Margin (%c.)" = (ISNULL(Sum(a.Amount),0) 
- Sum(ISNULL(a.PurchasePrice, 0))
- ABS(ISNULL(SUM(a.STPayable), 0)) 
- ABS(ISNULL(SUM(a.CSTPayable), 0))
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)     
When 1 Then    
(a.MRP * a.Quantity) * dbo.fn_get_TaxOnMRP(a.TaxSuffered) / 100
Else    
(a.PurchasePrice * a.TaxSuffered) / 100
End),0)  
- ISNULL((SELECT ISNULL(Sum(InvoiceDetail.Amount),0) 
- sum(abs(InvoiceDetail.STPayable)) 
- sum(InvoiceDetail.PurchasePrice) 
- sum(abs(InvoiceDetail.CSTPayable)) 
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)     
When 1 Then    
(InvoiceDetail.MRP * InvoiceDetail.Quantity) * dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100
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





