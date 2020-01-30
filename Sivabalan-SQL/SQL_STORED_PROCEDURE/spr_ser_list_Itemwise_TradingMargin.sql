CREATE procedure [dbo].[spr_ser_list_Itemwise_TradingMargin](@ITEMCODE NVARCHAR(15),  
         @FROMDATE DATETIME,  
         @TODATE DATETIME)  
  
AS  

DECLARE @VoucherPrefix nvarchar(50)  

Create Table #TradingMardingDetail (Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, 
InvoiceID nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Doc Reference] varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Invoice Date] datetime, Quantity Decimal(18,6),SalePrice Decimal(18,6),PurchasePrice Decimal(18,6), [Trading Margin] Decimal(18,6))



SELECT @VoucherPrefix = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE'  

Insert Into #TradingMardingDetail

SELECT InvoiceDetail.Product_Code,   
"InvoiceID" = @VoucherPrefix + CAST(InvoiceAbstract.DocumentID AS VARCHAR),   
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
ABS(InvoiceDetail.MRP * dbo.sp_ser_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100)   
Else
ABS((InvoiceDetail.PurchasePrice / InvoiceDetail.Quantity) * InvoiceDetail.TaxSuffered / 100)
End),0) as Decimal(18,6)),

"PurchasePrice" = SUM(InvoiceDetail.PurchasePrice) / (CASE SUM(InvoiceDetail.Quantity)
 WHEN 0   
  
THEN 1 ELSE SUM(InvoiceDetail.Quantity) END),  
"Trading Margin (%c.)" = (SUM(InvoiceDetail.Amount)   
- ISNULL((SUM(InvoiceDetail.PurchasePrice)), 0)   
- ISNULL(SUM(InvoiceDetail.STPayable), 0)   
- ISNULL(SUM(InvoiceDetail.CSTPayable), 0)  
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0) 
When 1 Then
(InvoiceDetail.MRP * InvoiceDetail.Quantity) * dbo.sp_ser_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100  
Else
(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered) / 100
End),0))
FROM InvoiceDetail, InvoiceAbstract, Items  
WHERE Items.Product_Code = InvoiceDetail.Product_Code  
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
AND InvoiceAbstract.InvoiceType <> 4  
AND InvoiceAbstract.InvoiceDate BETWEEN @FromDate And @Todate
AND InvoiceAbstract.Status & 128 = 0 AND InvoiceDetail.Product_Code = @Itemcode And   
InvoiceDetail.Quantity > 0  
GROUP BY InvoiceAbstract.DocumentID, InvoiceAbstract.DocReference,InvoiceAbstract.InvoiceDate,   
  
InvoiceDetail.Product_Code, InvoiceDetail.SalePrice, InvoiceAbstract.TaxOnMRP
  
UNION  
  
SELECT InvoiceDetail.Product_Code,   
@VoucherPrefix + CAST(InvoiceAbstract.DocumentID AS VARCHAR),   
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
ABS(InvoiceDetail.MRP * dbo.sp_ser_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100)
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
(InvoiceDetail.MRP * InvoiceDetail.Quantity) * dbo.sp_ser_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100
Else
(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered) / 100
End),0)) 
FROM InvoiceDetail, InvoiceAbstract, Items  
WHERE Items.Product_Code = InvoiceDetail.Product_Code  
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
AND InvoiceAbstract.InvoiceType = 4  
AND InvoiceAbstract.InvoiceDate BETWEEN @FromDate And @Todate
AND InvoiceAbstract.Status & 128 = 0 AND InvoiceDetail.Product_Code = @ITEMCODE And   
InvoiceDetail.Quantity > 0  
GROUP BY InvoiceAbstract.DocumentID, InvoiceAbstract.DocReference,InvoiceAbstract.InvoiceDate,   
InvoiceDetail.Product_Code, InvoiceDetail.SalePrice, InvoiceAbstract.TaxOnMRP 

UNION

SELECT InvoiceDetail.Product_Code,   
"InvoiceID" = @VoucherPrefix + CAST(InvoiceAbstract.DocumentID AS VARCHAR),   
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
ABS(InvoiceDetail.MRP * dbo.sp_ser_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100)
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
(InvoiceDetail.MRP * InvoiceDetail.Quantity) / dbo.sp_ser_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100
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
GROUP BY InvoiceAbstract.DocumentID, InvoiceAbstract.DocReference,InvoiceAbstract.InvoiceDate,   
InvoiceDetail.Product_Code, InvoiceDetail.SalePrice
ORDER BY InvoiceAbstract.InvoiceDate, InvoiceAbstract.InvoiceID


Insert Into #TradingMardingDetail


SELECT ServiceInvoiceDetail.SpareCode,   
"InvoiceID" = VoucherPrefix.Prefix + CAST(serviceInvoiceAbstract.DocumentID AS VARCHAR),     
"Doc Reference"=DocReference,  
"Invoice Date" = ServiceInvoiceAbstract.ServiceInvoiceDate,   
"Quantity" = SUM(ServiceInvoiceDetail.Quantity),  

"SalePrice" = Cast(SUM(serviceInvoiceDetail.NetValue) /(CASE SUM(ServiceInvoiceDetail.Quantity) WHEN 0 THEN 1 ELSE   
SUM(ServiceInvoiceDetail.Quantity) END )  
- ABS(ISNULL(SUM(ServiceInvoiceDetail.LSTPayable), 0) / (CASE SUM(ServiceInvoiceDetail.Quantity) WHEN 0 THEN 1   
  
ELSE SUM(ServiceInvoiceDetail.Quantity) END ))  
- ABS(ISNULL(SUM(isnull(ServiceInvoiceDetail.CSTPayable,0)), 0) / (CASE SUM(ServiceInvoiceDetail.Quantity) WHEN 0 THEN 1   
  
ELSE SUM(ServiceinvoiceDetail.Quantity) END ))  

- abs(sum(Isnull((isnull(iss.PurchasePrice,0) / serviceInvoiceDetail.Quantity) * (isnull(ServiceInvoiceDetail.Tax_SufferedPercentage,0)) / 100,0))) as Decimal(18,6)),



"PurchasePrice" = SUM(isnull(Iss.PurchasePrice,0)) / (CASE SUM(serviceInvoiceDetail.Quantity) 
WHEN 0   
THEN 1 ELSE SUM(serviceInvoiceDetail.Quantity) END),  

"Trading Margin (%c)" = ISNULL(Sum(serviceinvoicedetail.NetValue),0) 
- Sum(ISNULL(Iss.PurchasePrice, 0))
- SUM(ABS(ISNULL(serviceinvoicedetail.LSTPayable, 0))) - SUM(ABS(ISNULL(serviceinvoicedetail.CSTPayable, 0)))
 - Sum(ABS(ISNULL((isnull(Iss.PurchasePrice,0) * isnull(serviceInvoicedetail.Tax_SufferedPercentage,0))/100,0)))

FROM ServiceInvoiceDetail, ServiceInvoiceAbstract, Items ,IssueDetail Iss,VoucherPrefix
WHERE Items.Product_Code = ServiceInvoiceDetail.SpareCode  
AND ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID  
And ServiceInvoiceDetail.IssueID =Iss.IssueID
And ServiceInvoiceDetail.Issue_serial = Iss.SerialNo
AND ServiceInvoiceAbstract.serviceInvoiceType = 1  
And Isnull(serviceinvoicedetail.sparecode,'')<> ''
And VoucherPrefix.tranid = 'SERVICEINVOICE'   
AND ServiceInvoiceAbstract.serviceInvoiceDate BETWEEN @FromDate and @Todate
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0 
AND ServiceInvoiceDetail.SpareCode = @ITEMCODE
GROUP BY ServiceInvoiceAbstract.DocumentID, ServiceInvoiceAbstract.DocReference,
ServiceInvoiceAbstract.ServiceInvoiceDate,VoucherPrefix.Prefix,   
serviceInvoiceDetail.SpareCode,ServiceInvoiceDetail.Price

Select * from  #TradingMardingDetail 
order by [Invoice Date]
drop table #TradingMardingDetail
