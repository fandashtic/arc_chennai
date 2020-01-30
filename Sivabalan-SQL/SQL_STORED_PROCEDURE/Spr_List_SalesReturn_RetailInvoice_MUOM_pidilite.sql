CREATE procedure [dbo].[Spr_List_SalesReturn_RetailInvoice_MUOM_pidilite] (@FromDate datetime,
						     @ToDate datetime, @UOMDesc nvarchar(30))
As
Select InvoiceAbstract.InvoiceID, 
"Invoice No" = VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID As nvarchar),
"Doc Reference" = DocReference,
"Customer" = Customer.Company_Name,
"Membership Code" = Customer.MembershipCode,
"Net Value (%c)" = InvoiceAbstract.NetValue,
"Goods Returned Value (%c)" = (Select Sum(InvoiceDetail.Amount) From InvoiceDetail 
Where InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID)
From InvoiceAbstract, Customer, VoucherPrefix
Where InvoiceAbstract.CustomerID *= Customer.CustomerID And
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And
InvoiceAbstract.Status & 192 = 0 And InvoiceType In (5, 6) And
--InvoiceAbstract.Status & 256 = 256 And
VoucherPrefix.TranID = 'INVOICE'
