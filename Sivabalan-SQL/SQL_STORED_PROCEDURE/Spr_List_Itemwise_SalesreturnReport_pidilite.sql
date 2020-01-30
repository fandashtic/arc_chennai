CREATE Procedure Spr_List_Itemwise_SalesreturnReport_pidilite(@FromDate datetime,@ToDate datetime)
As
Select Items.ProductName,
"Item Name" = Items.ProductName,
"Damaged Qty"=
Sum(case When (Status & 32) <> 0 Then InvoiceDetail.Quantity Else 0 End),
"Damaged Qty Reporting UOM" = Sum((case When (Status & 32) <> 0 Then InvoiceDetail.Quantity Else 0 End) / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),
"Damaged Qty Conversion Factor" = Sum((case When (Status & 32) <> 0 Then InvoiceDetail.Quantity Else 0 End) * IsNull(ConversionFactor, 0)),
"Damaged Value"=
Sum(case When (Status & 32) <> 0 Then ISnull((InvoiceDetail.Quantity * InvoiceDetail.SalePrice),0) Else 0 End),
"Rejected Qty"=
Sum(case When (Status & 32) <> 0 Then 0 Else InvoiceDetail.Quantity  End),
"Rejected Qty Reporting UOM" = Sum((case When (Status & 32) <> 0 Then 0 Else InvoiceDetail.Quantity  End) / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),
"Rejected Qty Conversion Factor" = Sum((case When (Status & 32) <> 0 Then 0 Else InvoiceDetail.Quantity  End) * IsNull(ConversionFactor, 0)),
"Rejected Value"=
Sum(case When (Status & 32) <> 0 Then 0 Else ISnull((InvoiceDetail.Quantity * InvoiceDetail.SalePrice),0) End)
From Items,InvoiceDetail,InvoiceAbstract
Where InvoiceDetail.Product_Code = Items.Product_Code
And InvoiceDetail.InvoiceID=InvoiceAbstract.InvoiceID
And InvoiceAbstract.InvoiceType=4
And Invoicedate Between @FromDate And @Todate
And Status & 128 = 0
Group By Items.ProductName

