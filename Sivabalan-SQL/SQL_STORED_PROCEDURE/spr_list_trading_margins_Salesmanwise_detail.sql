CREATE PROCEDURE spr_list_trading_margins_Salesmanwise_detail(@smanid INT,
@FROMDATE DATETIME,@TODATE DATETIME)
AS
	create table #temp(ProductCode nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, ProductName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,TotSale Decimal(18,6),totCost Decimal(18,6),Margin Decimal(18,6))
	insert into #temp
	SELECT Items.Product_Code, "Item Name" = Items.ProductName,
	"Sales Value(%c)"=Case InvoiceAbstract.InvoiceType
			When 4 then 0-ISNULL(a.Amount,0) Else ISNULL(a.Amount,0) End,
	"Goods Value(%c)"=Case InvoiceAbstract.InvoiceType
			When 4 then 0-(ISNULL(a.PurchasePrice, 0)
				+ ABS(ISNULL(a.STPayable , 0)) 
				+ ABS(ISNULL(a.CSTPayable, 0))
				+ IsNull(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
				When 1 Then  
				(a.MRP * a.Quantity) * dbo.fn_get_TaxOnMRP(a.TaxSuffered) / 100
				Else  
				(a.PurchasePrice * a.TaxSuffered) / 100
				End,0))
			Else	ISNULL(a.PurchasePrice, 0)
				+ ABS(ISNULL(a.STPayable , 0)) 
				+ ABS(ISNULL(a.CSTPayable, 0))
				+ IsNull(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
				When 1 Then  
				(a.MRP * a.Quantity) * dbo.fn_get_TaxOnMRP(a.TaxSuffered) / 100
				Else  
				(a.PurchasePrice * a.TaxSuffered) / 100
				End,0)
			End,
	"Margin Value(%c)"=Case InvoiceAbstract.InvoiceType
		When 4 then 0-ISNULL(a.Amount,0)-(0-(ISNULL(a.PurchasePrice, 0)
				+ ABS(ISNULL(a.STPayable , 0)) 
				+ ABS(ISNULL(a.CSTPayable, 0))
				+ IsNull(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
				When 1 Then  
				(a.MRP * a.Quantity) * dbo.fn_get_TaxOnMRP(a.TaxSuffered) / 100
				Else  
				(a.PurchasePrice * a.TaxSuffered) / 100
				End,0)))
		Else ISNULL(a.Amount,0)-(ISNULL(a.PurchasePrice, 0)
				+ ABS(ISNULL(a.STPayable , 0)) 
				+ ABS(ISNULL(a.CSTPayable, 0))
				+ IsNull(Case Isnull(InvoiceAbstract.TaxOnMRP,0)   
				When 1 Then  
				(a.MRP * a.Quantity) * dbo.fn_get_TaxOnMRP(a.TaxSuffered) / 100
				Else  
				(a.PurchasePrice * a.TaxSuffered) / 100
				End,0)) 
		End
FROM InvoiceDetail a, InvoiceAbstract, Items
WHERE a.InvoiceID = InvoiceAbstract.InvoiceID
AND InvoiceAbstract.InvoiceType not in (2)
AND a.Product_Code = Items.Product_Code
AND a.Quantity > 0
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND InvoiceAbstract.Status & 128 = 0
And Invoiceabstract.SalesManid=@smanid


Select ProductCode,"Item Name" =ProductName,
"Sales Value(%c)"=Sum(TotSale),
"Goods Value(%c)"=Sum(TotCost),
"Margin Value(%c)"=Sum(Margin)
From #temp
Group by ProductCode,ProductName


Drop Table #temp









