CREATE procedure [dbo].[Spr_List_SalesReturn_RetailInvoice_Fmcg] (@FromDate datetime,  
           @ToDate datetime)  
As  
Select InvoiceAbstract.InvoiceID,   
"Invoice No" = VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID As nvarchar),  
"Customer" = Customer.Company_Name,  
"Membership Code" = Customer.CustomerID,  
"Net Value (%c)" = InvoiceAbstract.NetValue,  
"Goods Returned Value (%c)" = -Sum(abs(InvoiceDetail.Amount)) 

From InvoiceAbstract, InvoiceDetail, Customer, VoucherPrefix  
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And InvoiceAbstract.CustomerID *= Customer.CustomerID And  
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
InvoiceAbstract.Status & 128 = 0 And  
--InvoiceAbstract.Status & 256 = 256 And 
customer.customerCategory in(4,5) and InvoiceAbstract.InvoiceType In (5, 6) And
VoucherPrefix.TranID = 'INVOICE' Group By InvoiceAbstract.InvoiceID, 
VoucherPrefix.Prefix, InvoiceAbstract.DocumentID, Customer.Company_Name, 
Customer.CustomerID, InvoiceAbstract.NetValue
