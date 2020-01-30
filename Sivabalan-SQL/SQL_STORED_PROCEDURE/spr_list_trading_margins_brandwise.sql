CREATE PROCEDURE spr_list_trading_margins_brandwise(@FROMDATE DATETIME, @TODATE DATETIME)
AS
create table #temp(BrandID int, BrandName nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS, Margin Decimal(18,6))
insert into #temp
SELECT Brand.BrandID, 
"Division" = Brand.BrandName, 
"Trading Margin (%c.)" = (ISNULL(Sum(a.Amount),0) 
- Sum(ISNULL(a.PurchasePrice, 0))
- ABS(ISNULL(Sum(a.STPayable), 0)) 
- ABS(ISNULL(Sum(a.CSTPayable), 0))
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
When 1 Then  
(a.MRP * a.Quantity) * dbo.fn_get_TaxOnMRP(a.TaxSuffered) / 100
Else  
(a.PurchasePrice * a.TaxSuffered) / 100
End),0)
- ISNULL((SELECT Sum(InvoiceDetail.Amount) 
- sum(ABS(InvoiceDetail.STPayable)) 
- sum(InvoiceDetail.PurchasePrice) 
- sum(ABS(InvoiceDetail.CSTPayable)) 
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
When 1 Then  
(InvoiceDetail.MRP * InvoiceDetail.Quantity) * dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100
Else  
(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered) / 100
End),0)
FROM InvoiceDetail, InvoiceAbstract, Items
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND (InvoiceAbstract.InvoiceType = 4 Or (InvoiceType = 2 And InvoiceDetail.Quantity < 0))
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.Status & 128 = 0
AND InvoiceDetail.Product_Code = Items.Product_Code
AND Items.BrandID = Brand.BrandID And Items.Product_Code = I1.Product_Code), 0))
FROM InvoiceDetail a, InvoiceAbstract, Items I1, Brand
WHERE a.InvoiceID = InvoiceAbstract.InvoiceID
AND InvoiceAbstract.InvoiceType <> 4
AND a.Product_Code = I1.Product_Code
AND a.Quantity > 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.Status & 128 = 0
AND I1.BrandID = Brand.BrandID
AND Brand.Active = 1
GROUP BY Brand.BrandID, Brand.BrandName, I1.Product_Code
select BrandID, "Division" = BrandName, "Trading Margin (%c.)" = Sum(Margin)
From #temp
Group By BrandID, BrandName
drop table #temp






