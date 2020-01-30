CREATE PROCEDURE spr_ser_list_trading_margins_manufacturerwise(@FROMDATE DATETIME, @TODATE DATETIME)
AS
create table #temp(ManufacturerID int, ManufacturerName varchar(225) COLLATE SQL_Latin1_General_CP1_CI_AS, Margin Decimal(18,6))
insert into #temp
SELECT Manufacturer.ManufacturerID, 
"Manufacturer Name" = Manufacturer.Manufacturer_Name, 
"Trading Margin (%c.)" = (ISNULL(Sum(a.Amount),0) 
- Sum(ISNULL(a.PurchasePrice, 0))
- ABS(ISNULL(Sum(a.STPayable), 0)) 
- ABS(ISNULL(Sum(a.CSTPayable), 0))
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)     
When 1 Then    
(a.MRP * a.Quantity) * dbo.sp_ser_get_TaxOnMRP(a.TaxSuffered) / 100   
Else    
(a.PurchasePrice * a.TaxSuffered) / 100
End),0)  
- ISNULL((SELECT Sum(InvoiceDetail.Amount) 
- sum(ABS(InvoiceDetail.STPayable)) 
- sum(InvoiceDetail.PurchasePrice) 
- sum(ABS(InvoiceDetail.CSTPayable))
- IsNull(Sum(Case Isnull(InvoiceAbstract.TaxOnMRP,0)     
When 1 Then    
(InvoiceDetail.MRP * InvoiceDetail.Quantity) * dbo.sp_ser_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100
Else    
(InvoiceDetail.PurchasePrice * InvoiceDetail.TaxSuffered) / 100
End),0)  
FROM InvoiceDetail, InvoiceAbstract, Items
WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND (InvoiceAbstract.InvoiceType = 4 Or (InvoiceType = 2 And InvoiceDetail.Quantity < 0))
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceDetail.Product_Code = Items.Product_Code
AND Items.ManufacturerID = Manufacturer.ManufacturerID And Items.Product_Code = I1.Product_Code), 0))
FROM InvoiceDetail a, InvoiceAbstract, Items I1, Manufacturer
WHERE a.InvoiceID = InvoiceAbstract.InvoiceID
AND InvoiceAbstract.InvoiceType <> 4
AND a.Product_Code = I1.Product_Code
AND a.Quantity > 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.Status & 128 = 0
AND I1.ManufacturerID = Manufacturer.ManufacturerID
AND Manufacturer.Active = 1
GROUP BY Manufacturer.ManufacturerID, Manufacturer.Manufacturer_Name, I1.Product_Code

insert into #temp

SELECT Manufacturer.ManufacturerID, 
"Manufacturer Name" = Manufacturer.Manufacturer_Name, 
"Trading Margin (Rs.)" = ISNULL(Sum(a.NetValue),0) 
- Sum(ISNULL(Iss.PurchasePrice, 0))
- SUM(ABS(ISNULL(a.LSTPayable, 0))) - SUM(ABS(ISNULL(a.CSTPayable, 0)))
 - Sum(ABS(ISNULL((isnull(Iss.PurchasePrice,0) * isnull(a.Tax_SufferedPercentage,0))/100,0))) 
FROM ServiceInvoiceDetail a, ServiceInvoiceAbstract, Items I1, Manufacturer,IssueDetail Iss
WHERE a.ServiceInvoiceID = ServiceInvoiceAbstract.ServiceInvoiceID
And a.IssueId = Iss.IssueID
And a.Issue_serial = Iss.SerialNo
AND ServiceInvoiceAbstract.ServiceInvoiceType =1
AND a.SpareCode = I1.Product_Code
And Isnull(a.Sparecode,'') <> ''
AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN @FROMDATE AND @TODATE
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0
AND I1.ManufacturerID = Manufacturer.ManufacturerID
AND isnull(Manufacturer.Active,0) = 1
GROUP BY Manufacturer.ManufacturerID, Manufacturer.Manufacturer_Name, I1.Product_Code

select ManufacturerID, "Manufacturer Name" = ManufacturerName, "Trading Margin (%c.)" = Sum(Margin)
From #temp
Group By ManufacturerID, ManufacturerName
drop table #temp



