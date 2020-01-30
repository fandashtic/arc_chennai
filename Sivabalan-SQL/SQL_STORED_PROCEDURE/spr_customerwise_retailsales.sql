CREATE procedure [dbo].[spr_customerwise_retailsales](@FROMDATE datetime,  
     @TODATE datetime)  
AS  
select invoiceabstract.customerid, "Invoice" = sum(invoicedetail.quantity), "Sales" = sum(invoicedetail.amount) from invoiceabstract, cash_customer,invoicedetail where invoiceabstract.customerid *= cast(cash_customer.customerid as nvarchar) 
and invoiceabstract.invoiceid = invoicedetail.invoiceid 
and invoiceabstract.invoicetype = 2
And (InvoiceAbstract.Status & 128) = 0
and invoiceabstract.invoicedate between @fromdate and @todate
group by invoiceabstract.customerid
