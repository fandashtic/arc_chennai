CREATE Procedure Spr_List_Itemwise_SalesreturnReport(@FromDate datetime,@ToDate datetime)
As
Select Items.ProductName,
"Item Name" = Items.ProductName,
"Damaged Qty"=
Sum(case When (Status & 32) <> 0 Then InvoiceDetail.Quantity Else 0 End),
"Damaged Value"=
Sum(case When (Status & 32) <> 0 Then ISnull((InvoiceDetail.Quantity * InvoiceDetail.SalePrice),0) Else 0 End),
"Rejected Qty"=
Sum(case When (Status & 32) <> 0 Then 0 Else InvoiceDetail.Quantity  End),
"Rejected Value"=
Sum(case When (Status & 32) <> 0 Then 0 Else ISnull((InvoiceDetail.Quantity * InvoiceDetail.SalePrice),0) End)
From Items,InvoiceDetail,InvoiceAbstract
Where InvoiceDetail.Product_Code = Items.Product_Code
And InvoiceDetail.InvoiceID=InvoiceAbstract.InvoiceID
And InvoiceAbstract.InvoiceType=4
And Invoicedate Between @FromDate And @Todate
And Status & 128 = 0
Group By Items.ProductName

