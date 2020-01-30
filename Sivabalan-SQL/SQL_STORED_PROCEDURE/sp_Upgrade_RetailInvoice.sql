CREATE Procedure sp_Upgrade_RetailInvoice
As
Update InvoiceAbstract Set PaymentDetails = N'Cash:' + Cast(NetValue As nvarchar) + N'::0'
Where InvoiceType = 2 And IsNull(PaymentDetails, N'') = N''
