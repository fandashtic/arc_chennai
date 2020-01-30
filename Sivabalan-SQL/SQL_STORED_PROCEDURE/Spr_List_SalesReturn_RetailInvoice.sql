CREATE procedure [dbo].[Spr_List_SalesReturn_RetailInvoice] (@FromDate datetime,  
           @ToDate datetime)  
As  
Select InvoiceAbstract.InvoiceID,   
"Invoice No" = VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID As nvarchar),  
"Customer" = Customer.Company_Name,  
"Membership Code" = Customer.CustomerID,  
"Net Value (%c)" = InvoiceAbstract.NetValue,  
"Goods Returned Value (%c)" = (Select -Sum(abs(InvoiceDetail.Amount)) From InvoiceDetail   
Where InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID And  
(InvoiceDetail.Quantity < 0 or InvoiceAbstract.InvoiceType in(5,6))) 
From InvoiceAbstract, Customer, VoucherPrefix  
Where InvoiceAbstract.CustomerID *= Customer.CustomerID And  
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
InvoiceAbstract.Status & 128 = 0 And  
InvoiceAbstract.Status & 256 = 256 And customer.customerCategory in(4,5) and
VoucherPrefix.TranID = 'INVOICE'
