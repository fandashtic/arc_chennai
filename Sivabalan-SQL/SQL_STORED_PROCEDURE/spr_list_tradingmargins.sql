CREATE PROCedure spr_list_tradingmargins(@FROMDATE DATETIME, @TODATE DATETIME)
AS
SELECT a.Product_Code, "Item Code" = a.Product_Code, "Item Name" = Items.ProductName, 
"Trading Margin (Rs.)" = ISNULL(Sum(a.Amount),0) 
- Sum(ISNULL(a.PurchasePrice, 0))
- SUM(ABS(ISNULL(a.STPayable, 0))) - SUM(ABS(ISNULL(a.CSTPayable, 0)))
- ABS(ISNULL(SUM(CASE IsNull(InvoiceAbstract.TaxOnMRP,0) 
WHEN 1 THEN
(a.MRP * a.Quantity) * (dbo.fn_get_TaxOnMRP(a.TaxSuffered) / 100)
ELSE
(a.PurchasePrice * a.TaxSuffered) / 100
END), 0))
- ISNULL((SELECT Sum(Abs(InvoiceDetail.Amount)) 
- sum(Abs(InvoiceDetail.PurchasePrice)) 
- ABS(ISNULL(sum(InvoiceDetail.STPayable), 0)) 
- ABS(ISNULL(sum(InvoiceDetail.CSTPayable), 0))
- ABS(ISNULL(SUM(CASE IsNull(InvA.TaxOnMRP,0) 
WHEN 1 THEN
(InvoiceDetail.MRP * InvoiceDetail.Quantity) * (dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100)
ELSE
(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered) / 100
END), 0))
FROM InvoiceDetail, InvoiceAbstract InvA
WHERE InvoiceDetail.InvoiceID = InvA.InvoiceID 
AND (InvA.InvoiceType = 4 Or (InvA.InvoiceType = 2 And InvoiceDetail.Quantity < 0))
AND InvA.InvoiceDate BETWEEN @FROMDATE AND @TODATE 
AND InvA.Status & 128 = 0
AND InvoiceDetail.Product_Code = a.Product_Code), 0)
FROM InvoiceDetail a, InvoiceAbstract, Items
WHERE a.InvoiceID = InvoiceAbstract.InvoiceID
AND InvoiceAbstract.InvoiceType <> 4 and a.Quantity > 0
AND a.Product_Code = Items.Product_Code
AND InvoiceAbstract.Status & 128 = 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
GROUP BY a.Product_Code, Items.ProductName

