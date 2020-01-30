CREATE PROCEDURE spr_list_Itemwise_TradingMargin(@ITEMCODE nvarchar(15),    
         @FROMDATE DATETIME,    
         @TODATE DATETIME)    
    
AS    
DECLARE @VoucherPrefix nvarchar(50)    
SELECT @VoucherPrefix = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE'    
SELECT InvoiceDetail.Product_Code,     
"InvoiceID" = Case IsNull(InvoiceAbstract.GSTFlag,0) when 0 then @VoucherPrefix + CAST(InvoiceAbstract.DocumentID AS nvarchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'') END,     
"Doc Reference"=DocReference,    
"Invoice Date" = InvoiceAbstract.InvoiceDate,     
"Quantity" = SUM(InvoiceDetail.Quantity),    
"SalePrice" = Cast(SUM(InvoiceDetail.Amount) /  (CASE SUM(InvoiceDetail.Quantity) WHEN 0 THEN 1 ELSE     
    
SUM(InvoiceDetail.Quantity) END )    
- ABS(ISNULL(SUM(InvoiceDetail.STPayable), 0) / (CASE SUM(InvoiceDetail.Quantity) WHEN 0 THEN 1     
    
ELSE SUM(InvoiceDetail.Quantity) END ))    
- ABS(ISNULL(SUM(InvoiceDetail.CSTPayable), 0) / (CASE SUM(InvoiceDetail.Quantity) WHEN 0 THEN 1     
    
ELSE SUM(InvoiceDetail.Quantity) END ))    
- IsNull(SUM(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
When 1 Then  
ABS(InvoiceDetail.MRP * dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100)     
Else  
ABS((InvoiceDetail.PurchasePrice / InvoiceDetail.Quantity) * InvoiceDetail.TaxSuffered / 100)  
End),0) as Decimal(18,6)),  
  
"PurchasePrice" = SUM(InvoiceDetail.PurchasePrice) / (CASE SUM(InvoiceDetail.Quantity) WHEN 0     
    
THEN 1 ELSE SUM(InvoiceDetail.Quantity) END),    
"Trading Margin (%c.)" = (SUM(InvoiceDetail.Amount)     
- ISNULL((SUM(InvoiceDetail.PurchasePrice)), 0)     
- ISNULL(SUM(InvoiceDetail.STPayable), 0)     
- ISNULL(SUM(InvoiceDetail.CSTPayable), 0)    
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
When 1 Then  
(InvoiceDetail.MRP * InvoiceDetail.Quantity) * dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100    
Else  
(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered) / 100  
End),0))  
FROM InvoiceDetail, InvoiceAbstract, Items    
WHERE Items.Product_Code = InvoiceDetail.Product_Code    
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
AND InvoiceAbstract.InvoiceType <> 4    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE    
AND InvoiceAbstract.Status & 128 = 0 AND InvoiceDetail.Product_Code = @ITEMCODE And     
InvoiceDetail.Quantity > 0    
GROUP BY InvoiceAbstract.DocumentID, InvoiceAbstract.DocReference,InvoiceAbstract.InvoiceDate,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID,     
    
InvoiceDetail.Product_Code, InvoiceDetail.SalePrice, InvoiceAbstract.TaxOnMRP  
    
UNION    
    
SELECT InvoiceDetail.Product_Code,     
Case IsNull(InvoiceAbstract.GSTFlag,0) when 0 then @VoucherPrefix + CAST(InvoiceAbstract.DocumentID AS nvarchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'') END,
DocReference,    
InvoiceAbstract.InvoiceDate,     
0 - SUM(InvoiceDetail.Quantity),    
cast(SUM(InvoiceDetail.Amount) /  (CASE SUM(InvoiceDetail.Quantity) WHEN 0 THEN 1 ELSE     
    
SUM(InvoiceDetail.Quantity) END )    
- ABS(ISNULL(SUM(InvoiceDetail.STPayable), 0) / (CASE SUM(InvoiceDetail.Quantity) WHEN 0 THEN 1     
    
ELSE SUM(InvoiceDetail.Quantity) END ))    
- ABS(ISNULL(SUM(InvoiceDetail.CSTPayable), 0) / (CASE SUM(InvoiceDetail.Quantity) WHEN 0 THEN 1     
    
ELSE SUM(InvoiceDetail.Quantity) END ))    
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
When 1 Then  
ABS(InvoiceDetail.MRP * dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100)  
Else  
ABS(InvoiceDetail.PurchasePrice / InvoiceDetail.Quantity * InvoiceDetail.TaxSuffered / 100)  
End),0) as Decimal(18,6)),  
SUM(InvoiceDetail.PurchasePrice) / (CASE SUM(InvoiceDetail.Quantity) WHEN 0     
    
THEN 1 ELSE SUM(InvoiceDetail.Quantity) END),    
-(SUM(InvoiceDetail.Amount)     
- ISNULL((SUM(InvoiceDetail.PurchasePrice)), 0)     
- ABS(ISNULL(SUM(InvoiceDetail.STPayable), 0))     
- ABS(ISNULL(SUM(InvoiceDetail.CSTPayable), 0))    
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
When 1 Then  
(InvoiceDetail.MRP * InvoiceDetail.Quantity) * dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100  
Else  
(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered) / 100  
End),0))   
FROM InvoiceDetail, InvoiceAbstract, Items    
WHERE Items.Product_Code = InvoiceDetail.Product_Code    
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
AND InvoiceAbstract.InvoiceType = 4    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE    
AND InvoiceAbstract.Status & 128 = 0 AND InvoiceDetail.Product_Code = @ITEMCODE And     
InvoiceDetail.Quantity > 0    
GROUP BY InvoiceAbstract.DocumentID, InvoiceAbstract.DocReference,InvoiceAbstract.InvoiceDate,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID,     
InvoiceDetail.Product_Code, InvoiceDetail.SalePrice, InvoiceAbstract.TaxOnMRP   
  
UNION  
  
SELECT InvoiceDetail.Product_Code,     
"InvoiceID" = Case IsNull(InvoiceAbstract.GSTFlag,0) when 0 then @VoucherPrefix + CAST(InvoiceAbstract.DocumentID AS nvarchar)else ISNULL(InvoiceAbstract.GSTFullDocID,'') END,     
"Doc Reference"=DocReference,    
"Invoice Date" = InvoiceAbstract.InvoiceDate,     
"Quantity" = SUM(InvoiceDetail.Quantity),    
"SalePrice" = Cast(SUM(ABS(InvoiceDetail.Amount)) /  (CASE SUM(ABS(InvoiceDetail.Quantity)) WHEN 0 THEN 1 ELSE     
    
ABS(SUM(InvoiceDetail.Quantity)) END )    
- ABS(ISNULL(SUM(InvoiceDetail.STPayable), 0) / (CASE SUM(InvoiceDetail.Quantity) WHEN 0 THEN 1     
    
ELSE ABS(SUM(InvoiceDetail.Quantity)) END ))    
- ABS(ISNULL(SUM(InvoiceDetail.CSTPayable), 0) / (CASE SUM(InvoiceDetail.Quantity) WHEN 0 THEN 1     
    
ELSE SUM(InvoiceDetail.Quantity) END ))    
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
When 1 Then  
ABS(InvoiceDetail.MRP * dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100)  
Else  
ABS(InvoiceDetail.PurchasePrice / InvoiceDetail.Quantity * InvoiceDetail.TaxSuffered / 100)  
End),0) as Decimal(18,6)),  
  
"PurchasePrice" = ABS(SUM(InvoiceDetail.PurchasePrice) / (CASE SUM(InvoiceDetail.Quantity) WHEN 0     
    
THEN 1 ELSE SUM(InvoiceDetail.Quantity) END)),    
"Trading Margin (%c.)" = 0-(ABS(SUM(InvoiceDetail.Amount))     
- ISNULL((ABS(SUM(InvoiceDetail.PurchasePrice))), 0)     
- ISNULL(ABS(SUM(InvoiceDetail.STPayable)), 0)     
- ISNULL(ABS(SUM(InvoiceDetail.CSTPayable)), 0)    
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
When 1 Then  
(InvoiceDetail.MRP * InvoiceDetail.Quantity) / dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100  
Else  
(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered) / 100  
End),0))   
FROM InvoiceDetail, InvoiceAbstract, Items    
WHERE Items.Product_Code = InvoiceDetail.Product_Code    
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
AND InvoiceAbstract.InvoiceType = 2    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE    
AND InvoiceAbstract.Status & 128 = 0 AND InvoiceDetail.Product_Code = @ITEMCODE And     
InvoiceDetail.Quantity < 0    
GROUP BY InvoiceAbstract.DocumentID, InvoiceAbstract.DocReference,InvoiceAbstract.InvoiceDate, InvoiceAbstract.GSTFullDocID,  InvoiceAbstract.GSTFlag,    
InvoiceDetail.Product_Code, InvoiceDetail.SalePrice  
ORDER BY InvoiceAbstract.InvoiceDate,InvoiceID  
