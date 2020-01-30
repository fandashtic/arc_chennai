CREATE function getinvoicedate(@invoiceid int)
returns datetime
as 
begin
declare @invoicedate datetime
select @invoicedate = InvoiceDate from InvoiceAbstract
where [InvoiceID]= @invoiceid
return @invoicedate
end


