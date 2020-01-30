CREATE procedure [dbo].[spr_list_ReturnFromCustomer]
(@fromdate datetime,@todate datetime)
as

Declare @SALEABLE As NVarchar(50)
Declare @DAMAGED As NVarchar(50)

Set @SALEABLE = dbo.LookupDictionaryItem(N'Saleable', Default)
Set @DAMAGED = dbo.LookupDictionaryItem(N'Damaged', Default)

Select Invoiceabstract.CustomerId, 
"Name of the Retailer"=Customer.Company_Name,
"SKU Code"=INvoiceDetail.Product_Code, 
"SKU Name"=Items.ProductName,"Brand Pack"=ItemCategories.Category_Name,
"Volume"=Sum(Invoicedetail.Quantity),"Value"=Sum(InvoicedetAIL.AMOUNT),
"Reason for Return "=StockAdjustmentReason.Message,
"Date of Return"=dbo.StripDateFromTime(Invoiceabstract.Invoicedate), 
"Type of Return"=case (Status & 32) When 0 Then @SALEABLE Else @DAMAGED end
From InvoiceAbstract, InvoiceDetail, Customer, StockAdjustmentReason,
ItemCategories, Items Where 
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate and
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
And InvoiceAbstract.InvoiceType = 4 
And (InvoiceAbstract.Status & 128) = 0
And InvoiceAbstract.CustomerID = Customer.CustomerID 
And InvoiceDetail.Product_Code = Items.Product_Code
And Items.CategoryID = ItemCategories.CategoryID
And InvoiceDetail.ReasonID *= StockAdjustmentReason.MessageID
Group by dbo.StripDateFromTime(Invoiceabstract.Invoicedate),
Invoiceabstract.CustomerId,Customer.Company_Name,
INvoiceDetail.Product_Code,Items.ProductName,
ItemCategories.Category_Name,Status,StockAdjustmentReason.Message
