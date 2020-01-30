
create procedure sp_acc_retrieveinvoiceinfo(@invoiceid int)
as
select InvoiceType,PaymentMode 
from InvoiceAbstract
where InvoiceID = @invoiceid

