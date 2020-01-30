CREATE Procedure sp_ser_getlowestpaymentdate(@AlertDate DateTime)
As
select Top 1 PaymentDate
from (
--Begin: Get Lowest Payment Date for Invoice
select PaymentDate
from InvoiceAbstract 
where isNull(Status,0) & 128 = 0 and PaymentDate <= @AlertDate
and isNull(Balance,0) <> 0
and isNull(InvoiceType,0) in (1,3) 
--End: Get Lowest Payment Date for Invoice
union
--Begin: Get Lowest Payment Date for Service Invoice
select PaymentDate
from ServiceInvoiceAbstract 
where isNull(Status,0) & 192 = 0 and PaymentDate <= @AlertDate
and isNull(Balance,0) <> 0
and isNull(ServiceInvoicetype,0) in (1)
--End: Get Lowest Payment Date for Service Invoice
) as ResultSet order by PaymentDate

